<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\Friendship\FriendshipOutput;
use App\Entity\Friendship;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProviderInterface<FriendshipOutput>
 */
final class FriendshipViewProvider implements ProviderInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): FriendshipOutput
    {
        $friendship = $this->entityManager->find(
            Friendship::class,
            Uuid::fromString((string) ($uriVariables['id'] ?? '')),
        );

        if ($friendship === null) {
            throw new NotFoundHttpException();
        }

        return new FriendshipOutput(
            id: (string) $friendship->getId(),
            friend: [],
            status: $friendship->getStatus()->value,
            createdAt: $friendship->getCreatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
