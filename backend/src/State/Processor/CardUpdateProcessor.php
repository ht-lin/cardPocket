<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\Card\CardOwnerOutput;
use App\ApiResource\Card\CardUpdateInput;
use App\Entity\Card;
use App\Entity\User;
use App\Security\Voter\CardVoter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProcessorInterface<CardUpdateInput, CardOwnerOutput>
 */
final class CardUpdateProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): CardOwnerOutput
    {
        assert($data instanceof CardUpdateInput);

        $user = $this->security->getUser();
        assert($user instanceof User);

        $card = $this->entityManager->find(Card::class, Uuid::fromString((string) ($uriVariables['id'] ?? '')));

        if ($card === null) {
            throw new NotFoundHttpException();
        }

        if (!$this->security->isGranted(CardVoter::CARD_EDIT, $card)) {
            throw new AccessDeniedHttpException();
        }

        if ($data->name !== null) {
            $card->setName($data->name);
        }

        $this->entityManager->flush();

        return new CardOwnerOutput(
            id: (string) $card->getId(),
            name: $card->getName(),
            barcodeType: $card->getBarcodeType()->value,
            barcodeContent: $card->getBarcodeContent(),
            isOwner: true,
            createdAt: $card->getCreatedAt()->format(\DateTimeInterface::ATOM),
            updatedAt: $card->getUpdatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
