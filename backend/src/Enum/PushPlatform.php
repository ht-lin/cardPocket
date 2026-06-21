<?php

declare(strict_types=1);

namespace App\Enum;

enum PushPlatform: string
{
    case ANDROID = 'ANDROID';
    case IOS     = 'IOS';

    /** @return list<string> */
    public static function values(): array
    {
        return array_map(static fn (self $case): string => $case->value, self::cases());
    }
}
