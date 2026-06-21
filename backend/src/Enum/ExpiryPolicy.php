<?php

declare(strict_types=1);

namespace App\Enum;

enum ExpiryPolicy: string
{
    case KEEP       = 'KEEP';
    case AUTO_TRASH = 'AUTO_TRASH';
}
