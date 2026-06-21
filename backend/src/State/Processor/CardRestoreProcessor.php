<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\Card\CardOwnerOutput;
use App\Entity\Card;
use App\Security\Voter\CardVoter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * POST /api/cards/{id}/restore — pull a card out of the trash (owner only).
 *
 * Clearing `deletedAt` triggers Card::onPreUpdate(), which bumps `updatedAt`, so
 * the restored card naturally reappears in the next incremental sync `updated`.
 *
 * @implements ProcessorInterface<mixed, CardOwnerOutput>
 */
final class CardRestoreProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): CardOwnerOutput
    {
        if (!$data instanceof Card) {
            throw new NotFoundHttpException();
        }

        if (!$this->security->isGranted(CardVoter::CARD_DELETE, $data)) {
            throw new AccessDeniedHttpException();
        }

        // Only cards currently in the trash can be restored.
        if ($data->getDeletedAt() === null) {
            throw new NotFoundHttpException();
        }

        $data->setDeletedAt(null);
        $this->entityManager->flush();

        return new CardOwnerOutput(
            id: (string) $data->getId(),
            name: $data->getName(),
            barcodeType: $data->getBarcodeType()->value,
            barcodeContent: $data->getBarcodeContent(),
            isOwner: true,
            createdAt: $data->getCreatedAt()->format(\DateTimeInterface::ATOM),
            updatedAt: $data->getUpdatedAt()->format(\DateTimeInterface::ATOM),
            expiresAt: $data->getExpiresAt()?->format(\DateTimeInterface::ATOM),
            color: $data->getColor(),
        );
    }
}
