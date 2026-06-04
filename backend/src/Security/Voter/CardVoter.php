<?php

declare(strict_types=1);

namespace App\Security\Voter;

use App\Entity\Card;
use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;

final class CardVoter extends Voter
{
    public const string CARD_VIEW   = 'CARD_VIEW';
    public const string CARD_EDIT   = 'CARD_EDIT';
    public const string CARD_DELETE = 'CARD_DELETE';

    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, [self::CARD_VIEW, self::CARD_EDIT, self::CARD_DELETE], true)
            && $subject instanceof Card;
    }

    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();
        if (!$user instanceof User) {
            return false;
        }
        assert($subject instanceof Card);

        return match ($attribute) {
            // Phase 2: CARD_VIEW will also check CardShare table for shared viewers
            self::CARD_VIEW,
            self::CARD_EDIT,
            self::CARD_DELETE => $subject->getOwner()->getId()->equals($user->getId()),
            default => false,
        };
    }
}
