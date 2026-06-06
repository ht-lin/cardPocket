<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\User;
use App\Repository\CardDeletionRepository;
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
        private readonly CardDeletionRepository $cardDeletionRepository,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): null
    {
        $user = $this->security->getUser();
        assert($user instanceof User);

        $userId = (string) $user->getId();

        // GDPR: remove audit log entries that reference this user before anonymizing
        $this->cardDeletionRepository->deleteByUserId($userId);

        foreach ($this->cardShareRepository->findByViewer($user) as $share) {
            $this->entityManager->remove($share);
        }

        $this->cardShareRepository->deleteByOwner($user);

        // GDPR: anonymize card content so no personal data remains in soft-deleted rows
        foreach ($this->cardRepository->findActiveByOwner($user) as $card) {
            $card->setDeletedAt(new \DateTimeImmutable());
            $card->setName('');
            $card->setBarcodeContent('');
        }

        foreach ($this->friendshipRepository->findAllInvolvingUser($user) as $friendship) {
            $this->entityManager->remove($friendship);
        }

        // GDPR: soft-delete and overwrite all identifying fields
        $user->setDeletedAt(new \DateTimeImmutable());
        $user->setEmail("deleted_{$userId}@deleted.invalid");
        $user->setUserName("deleted_{$userId}");
        $user->setPassword('');

        $this->entityManager->flush();

        return null;
    }
}
