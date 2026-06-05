<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\CardShare\CardShareOutput;
use App\Entity\CardShare;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProviderInterface<CardShareOutput>
 */
final class CardShareViewProvider implements ProviderInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): CardShareOutput
    {
        $share = $this->entityManager->find(
            CardShare::class,
            Uuid::fromString((string) ($uriVariables['id'] ?? '')),
        );

        if ($share === null) {
            throw new NotFoundHttpException();
        }

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
