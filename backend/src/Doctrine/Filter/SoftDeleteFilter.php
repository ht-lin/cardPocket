<?php

declare(strict_types=1);

namespace App\Doctrine\Filter;

use Doctrine\ORM\Mapping\ClassMetadata;
use Doctrine\ORM\Query\Filter\SQLFilter;

/**
 * Soft-delete convention (resolves REV-L16):
 *  - This filter is the GLOBAL default — enabled in doctrine.yaml, it excludes
 *    `deleted_at IS NOT NULL` rows from every DQL query (including JOINed entities).
 *  - Repository methods that promise active-only results by name/contract
 *    (e.g. CardRepository::findActiveByOwner) ALSO keep an explicit `deletedAt IS NULL`
 *    clause as defense-in-depth, so they stay correct even if a caller disables this
 *    filter. This is intentional and covered by CardRepositoryTest — do not "DRY it away".
 */
class SoftDeleteFilter extends SQLFilter
{
    public function addFilterConstraint(ClassMetadata $targetEntity, string $targetTableAlias): string
    {
        if (!$targetEntity->hasField('deletedAt')) {
            return '';
        }

        return $targetTableAlias . '.deleted_at IS NULL';
    }
}
