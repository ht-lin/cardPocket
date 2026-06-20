<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\Card\CardCreateInput;
use App\ApiResource\Card\CardOwnerOutput;
use App\Entity\Card;
use App\Entity\User;
use App\Repository\CardRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

/**
 * @implements ProcessorInterface<CardCreateInput, CardOwnerOutput>
 */
final class CardCreateProcessor implements ProcessorInterface
{
    private const int CARD_LIMIT = 200;

    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
        private readonly CardRepository $cardRepository,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): CardOwnerOutput
    {
        assert($data instanceof CardCreateInput);

        $user = $this->security->getUser();
        assert($user instanceof User);

        if ($user->getEmailVerifiedAt() === null) {
            throw new AccessDeniedHttpException();
        }

        if ($this->cardRepository->countActiveByOwner($user) >= self::CARD_LIMIT) {
            throw new UnprocessableEntityHttpException('You have reached the maximum limit of 200 cards.');
        }

        $card = new Card();
        $card->setName($data->name);
        $card->setBarcodeType($data->barcodeType);
        $card->setBarcodeContent($data->barcodeContent);
        $card->setExpiresAt($data->expiresAt);
        $card->setOwner($user);

        $this->entityManager->persist($card);
        $this->entityManager->flush();

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
