<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\Friendship\FriendRequestOutput;
use App\Entity\User;
use App\Repository\FriendshipRepository;
use Symfony\Bundle\SecurityBundle\Security;

/**
 * @implements ProviderInterface<FriendRequestOutput>
 */
final class FriendRequestListProvider implements ProviderInterface
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

        $requests = $this->friendshipRepository->findPendingForAddressee($me);

        return array_map(fn ($friendship) => new FriendRequestOutput(
            id: (string) $friendship->getId(),
            requester: [
                'id'       => (string) $friendship->getRequester()->getId(),
                'userName' => $friendship->getRequester()->getUserName(),
            ],
            status: $friendship->getStatus()->value,
            createdAt: $friendship->getCreatedAt()->format(\DateTimeInterface::ATOM),
        ), $requests);
    }
}
