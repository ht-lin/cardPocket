<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\Friendship\FriendshipOutput;
use App\Entity\User;
use App\Repository\FriendshipRepository;
use Symfony\Bundle\SecurityBundle\Security;

/**
 * @implements ProviderInterface<FriendshipOutput>
 */
final class FriendshipListProvider implements ProviderInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly FriendshipRepository $friendshipRepository,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): array
    {
        $me = $this->security->getUser();
        assert($me instanceof User);

        $friendships = $this->friendshipRepository->findAcceptedByUser($me);

        return array_map(function ($friendship) use ($me) {
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
        }, $friendships);
    }
}
