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
        return $this->findBy(['owner' => $owner]);
    }

    public function countActiveByOwner(User $owner): int
    {
        return $this->count(['owner' => $owner]);
    }
}
