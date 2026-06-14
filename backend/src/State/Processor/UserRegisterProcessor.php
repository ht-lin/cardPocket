<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\User\UserRegisterInput;
use App\ApiResource\User\UserRegisterOutput;
use App\Entity\User;
use App\Service\EmailVerificationService;
use Doctrine\DBAL\Exception\UniqueConstraintViolationException;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\HttpKernel\Exception\TooManyRequestsHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\RateLimiter\RateLimiterFactory;

/**
 * @implements ProcessorInterface<UserRegisterInput, UserRegisterOutput>
 */
final class UserRegisterProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly UserPasswordHasherInterface $passwordHasher,
        private readonly EmailVerificationService $emailVerificationService,
        private readonly RequestStack $requestStack,
        #[Autowire(service: 'limiter.register_by_ip')]
        private readonly RateLimiterFactory $registerByIpLimiter,
    ) {
    }

    public function process(
        mixed $data,
        Operation $operation,
        array $uriVariables = [],
        array $context = [],
    ): UserRegisterOutput {
        assert($data instanceof UserRegisterInput);

        $ip = $this->requestStack->getCurrentRequest()?->getClientIp() ?? '127.0.0.1';
        if (!$this->registerByIpLimiter->create($ip)->consume()->isAccepted()) {
            throw new TooManyRequestsHttpException();
        }

        // Uniqueness of email/userName is enforced declaratively by #[UniqueEntity] on
        // UserRegisterInput (validated before this processor). The DB unique indexes are the
        // race-condition backstop: two concurrent registrations can both pass validation, so
        // catch the violation here instead of surfacing a 500.
        $user = new User();
        $user->setEmail($data->email);
        $user->setUserName($data->userName);
        $user->setGdprConsentAt(new \DateTimeImmutable());

        $hashedPassword = $this->passwordHasher->hashPassword($user, $data->password);
        $user->setPassword($hashedPassword);

        $this->entityManager->persist($user);

        try {
            $this->entityManager->flush();
        } catch (UniqueConstraintViolationException $e) {
            throw new UnprocessableEntityHttpException('Email or username is already taken.', $e);
        }

        $this->emailVerificationService->sendVerification($user);

        return new UserRegisterOutput(
            id: (string) $user->getId(),
            email: $user->getEmail(),
            userName: $user->getUserName(),
            emailVerified: $user->getEmailVerifiedAt() !== null,
            createdAt: $user->getCreatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
