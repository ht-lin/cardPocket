<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\Card;
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

    /** @return CardShare[] */
    public function findByCard(Card $card): array
    {
        return $this->createQueryBuilder('cs')
            ->where('cs.card = :card')
            ->setParameter('card', $card)
            ->getQuery()
            ->getResult();
    }

    /** @return CardShare[] */
    public function findSharesBetweenUsers(User $userA, User $userB): array
    {
        return $this->createQueryBuilder('cs')
            ->join('cs.card', 'c')
            ->where(
                '(c.owner = :userA AND cs.viewer = :userB) OR (c.owner = :userB AND cs.viewer = :userA)'
            )
            ->andWhere('c.deletedAt IS NULL')
            ->setParameter('userA', $userA)
            ->setParameter('userB', $userB)
            ->getQuery()
            ->getResult();
    }

    public function findByCardAndViewer(Card $card, User $viewer): ?CardShare
    {
        return $this->createQueryBuilder('cs')
            ->where('cs.card = :card')
            ->andWhere('cs.viewer = :viewer')
            ->setParameter('card', $card)
            ->setParameter('viewer', $viewer)
            ->getQuery()
            ->getOneOrNullResult();
    }

    public function deleteByOwner(User $owner): void
    {
        $this->getEntityManager()->createQuery(
            'DELETE FROM App\Entity\CardShare cs
             WHERE cs.card IN (SELECT c FROM App\Entity\Card c WHERE c.owner = :owner)'
        )->setParameter('owner', $owner)->execute();
    }

    /** @return CardShare[] */
    public function findByOwner(User $owner): array
    {
        return $this->createQueryBuilder('cs')
            ->join('cs.card', 'c')
            ->where('c.owner = :owner')
            ->setParameter('owner', $owner)
            ->getQuery()
            ->getResult();
    }

    /** @return CardShare[] */
    public function findUpdatedSharesSince(User $viewer, \DateTimeImmutable $since): array
    {
        return $this->createQueryBuilder('cs')
            ->join('cs.card', 'c')
            ->where('cs.viewer = :viewer')
            ->andWhere('c.deletedAt IS NULL')
            ->andWhere('c.updatedAt > :since OR cs.updatedAt > :since')
            ->setParameter('viewer', $viewer)
            ->setParameter('since', $since)
            ->getQuery()
            ->getResult();
    }
}
