<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\User\UserOutput;
use App\ApiResource\User\UserUpdateInput;
use App\Entity\User;
use Doctrine\DBAL\Exception\UniqueConstraintViolationException;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

/**
 * @implements ProcessorInterface<UserUpdateInput, UserOutput>
 */
final class UserUpdateProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
        private readonly UserPasswordHasherInterface $passwordHasher,
    ) {
    }

    public function process(
        mixed $data,
        Operation $operation,
        array $uriVariables = [],
        array $context = [],
    ): UserOutput {
        assert($data instanceof UserUpdateInput);

        $user = $this->security->getUser();
        assert($user instanceof User);

        if ($data->newPassword !== null) {
            if (!$this->passwordHasher->isPasswordValid($user, (string) $data->currentPassword)) {
                throw new UnprocessableEntityHttpException('Current password is incorrect.');
            }
            $user->setPassword($this->passwordHasher->hashPassword($user, $data->newPassword));

            // Revoke all refresh tokens so a changed password cannot be undone by a stolen,
            // still-valid (30-day) refresh token. The username column stores the user's email.
            $this->entityManager->createQuery(
                'DELETE FROM App\Entity\RefreshToken rt WHERE rt.username = :username'
            )->setParameter('username', $user->getUserIdentifier())->execute();
        }

        if ($data->userName !== null) {
            $existing = $this->entityManager->getRepository(User::class)
                ->findOneBy(['userName' => $data->userName]);
            if ($existing !== null && !$existing->getId()->equals($user->getId())) {
                throw new UnprocessableEntityHttpException('This username is already taken.');
            }
            $user->setUserName($data->userName);
        }

        try {
            $this->entityManager->flush();
        } catch (UniqueConstraintViolationException $e) {
            // DB unique index backstops the find-then-update check above against races.
            throw new UnprocessableEntityHttpException('This username is already taken.', $e);
        }

        return new UserOutput(
            id: (string) $user->getId(),
            email: $user->getEmail(),
            userName: $user->getUserName(),
            emailVerified: $user->getEmailVerifiedAt() !== null,
            createdAt: $user->getCreatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
