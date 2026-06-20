<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\Card\CardOwnerOutput;
use App\Entity\Card;
use App\Security\Voter\CardVoter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProviderInterface<CardOwnerOutput>
 */
final class CardViewProvider implements ProviderInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly Security $security,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): CardOwnerOutput
    {
        $card = $this->entityManager->find(Card::class, Uuid::fromString((string) ($uriVariables['id'] ?? '')));

        if ($card === null) {
            throw new NotFoundHttpException();
        }

        if (!$this->security->isGranted(CardVoter::CARD_VIEW, $card)) {
            throw new AccessDeniedHttpException();
        }

        return $this->toOwnerOutput($card);
    }

    public function toOwnerOutput(Card $card): CardOwnerOutput
    {
        return new CardOwnerOutput(
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
}
