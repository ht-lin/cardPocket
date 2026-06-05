<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\CardShare\CardShareOutput;
use App\ApiResource\CardShare\CardShareUpdateInput;
use App\Entity\CardShare;
use App\Entity\User;
use App\Security\Voter\CardShareVoter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProcessorInterface<CardShareUpdateInput, CardShareOutput>
 */
final class CardShareUpdateProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): CardShareOutput
    {
        assert($data instanceof CardShareUpdateInput);

        $me = $this->security->getUser();
        assert($me instanceof User);

        $share = $this->entityManager->find(
            CardShare::class,
            Uuid::fromString((string) ($uriVariables['id'] ?? '')),
        );

        if ($share === null) {
            throw new NotFoundHttpException();
        }

        if (!$this->security->isGranted(CardShareVoter::CARDSHARE_UPDATE, $share)) {
            throw new AccessDeniedHttpException();
        }

        $share->setViewerNickname($data->viewerNickname);
        $this->entityManager->flush();

        return new CardShareOutput(
            id: (string) $share->getId(),
            viewer: [
                'id'       => (string) $share->getViewer()->getId(),
                'userName' => $share->getViewer()->getUserName(),
            ],
            viewerNickname: $share->getViewerNickname(),
            createdAt: $share->getCreatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
