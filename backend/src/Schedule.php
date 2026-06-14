<?php

declare(strict_types=1);

namespace App;

use App\Message\CleanupExpiredDataMessage;
use Symfony\Component\Scheduler\Attribute\AsSchedule;
use Symfony\Component\Scheduler\RecurringMessage;
use Symfony\Component\Scheduler\Schedule as SymfonySchedule;
use Symfony\Component\Scheduler\ScheduleProviderInterface;
use Symfony\Contracts\Cache\CacheInterface;

/**
 * Application schedule. Requires a running worker:
 *   bin/console messenger:consume scheduler_default
 */
#[AsSchedule]
final class Schedule implements ScheduleProviderInterface
{
    public function __construct(
        private readonly CacheInterface $cache,
    ) {
    }

    public function getSchedule(): SymfonySchedule
    {
        return (new SymfonySchedule())
            ->stateful($this->cache) // ensure missed tasks are executed
            ->processOnlyLastMissedRun(true) // ensure only last missed task is run
            ->add(
                // Daily data-retention pruning (L13): expired verification/refresh tokens
                // and card-deletion tombstones older than the retention window.
                RecurringMessage::every('1 day', new CleanupExpiredDataMessage()),
            );
    }
}
