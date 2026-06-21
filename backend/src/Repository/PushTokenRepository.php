<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\PushToken;
use App\Entity\User;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<PushToken>
 */
class PushTokenRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, PushToken::class);
    }

    public function findOneByFcmToken(string $fcmToken): ?PushToken
    {
        return $this->findOneBy(['fcmToken' => $fcmToken]);
    }

    /** @return PushToken[] */
    public function findActiveByUser(User $user): array
    {
        return $this->createQueryBuilder('pt')
            ->where('pt.user = :user')
            ->andWhere('pt.isActive = true')
            ->setParameter('user', $user)
            ->getQuery()
            ->getResult();
    }

    public function deleteByUser(User $user): void
    {
        $this->getEntityManager()->createQuery(
            'DELETE FROM App\Entity\PushToken pt WHERE pt.user = :user'
        )->setParameter('user', $user)->execute();
    }
}
