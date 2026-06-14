<?php

declare(strict_types=1);

namespace App\Message;

/**
 * Triggers periodic pruning of expired/stale data. Dispatched by CleanupSchedule.
 */
final class CleanupExpiredDataMessage
{
}
