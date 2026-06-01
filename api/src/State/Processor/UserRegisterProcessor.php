<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\User\UserRegisterInput;
use App\ApiResource\User\UserRegisterOutput;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

/**
 * @implements ProcessorInterface<UserRegisterInput, UserRegisterOutput>
 */
final class UserRegisterProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly UserPasswordHasherInterface $passwordHasher,
    ) {
    }

    public function process(
        mixed $data,
        Operation $operation,
        array $uriVariables = [],
        array $context = [],
    ): UserRegisterOutput {
        assert($data instanceof UserRegisterInput);

        $user = new User();
        $user->setEmail($data->email);
        $user->setUserName($data->userName);
        $user->setGdprConsentAt(new \DateTimeImmutable());

        $hashedPassword = $this->passwordHasher->hashPassword($user, $data->password);
        $user->setPassword($hashedPassword);

        $this->entityManager->persist($user);
        $this->entityManager->flush();

        return new UserRegisterOutput(
            id: (string) $user->getId(),
            email: $user->getEmail(),
            userName: $user->getUserName(),
            emailVerified: $user->getEmailVerifiedAt() !== null,
            createdAt: $user->getCreatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
