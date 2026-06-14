<?php

declare(strict_types=1);

namespace App\Routing;

final class ApiRequirement
{
    /**
     * Loose canonical UUID (36-char hex) — accepts any version nibble (incl. v7)
     * and the nil UUID. Do NOT use Symfony Requirement::UUID: it enforces version
     * [1-5] and would 404 every real (v7) resource id.
     */
    public const string UUID = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}';
}
