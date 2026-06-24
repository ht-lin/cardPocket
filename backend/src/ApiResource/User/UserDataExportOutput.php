<?php

declare(strict_types=1);

namespace App\ApiResource\User;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use App\State\Provider\DataExportProvider;

/**
 * GDPR Art. 20 data portability: a synchronous, machine-readable dump of all
 * personal data the current user owns or is involved in.
 *
 * Each property is an associative array (or list of them) so the export is a
 * single self-describing JSON blob the client can save or share as-is.
 */
#[ApiResource(
    operations: [
        new Get(
            uriTemplate: '/users/me/data-export',
            provider: DataExportProvider::class,
            name: 'api_users_me_data_export',
        ),
    ],
)]
final class UserDataExportOutput
{
    public function __construct(
        /** @var array<string, mixed> */
        public readonly array $profile,
        /** @var list<array<string, mixed>> */
        public readonly array $ownedCards,
        /** @var list<array<string, mixed>> */
        public readonly array $sharedWithMe,
        /** @var list<array<string, mixed>> */
        public readonly array $sharesIGranted,
        /** @var list<array<string, mixed>> */
        public readonly array $friends,
        /** @var list<array<string, mixed>> */
        public readonly array $pendingRequests,
        /** @var list<array<string, mixed>> */
        public readonly array $pushTokens,
    ) {
    }
}
