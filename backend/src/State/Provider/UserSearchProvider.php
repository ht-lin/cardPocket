<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\User\UserSearchOutput;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

/**
 * @implements ProviderInterface<UserSearchOutput>
 */
final class UserSearchProvider implements ProviderInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): array
    {
        $user = $this->security->getUser();
        assert($user instanceof User);

        if ($user->getEmailVerifiedAt() === null) {
            throw new AccessDeniedHttpException();
        }

        $q = $context['filters']['q'] ?? '';
        if ($q === '') {
            return [];
        }

        $repo = $this->entityManager->getRepository(User::class);
        $found = $repo->findOneBy(['userName' => $q])
            ?? $repo->findOneBy(['email' => $q]);

        // A user who opted out of discovery is treated as not found, so neither
        // an exact userName nor email match can confirm the account exists.
        if ($found === null || !$found->isDiscoverable()) {
            return [];
        }

        return [new UserSearchOutput(
            id: (string) $found->getId(),
            userName: $found->getUserName(),
        )];
    }
}
