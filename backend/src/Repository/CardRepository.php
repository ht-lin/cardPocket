<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\Card;
use App\Entity\User;
use App\Enum\ExpiryPolicy;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Card>
 */
class CardRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Card::class);
    }

    /** @return Card[] */
    public function findActiveByOwner(User $owner): array
    {
        return $this->createQueryBuilder('c')
            ->where('c.owner = :owner')
            ->andWhere('c.deletedAt IS NULL')
            ->setParameter('owner', $owner)
            ->getQuery()
            ->getResult();
    }

    /** @return Card[] */
    public function searchByOwner(User $owner, string $q): array
    {
        return $this->createQueryBuilder('c')
            ->where('c.owner = :owner')
            ->andWhere('c.deletedAt IS NULL')
            ->andWhere("LOWER(c.name) LIKE :pattern ESCAPE '\\'")
            ->setParameter('owner', $owner)
            ->setParameter('pattern', self::buildLikePattern($q))
            ->getQuery()
            ->getResult();
    }

    public function countActiveByOwner(User $owner): int
    {
        return (int) $this->createQueryBuilder('c')
            ->select('COUNT(c.id)')
            ->where('c.owner = :owner')
            ->andWhere('c.deletedAt IS NULL')
            ->setParameter('owner', $owner)
            ->getQuery()
            ->getSingleScalarResult();
    }

    /**
     * Cards in the owner's trash (soft-deleted, not yet physically purged).
     *
     * The global `soft_delete` filter forces `deleted_at IS NULL` on every DQL
     * query, which would make a trash listing impossible. We temporarily disable
     * it and add the explicit inverse condition `deletedAt IS NOT NULL` (per the
     * REV-L16 convention: global filter as default, named methods carry their own
     * explicit clause), restoring the filter's prior state in a finally block.
     *
     * @return Card[]
     */
    public function findTrashedByOwner(User $owner): array
    {
        $filters = $this->getEntityManager()->getFilters();
        $wasEnabled = $filters->isEnabled('soft_delete');

        if ($wasEnabled) {
            $filters->disable('soft_delete');
        }

        try {
            return $this->createQueryBuilder('c')
                ->where('c.owner = :owner')
                ->andWhere('c.deletedAt IS NOT NULL')
                ->orderBy('c.deletedAt', 'DESC')
                ->setParameter('owner', $owner)
                ->getQuery()
                ->getResult();
        } finally {
            if ($wasEnabled) {
                $filters->enable('soft_delete');
            }
        }
    }

    /**
     * Active (not yet trashed) cards that have expired and whose owner opted into the
     * AUTO_TRASH expiry policy. Used by the scheduled cleanup to auto-trash expired cards.
     *
     * Carries the explicit `deletedAt IS NULL` clause (REV-L16: named methods do not rely
     * on the implicit global `soft_delete` filter).
     *
     * @return Card[]
     */
    public function findExpiredForAutoTrash(\DateTimeImmutable $now): array
    {
        return $this->createQueryBuilder('c')
            ->join('c.owner', 'o')
            ->where('o.expiryPolicy = :policy')
            ->andWhere('c.expiresAt IS NOT NULL')
            ->andWhere('c.expiresAt < :now')
            ->andWhere('c.deletedAt IS NULL')
            ->setParameter('policy', ExpiryPolicy::AUTO_TRASH)
            ->setParameter('now', $now)
            ->getQuery()
            ->getResult();
    }

    /**
     * Soft-deleted cards whose trash retention window has elapsed, ready to be physically
     * purged. Temporarily disables the global `soft_delete` filter (which would otherwise
     * force `deleted_at IS NULL` and hide every trashed row), mirroring findTrashedByOwner.
     *
     * @return Card[]
     */
    public function findPurgeable(\DateTimeImmutable $cutoff): array
    {
        $filters = $this->getEntityManager()->getFilters();
        $wasEnabled = $filters->isEnabled('soft_delete');

        if ($wasEnabled) {
            $filters->disable('soft_delete');
        }

        try {
            return $this->createQueryBuilder('c')
                ->where('c.deletedAt IS NOT NULL')
                ->andWhere('c.deletedAt < :cutoff')
                ->setParameter('cutoff', $cutoff)
                ->getQuery()
                ->getResult();
        } finally {
            if ($wasEnabled) {
                $filters->enable('soft_delete');
            }
        }
    }

    /** @return Card[] */
    public function findUpdatedByOwnerSince(User $owner, \DateTimeImmutable $since): array
    {
        return $this->createQueryBuilder('c')
            ->where('c.owner = :owner')
            ->andWhere('c.updatedAt > :since')
            ->setParameter('owner', $owner)
            ->setParameter('since', $since)
            ->getQuery()
            ->getResult();
    }

    /**
     * Build a case-insensitive substring LIKE pattern, escaping the user input so
     * `%`, `_` and `\` are matched literally rather than as SQL wildcards.
     */
    private static function buildLikePattern(string $q): string
    {
        return '%' . addcslashes(mb_strtolower($q), '%_\\') . '%';
    }
}
