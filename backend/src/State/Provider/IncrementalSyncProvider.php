<?php

declare(strict_types=1);

namespace App\State\Provider;

use App\ApiResource\Card\CardOwnerOutput;
use App\ApiResource\Card\CardSyncOutput;
use App\ApiResource\Card\CardViewerOutput;
use App\Entity\User;
use App\Repository\CardDeletionRepository;
use App\Repository\CardRepository;
use App\Repository\CardShareRepository;

final class IncrementalSyncProvider
{
    public function __construct(
        private readonly CardRepository $cardRepository,
        private readonly CardShareRepository $cardShareRepository,
        private readonly CardDeletionRepository $cardDeletionRepository,
    ) {
    }

    public function provide(User $user, \DateTimeImmutable $since): CardSyncOutput
    {
        // Capture the server clock before querying so anything committed during/after this
        // request (updatedAt >= serverNow) is caught by the next sync (> serverNow).
        $serverNow = new \DateTimeImmutable();

        $updated = [];

        foreach ($this->cardRepository->findUpdatedByOwnerSince($user, $since) as $card) {
            // Cast to a plain array (public readonly props → clean string keys)
            // so CardSyncOutput carries flat data rather than resource objects.
            $updated[] = (array) new CardOwnerOutput(
                id: (string) $card->getId(),
                name: $card->getName(),
                barcodeType: $card->getBarcodeType()->value,
                barcodeContent: $card->getBarcodeContent(),
                isOwner: true,
                createdAt: $card->getCreatedAt()->format(\DateTimeInterface::ATOM),
                updatedAt: $card->getUpdatedAt()->format(\DateTimeInterface::ATOM),
                expiresAt: $card->getExpiresAt()?->format(\DateTimeInterface::ATOM),
            );
        }

        foreach ($this->cardShareRepository->findUpdatedSharesSince($user, $since) as $cardShare) {
            $card = $cardShare->getCard();
            $updated[] = (array) new CardViewerOutput(
                id: (string) $card->getId(),
                name: $card->getName(),
                barcodeType: $card->getBarcodeType()->value,
                barcodeContent: $card->getBarcodeContent(),
                isOwner: false,
                shareId: (string) $cardShare->getId(),
                viewerNickname: $cardShare->getViewerNickname(),
                createdAt: $card->getCreatedAt()->format(\DateTimeInterface::ATOM),
                updatedAt: $card->getUpdatedAt()->format(\DateTimeInterface::ATOM),
                expiresAt: $card->getExpiresAt()?->format(\DateTimeInterface::ATOM),
            );
        }

        $deleted = $this->cardDeletionRepository->findCardIdsByUserSince(
            (string) $user->getId(),
            $since,
        );

        return new CardSyncOutput(
            updated: $updated,
            deleted: $deleted,
            syncedAt: $serverNow->format(\DateTimeInterface::ATOM),
        );
    }
}
