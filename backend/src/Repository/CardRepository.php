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
}
