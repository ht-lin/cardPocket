<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\Card\CardOwnerOutput;
use App\ApiResource\Card\CardSyncOutput;
use App\ApiResource\Card\CardViewerOutput;
use App\Entity\User;
use App\Repository\CardRepository;
use App\Repository\CardShareRepository;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpFoundation\RequestStack;

final class CardListProvider implements ProviderInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly CardRepository $cardRepository,
        private readonly CardShareRepository $cardShareRepository,
        private readonly IncrementalSyncProvider $incrementalSyncProvider,
        private readonly RequestStack $requestStack,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): iterable|CardSyncOutput
    {
        /** @var User $user */
        $user = $this->security->getUser();

        $updatedAfterParam = $this->requestStack->getCurrentRequest()?->query->get('updatedAfter');
        if ($updatedAfterParam !== null) {
            return $this->incrementalSyncProvider->provide($user, new \DateTimeImmutable($updatedAfterParam));
        }

        $result = [];

        foreach ($this->cardRepository->findActiveByOwner($user) as $card) {
            $result[] = new CardOwnerOutput(
                id: (string) $card->getId(),
                name: $card->getName(),
                barcodeType: $card->getBarcodeType()->value,
                barcodeContent: $card->getBarcodeContent(),
                isOwner: true,
                createdAt: $card->getCreatedAt()->format(\DateTimeInterface::ATOM),
                updatedAt: $card->getUpdatedAt()->format(\DateTimeInterface::ATOM),
            );
        }

        foreach ($this->cardShareRepository->findByViewer($user) as $cardShare) {
            $card = $cardShare->getCard();
            $result[] = new CardViewerOutput(
                id: (string) $card->getId(),
                name: $card->getName(),
                barcodeType: $card->getBarcodeType()->value,
                barcodeContent: $card->getBarcodeContent(),
                isOwner: false,
                shareId: (string) $cardShare->getId(),
                viewerNickname: $cardShare->getViewerNickname(),
                createdAt: $card->getCreatedAt()->format(\DateTimeInterface::ATOM),
                updatedAt: $card->getUpdatedAt()->format(\DateTimeInterface::ATOM),
            );
        }

        return $result;
    }
}
