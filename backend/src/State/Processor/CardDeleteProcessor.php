<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\Card;
use App\Entity\User;
use App\Security\Voter\CardVoter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProcessorInterface<mixed, null>
 */
final class CardDeleteProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): null
    {
        $user = $this->security->getUser();
        assert($user instanceof User);

        $card = $this->entityManager->find(Card::class, Uuid::fromString((string) ($uriVariables['id'] ?? '')));

        if ($card === null) {
            throw new NotFoundHttpException();
        }

        if (!$this->security->isGranted(CardVoter::CARD_DELETE, $card)) {
            throw new AccessDeniedHttpException();
        }

        $card->setDeletedAt(new \DateTimeImmutable());
        $this->entityManager->flush();

        return null;
    }
}
