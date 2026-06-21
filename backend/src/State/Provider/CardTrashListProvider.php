<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\Card\CardTrashOutput;
use App\Entity\User;
use App\Repository\CardRepository;
use Symfony\Bundle\SecurityBundle\Security;

/**
 * GET /api/cards/trash — the caller's own soft-deleted cards.
 *
 * @implements ProviderInterface<CardTrashOutput>
 */
final class CardTrashListProvider implements ProviderInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly CardRepository $cardRepository,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): iterable
    {
        /** @var User $user */
        $user = $this->security->getUser();

        $result = [];

        foreach ($this->cardRepository->findTrashedByOwner($user) as $card) {
            $deletedAt = $card->getDeletedAt();
            assert($deletedAt instanceof \DateTimeImmutable);

            $result[] = new CardTrashOutput(
                id: (string) $card->getId(),
                name: $card->getName(),
                barcodeType: $card->getBarcodeType()->value,
                barcodeContent: $card->getBarcodeContent(),
                isOwner: true,
                createdAt: $card->getCreatedAt()->format(\DateTimeInterface::ATOM),
                updatedAt: $card->getUpdatedAt()->format(\DateTimeInterface::ATOM),
                expiresAt: $card->getExpiresAt()?->format(\DateTimeInterface::ATOM),
                color: $card->getColor(),
                deletedAt: $deletedAt->format(\DateTimeInterface::ATOM),
            );
        }

        return $result;
    }
}
