<?php

declare(strict_types=1);

namespace App\Security\Voter;

use App\Entity\Friendship;
use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;

final class FriendshipVoter extends Voter
{
    public const string FRIENDSHIP_ACCEPT = 'FRIENDSHIP_ACCEPT';
    public const string FRIENDSHIP_DELETE = 'FRIENDSHIP_DELETE';

    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, [self::FRIENDSHIP_ACCEPT, self::FRIENDSHIP_DELETE], true)
            && $subject instanceof Friendship;
    }

    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();
        if (!$user instanceof User) {
            return false;
        }
        assert($subject instanceof Friendship);

        return match ($attribute) {
            self::FRIENDSHIP_ACCEPT => $subject->getAddressee()->getId()->equals($user->getId()),
            self::FRIENDSHIP_DELETE => $subject->getRequester()->getId()->equals($user->getId())
                || $subject->getAddressee()->getId()->equals($user->getId()),
            default => false,
        };
    }
}
