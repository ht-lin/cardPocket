<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\Card;
use App\Entity\User;
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
