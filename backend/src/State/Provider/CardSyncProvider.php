<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\Card\CardSyncOutput;
use App\Entity\User;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;

/**
 * Backs `GET /api/cards/sync?updatedAfter=`. Parses the watermark query
 * parameter and delegates the delta computation to IncrementalSyncProvider.
 *
 * @implements ProviderInterface<CardSyncOutput>
 */
final class CardSyncProvider implements ProviderInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly IncrementalSyncProvider $incrementalSyncProvider,
        private readonly RequestStack $requestStack,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): CardSyncOutput
    {
        /** @var User $user */
        $user = $this->security->getUser();

        $updatedAfterParam = $this->requestStack->getCurrentRequest()?->query->get('updatedAfter');
        if ($updatedAfterParam === null || $updatedAfterParam === '') {
            throw new BadRequestHttpException('Missing required "updatedAfter" query parameter.');
        }

        try {
            $since = new \DateTimeImmutable($updatedAfterParam);
        } catch (\Exception $e) {
            throw new BadRequestHttpException('Invalid "updatedAfter" parameter: expected a valid date/time.', $e);
        }

        return $this->incrementalSyncProvider->provide($user, $since);
    }
}
