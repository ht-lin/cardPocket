<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\Friendship;
use App\Entity\User;
use App\Enum\FriendshipStatus;
use App\Repository\CardShareRepository;
use App\Security\Voter\FriendshipVoter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProcessorInterface<mixed, null>
 */
final class FriendDeleteProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
        private readonly CardShareRepository $cardShareRepository,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): null
    {
        $me = $this->security->getUser();
        assert($me instanceof User);

        $friendship = $this->entityManager->find(
            Friendship::class,
            Uuid::fromString((string) ($uriVariables['id'] ?? '')),
        );

        if ($friendship === null) {
            throw new NotFoundHttpException();
        }

        if (!$this->security->isGranted(FriendshipVoter::FRIENDSHIP_DELETE, $friendship)) {
            throw new AccessDeniedHttpException();
        }

        if ($friendship->getStatus() === FriendshipStatus::ACCEPTED) {
            $shares = $this->cardShareRepository->findSharesBetweenUsers(
                $friendship->getRequester(),
                $friendship->getAddressee(),
            );
            foreach ($shares as $share) {
                $this->entityManager->remove($share);
            }
        }

        $this->entityManager->remove($friendship);
        $this->entityManager->flush();

        return null;
    }
}
