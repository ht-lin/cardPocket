<?php

declare(strict_types=1);

namespace App\State\Provider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\ApiResource\User\UserDataExportOutput;
use App\Entity\Card;
use App\Entity\CardShare;
use App\Entity\Friendship;
use App\Entity\PushToken;
use App\Entity\User;
use App\Repository\CardRepository;
use App\Repository\CardShareRepository;
use App\Repository\FriendshipRepository;
use App\Repository\PushTokenRepository;
use Symfony\Bundle\SecurityBundle\Security;

/**
 * @implements ProviderInterface<UserDataExportOutput>
 */
final class DataExportProvider implements ProviderInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly CardRepository $cardRepository,
        private readonly CardShareRepository $cardShareRepository,
        private readonly FriendshipRepository $friendshipRepository,
        private readonly PushTokenRepository $pushTokenRepository,
    ) {
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): UserDataExportOutput
    {
        $user = $this->security->getUser();
        assert($user instanceof User);

        // Owned cards include trashed (soft-deleted) ones — GDPR export must be complete.
        // findTrashedByOwner temporarily disables the SoftDeleteFilter (see CardRepository).
        $ownedCards = array_merge(
            $this->cardRepository->findActiveByOwner($user),
            $this->cardRepository->findTrashedByOwner($user),
        );

        return new UserDataExportOutput(
            profile: [
                'id' => (string) $user->getId(),
                'email' => $user->getEmail(),
                'userName' => $user->getUserName(),
                'emailVerified' => $user->getEmailVerifiedAt() !== null,
                'discoverable' => $user->isDiscoverable(),
                'expiryPolicy' => $user->getExpiryPolicy()->value,
                'createdAt' => $user->getCreatedAt()->format(\DateTimeInterface::ATOM),
                'gdprConsentAt' => $user->getGdprConsentAt()?->format(\DateTimeInterface::ATOM),
            ],
            ownedCards: array_map($this->mapOwnedCard(...), $ownedCards),
            sharedWithMe: array_map(
                $this->mapSharedWithMe(...),
                $this->cardShareRepository->findByViewer($user),
            ),
            sharesIGranted: array_map(
                $this->mapShareGranted(...),
                $this->cardShareRepository->findByOwner($user),
            ),
            friends: array_map(
                fn (Friendship $f) => $this->mapFriendship($f, $user),
                $this->friendshipRepository->findAcceptedByUser($user),
            ),
            pendingRequests: array_map(
                fn (Friendship $f) => $this->mapFriendship($f, $user),
                $this->friendshipRepository->findPendingForAddressee($user),
            ),
            pushTokens: array_map(
                $this->mapPushToken(...),
                $this->pushTokenRepository->findActiveByUser($user),
            ),
        );
    }

    /**
     * @return array<string, mixed>
     */
    private function mapOwnedCard(Card $card): array
    {
        return [
            'id' => (string) $card->getId(),
            'name' => $card->getName(),
            'barcodeType' => $card->getBarcodeType()->value,
            'barcodeContent' => $card->getBarcodeContent(),
            'color' => $card->getColor(),
            'expiresAt' => $card->getExpiresAt()?->format(\DateTimeInterface::ATOM),
            'createdAt' => $card->getCreatedAt()->format(\DateTimeInterface::ATOM),
            'deletedAt' => $card->getDeletedAt()?->format(\DateTimeInterface::ATOM),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function mapSharedWithMe(CardShare $share): array
    {
        $card = $share->getCard();

        return [
            'cardId' => (string) $card->getId(),
            'name' => $card->getName(),
            'barcodeType' => $card->getBarcodeType()->value,
            'barcodeContent' => $card->getBarcodeContent(),
            'ownerUsername' => $card->getOwner()->getUserName(),
            'viewerNickname' => $share->getViewerNickname(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function mapShareGranted(CardShare $share): array
    {
        return [
            'cardId' => (string) $share->getCard()->getId(),
            'cardName' => $share->getCard()->getName(),
            'viewerUsername' => $share->getViewer()->getUserName(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function mapFriendship(Friendship $friendship, User $self): array
    {
        $other = $friendship->getRequester()->getId()->equals($self->getId())
            ? $friendship->getAddressee()
            : $friendship->getRequester();

        return [
            'userName' => $other->getUserName(),
            'status' => $friendship->getStatus()->value,
            'createdAt' => $friendship->getCreatedAt()->format(\DateTimeInterface::ATOM),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function mapPushToken(PushToken $token): array
    {
        return [
            'platform' => $token->getPlatform()->value,
            'isActive' => $token->isActive(),
        ];
    }
}
