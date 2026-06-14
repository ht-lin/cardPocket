<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\CardShare\CardShareCreateInput;
use App\ApiResource\CardShare\CardShareOutput;
use App\Entity\Card;
use App\Entity\CardShare;
use App\Entity\User;
use App\Enum\FriendshipStatus;
use App\Repository\CardShareRepository;
use App\Repository\FriendshipRepository;
use Doctrine\DBAL\Exception\UniqueConstraintViolationException;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProcessorInterface<CardShareCreateInput, CardShareOutput>
 */
final class CardShareCreateProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
        private readonly FriendshipRepository $friendshipRepository,
        private readonly CardShareRepository $cardShareRepository,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): CardShareOutput
    {
        assert($data instanceof CardShareCreateInput);

        $me = $this->security->getUser();
        assert($me instanceof User);

        $card = $this->entityManager->find(
            Card::class,
            Uuid::fromString((string) ($uriVariables['cardId'] ?? '')),
        );

        if ($card === null || $card->getDeletedAt() !== null) {
            throw new NotFoundHttpException();
        }

        if (!$card->getOwner()->getId()->equals($me->getId())) {
            throw new AccessDeniedHttpException();
        }

        $viewerUuid = Uuid::fromString($data->viewerId);
        $viewer     = $this->entityManager->find(User::class, $viewerUuid);

        if ($viewer === null) {
            throw new UnprocessableEntityHttpException('Target user not found.');
        }

        $friendship = $this->friendshipRepository->findExistingBetweenUsers($me, $viewer);

        if ($friendship === null || $friendship->getStatus() !== FriendshipStatus::ACCEPTED) {
            throw new AccessDeniedHttpException('You must be friends to share a card.');
        }

        if ($this->cardShareRepository->findByCardAndViewer($card, $viewer) !== null) {
            throw new UnprocessableEntityHttpException('Card is already shared with this user.');
        }

        $share = new CardShare();
        $share->setCard($card);
        $share->setViewer($viewer);

        $this->entityManager->persist($share);

        try {
            $this->entityManager->flush();
        } catch (UniqueConstraintViolationException $e) {
            throw new UnprocessableEntityHttpException('Card is already shared with this user.', $e);
        }

        return new CardShareOutput(
            id: (string) $share->getId(),
            viewer: [
                'id'       => (string) $viewer->getId(),
                'userName' => $viewer->getUserName(),
            ],
            viewerNickname: null,
            createdAt: $share->getCreatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
