<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\Entity\Card;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Uid\Uuid;

/**
 * Loads a single Card by id for the restore / permanent-delete operations.
 *
 * The global `soft_delete` SQL filter is applied even to a load-by-primary-key,
 * so it must be temporarily disabled to fetch a trashed (soft-deleted) card;
 * its prior state is restored in a finally block. Returning null lets API
 * Platform respond 404 automatically.
 *
 * @implements ProviderInterface<Card>
 */
final class CardTrashItemProvider implements ProviderInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): ?Card
    {
        $id = (string) ($uriVariables['id'] ?? '');

        if (!Uuid::isValid($id)) {
            return null;
        }

        $filters = $this->entityManager->getFilters();
        $wasEnabled = $filters->isEnabled('soft_delete');

        if ($wasEnabled) {
            $filters->disable('soft_delete');
        }

        try {
            return $this->entityManager->find(Card::class, Uuid::fromString($id));
        } finally {
            if ($wasEnabled) {
                $filters->enable('soft_delete');
            }
        }
    }
}
