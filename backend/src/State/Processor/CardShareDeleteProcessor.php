<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\CardShare\CardShareOutput;
use App\Entity\CardShare;
use App\Entity\User;
use App\Security\Voter\CardShareVoter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProcessorInterface<mixed, null>
 */
final class CardShareDeleteProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): null
    {
        $me = $this->security->getUser();
        assert($me instanceof User);

        $share = $this->entityManager->find(
            CardShare::class,
            Uuid::fromString((string) ($uriVariables['id'] ?? '')),
        );

        if ($share === null) {
            throw new NotFoundHttpException();
        }

        if (!$this->security->isGranted(CardShareVoter::CARDSHARE_DELETE, $share)) {
            throw new AccessDeniedHttpException();
        }

        $this->entityManager->remove($share);
        $this->entityManager->flush();

        return null;
    }
}
