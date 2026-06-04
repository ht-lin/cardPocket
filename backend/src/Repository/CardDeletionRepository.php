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
