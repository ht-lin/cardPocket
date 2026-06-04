<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\CardShare;
use App\Entity\User;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<CardShare>
 */
class CardShareRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, CardShare::class);
    }

    /** @return CardShare[] */
    public function findByViewer(User $viewer): array
    {
        return $this->createQueryBuilder('cs')
            ->join('cs.card', 'c')
            ->where('cs.viewer = :viewer')
            ->andWhere('c.deletedAt IS NULL')
            ->setParameter('viewer', $viewer)
            ->getQuery()
            ->getResult();
    }
}
