<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\CardShare\CardShareOutput;
use App\Entity\Card;
use App\Entity\User;
use App\Repository\CardShareRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProviderInterface<CardShareOutput>
 */
final class CardShareListProvider implements ProviderInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
        private readonly CardShareRepository $cardShareRepository,
    ) {
    }

    /** @return CardShareOutput[] */
    public function provide(Operation $operation, array $uriVariables = [], array $context = []): array
    {
        $me = $this->security->getUser();
        assert($me instanceof User);

        $card = $this->entityManager->find(
            Card::class,
            Uuid::fromString((string) ($uriVariables['cardId'] ?? '')),
        );

        if ($card === null || $card->getDeletedAt() !== null) {
            throw new NotFoundHttpException();
        }

        if (!$card->getOwner()->getId()->equals($me->getId())) {
            throw new AccessDeniedHttpException();
        }

        $shares = $this->cardShareRepository->findByCard($card);

        return array_map(
            static fn ($share) => new CardShareOutput(
                id: (string) $share->getId(),
                viewer: [
                    'id'       => (string) $share->getViewer()->getId(),
                    'userName' => $share->getViewer()->getUserName(),
                ],
                viewerNickname: null,
                createdAt: $share->getCreatedAt()->format(\DateTimeInterface::ATOM),
            ),
            $shares,
        );
    }
}
