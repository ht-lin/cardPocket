<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\Friendship\FriendshipOutput;
use App\Entity\Friendship;
use App\Entity\User;
use App\Enum\FriendshipStatus;
use App\Security\Voter\FriendshipVoter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProcessorInterface<mixed, FriendshipOutput>
 */
final class FriendAcceptProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): FriendshipOutput
    {
        $me = $this->security->getUser();
        assert($me instanceof User);

        $friendship = $this->entityManager->find(
            Friendship::class,
            Uuid::fromString((string) ($uriVariables['id'] ?? '')),
        );

        if ($friendship === null) {
            throw new NotFoundHttpException();
        }

        if (!$this->security->isGranted(FriendshipVoter::FRIENDSHIP_ACCEPT, $friendship)) {
            throw new AccessDeniedHttpException();
        }

        $friendship->setStatus(FriendshipStatus::ACCEPTED);
        $this->entityManager->flush();

        $friend = $friendship->getRequester()->getId()->equals($me->getId())
            ? $friendship->getAddressee()
            : $friendship->getRequester();

        return new FriendshipOutput(
            id: (string) $friendship->getId(),
            friend: [
                'id'       => (string) $friend->getId(),
                'userName' => $friend->getUserName(),
            ],
            status: $friendship->getStatus()->value,
            createdAt: $friendship->getCreatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
