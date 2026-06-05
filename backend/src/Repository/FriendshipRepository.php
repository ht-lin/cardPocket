<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\Friendship;
use App\Entity\User;
use App\Enum\FriendshipStatus;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Friendship>
 */
class FriendshipRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Friendship::class);
    }

    /** @return Friendship[] */
    public function findAcceptedByUser(User $user): array
    {
        return $this->createQueryBuilder('f')
            ->where('f.requester = :user OR f.addressee = :user')
            ->andWhere('f.status = :status')
            ->setParameter('user', $user)
            ->setParameter('status', FriendshipStatus::ACCEPTED)
            ->getQuery()
            ->getResult();
    }

    /** @return Friendship[] */
    public function findPendingForAddressee(User $addressee): array
    {
        return $this->createQueryBuilder('f')
            ->where('f.addressee = :addressee')
            ->andWhere('f.status = :status')
            ->setParameter('addressee', $addressee)
            ->setParameter('status', FriendshipStatus::PENDING)
            ->getQuery()
            ->getResult();
    }

    /** @return Friendship[] */
    public function findAllInvolvingUser(User $user): array
    {
        return $this->createQueryBuilder('f')
            ->where('f.requester = :user OR f.addressee = :user')
            ->setParameter('user', $user)
            ->getQuery()
            ->getResult();
    }

    public function findExistingBetweenUsers(User $userA, User $userB): ?Friendship
    {
        return $this->createQueryBuilder('f')
            ->where(
                '(f.requester = :userA AND f.addressee = :userB) OR (f.requester = :userB AND f.addressee = :userA)'
            )
            ->setParameter('userA', $userA)
            ->setParameter('userB', $userB)
            ->setMaxResults(1)
            ->getQuery()
            ->getOneOrNullResult();
    }
}
