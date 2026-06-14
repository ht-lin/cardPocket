<?php

declare(strict_types=1);

namespace App\MessageHandler;

use App\Message\CleanupExpiredDataMessage;
use App\Repository\CardDeletionRepository;
use Doctrine\ORM\EntityManagerInterface;
use Gesdinet\JWTRefreshTokenBundle\Model\RefreshTokenManagerInterface;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

/**
 * Prunes expired/stale data so unbounded tables (verification tokens, refresh tokens, card
 * deletion tombstones) do not grow forever. Runs daily via CleanupSchedule.
 */
#[AsMessageHandler]
final class CleanupExpiredDataHandler
{
    private const int TOMBSTONE_RETENTION_DAYS = 90;

    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly RefreshTokenManagerInterface $refreshTokenManager,
        private readonly CardDeletionRepository $cardDeletionRepository,
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
    }
}
