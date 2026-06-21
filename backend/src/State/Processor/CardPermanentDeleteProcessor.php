<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\Card;
use App\Entity\User;
use App\Repository\CardShareRepository;
use App\Security\Voter\CardVoter;
use App\Service\CardTombstoneWriter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * DELETE /api/cards/{id}/permanent — physically remove a trashed card (owner only).
 *
 * Writes a CardDeletion tombstone for the owner and for every viewer (so the
 * removal propagates through each viewer's incremental sync `deleted`), drops the
 * associated CardShare rows, then deletes the card itself.
 *
 * @implements ProcessorInterface<mixed, null>
 */
final class CardPermanentDeleteProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
        private readonly CardShareRepository $cardShareRepository,
        private readonly CardTombstoneWriter $cardTombstoneWriter,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): null
    {
        if (!$data instanceof Card) {
            throw new NotFoundHttpException();
        }

        if (!$this->security->isGranted(CardVoter::CARD_DELETE, $data)) {
            throw new AccessDeniedHttpException();
        }

        // Only cards already in the trash can be permanently deleted.
        if ($data->getDeletedAt() === null) {
            throw new NotFoundHttpException();
        }

        $owner = $this->security->getUser();
        assert($owner instanceof User);

        $this->cardTombstoneWriter->writeForOwnerAndViewers($data, (string) $owner->getId());

        $this->cardShareRepository->deleteByCard($data);
        $this->entityManager->remove($data);
        $this->entityManager->flush();

        return null;
    }
}
