<?php

declare(strict_types=1);

namespace App\Service;

use App\Entity\Card;
use App\Entity\CardDeletion;
use App\Repository\CardShareRepository;
use Doctrine\ORM\EntityManagerInterface;

/**
 * Writes CardDeletion tombstones for a card's owner and all of its viewers, so a
 * removal (soft delete, permanent delete, or scheduled cleanup) propagates through
 * each user's incremental sync `deleted` list.
 */
final class CardTombstoneWriter
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly CardShareRepository $cardShareRepository,
    ) {
    }

    /**
     * Persist a CardDeletion tombstone for the owner and for every viewer of the card.
     * Does NOT flush — the caller controls the surrounding unit of work.
     */
    public function writeForOwnerAndViewers(Card $card, string $ownerId): void
    {
        $cardId = (string) $card->getId();

        $ownerDeletion = (new CardDeletion())
            ->setUserId($ownerId)
            ->setCardId($cardId);
        $this->entityManager->persist($ownerDeletion);

        foreach ($this->cardShareRepository->findByCard($card) as $cardShare) {
            $viewerDeletion = (new CardDeletion())
                ->setUserId((string) $cardShare->getViewer()->getId())
                ->setCardId($cardId);
            $this->entityManager->persist($viewerDeletion);
        }
    }
}
