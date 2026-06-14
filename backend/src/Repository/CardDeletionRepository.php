<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\CardDeletion;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<CardDeletion>
 */
class CardDeletionRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, CardDeletion::class);
    }

    public function deleteByUserId(string $userId): void
    {
        $this->createQueryBuilder('cd')
            ->delete()
            ->where('cd.userId = :userId')
            ->setParameter('userId', $userId)
            ->getQuery()
            ->execute();
    }

    /**
     * Prune tombstones older than the retention cutoff. Clients that sync less often than the
     * retention window must fall back to a full sync (see architecture.md).
     */
    public function deleteOlderThan(\DateTimeImmutable $cutoff): int
    {
        return (int) $this->createQueryBuilder('cd')
            ->delete()
            ->where('cd.createdAt < :cutoff')
            ->setParameter('cutoff', $cutoff)
            ->getQuery()
            ->execute();
    }

    /** @return string[] */
    public function findCardIdsByUserSince(string $userId, \DateTimeImmutable $since): array
    {
        $rows = $this->createQueryBuilder('cd')
            ->select('cd.cardId')
            ->where('cd.userId = :userId')
            ->andWhere('cd.createdAt > :since')
            ->setParameter('userId', $userId)
            ->setParameter('since', $since)
            ->getQuery()
            ->getScalarResult();

        return array_column($rows, 'cardId');
    }
}
