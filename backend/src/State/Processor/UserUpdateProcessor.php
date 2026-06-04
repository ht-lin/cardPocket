<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\User\UserOutput;
use App\ApiResource\User\UserUpdateInput;
use App\Entity\User;
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
        }

        if ($data->userName !== null) {
            $existing = $this->entityManager->getRepository(User::class)
                ->findOneBy(['userName' => $data->userName]);
            if ($existing !== null && $existing->getId() !== $user->getId()) {
                throw new UnprocessableEntityHttpException('This username is already taken.');
            }
            $user->setUserName($data->userName);
        }

        $this->entityManager->flush();

        return new UserOutput(
            id: (string) $user->getId(),
            email: $user->getEmail(),
            userName: $user->getUserName(),
            emailVerified: $user->getEmailVerifiedAt() !== null,
            createdAt: $user->getCreatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
