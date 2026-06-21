<?php

declare(strict_types=1);

namespace App\MessageHandler;

use App\Message\CleanupExpiredDataMessage;
use App\Repository\CardDeletionRepository;
use App\Repository\CardRepository;
use App\Repository\CardShareRepository;
use App\Service\CardTombstoneWriter;
use Doctrine\ORM\EntityManagerInterface;
use Gesdinet\JWTRefreshTokenBundle\Model\RefreshTokenManagerInterface;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

/**
 * Prunes expired/stale data so unbounded tables (verification tokens, refresh tokens, card
 * deletion tombstones) do not grow forever, and advances cards through their lifecycle:
 * auto-trashing expired cards for AUTO_TRASH users and purging long-trashed cards.
 * Runs daily via CleanupSchedule.
 */
#[AsMessageHandler]
final class CleanupExpiredDataHandler
{
    private const int TOMBSTONE_RETENTION_DAYS = 90;
    private const int TRASH_PURGE_DAYS = 30;

    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly RefreshTokenManagerInterface $refreshTokenManager,
        private readonly CardDeletionRepository $cardDeletionRepository,
        private readonly CardRepository $cardRepository,
        private readonly CardShareRepository $cardShareRepository,
        private readonly CardTombstoneWriter $cardTombstoneWriter,
    ) {
    }

    public function __invoke(CleanupExpiredDataMessage $message): void
    {
        $now = new \DateTimeImmutable();

        // Expired email verification tokens.
        $this->entityManager->createQuery(
            'DELETE FROM App\Entity\EmailVerificationToken evt WHERE evt.expiresAt < :now'
        )->setParameter('now', $now)->execute();

        // Invalid (expired) refresh tokens — equivalent to gesdinet:jwt:clear.
        $this->refreshTokenManager->revokeAllInvalid();

        // Card deletion tombstones past the retention window.
        $this->cardDeletionRepository->deleteOlderThan(
            $now->modify('-' . self::TOMBSTONE_RETENTION_DAYS . ' days'),
        );

        // BE-CLEANUP-01: auto-trash expired cards of AUTO_TRASH users (write tombstones for
        // the owner and every viewer so the disappearance reaches each incremental sync).
        foreach ($this->cardRepository->findExpiredForAutoTrash($now) as $card) {
            $this->cardTombstoneWriter->writeForOwnerAndViewers($card, (string) $card->getOwner()->getId());
            $card->setDeletedAt($now);
        }
        $this->entityManager->flush();

        // BE-CLEANUP-02: physically purge cards trashed beyond the retention window, dropping
        // their CardShare rows. Just-trashed cards (deletedAt = now) cannot fall into this
        // cutoff, so the two passes never interfere.
        $purgeCutoff = $now->modify('-' . self::TRASH_PURGE_DAYS . ' days');
        foreach ($this->cardRepository->findPurgeable($purgeCutoff) as $card) {
            $this->cardTombstoneWriter->writeForOwnerAndViewers($card, (string) $card->getOwner()->getId());
            $this->cardShareRepository->deleteByCard($card);
            $this->entityManager->remove($card);
        }
        $this->entityManager->flush();
    }
}
