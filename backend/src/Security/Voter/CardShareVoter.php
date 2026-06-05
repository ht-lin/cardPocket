<?php

declare(strict_types=1);

namespace App\Security\Voter;

use App\Entity\CardShare;
use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;

final class CardShareVoter extends Voter
{
    public const string CARDSHARE_UPDATE = 'CARDSHARE_UPDATE';
    public const string CARDSHARE_DELETE = 'CARDSHARE_DELETE';

    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, [self::CARDSHARE_UPDATE, self::CARDSHARE_DELETE], true)
            && $subject instanceof CardShare;
    }

    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();
        if (!$user instanceof User) {
            return false;
        }
        assert($subject instanceof CardShare);

        return match ($attribute) {
            self::CARDSHARE_UPDATE => $subject->getViewer()->getId()->equals($user->getId()),
            self::CARDSHARE_DELETE => $subject->getCard()->getOwner()->getId()->equals($user->getId())
                || $subject->getViewer()->getId()->equals($user->getId()),
            default => false,
        };
    }
}
