<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\User;
use App\Repository\CardRepository;
use App\Repository\CardShareRepository;
use App\Repository\FriendshipRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;

/**
 * @implements ProcessorInterface<mixed, null>
 */
final class DeleteAccountProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
        private readonly CardRepository $cardRepository,
        private readonly CardShareRepository $cardShareRepository,
        private readonly FriendshipRepository $friendshipRepository,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): null
    {
        $user = $this->security->getUser();
        assert($user instanceof User);

        foreach ($this->cardShareRepository->findByViewer($user) as $share) {
            $this->entityManager->remove($share);
        }

        foreach ($this->cardRepository->findActiveByOwner($user) as $card) {
            foreach ($this->cardShareRepository->findByCard($card) as $share) {
                $this->entityManager->remove($share);
            }
            $card->setDeletedAt(new \DateTimeImmutable());
        }

        foreach ($this->friendshipRepository->findAllInvolvingUser($user) as $friendship) {
            $this->entityManager->remove($friendship);
        }

        $user->setDeletedAt(new \DateTimeImmutable());
        $this->entityManager->flush();

        return null;
    }
}
