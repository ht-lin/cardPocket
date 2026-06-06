<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\User\UserRegisterInput;
use App\ApiResource\User\UserRegisterOutput;
use App\Entity\User;
use App\Service\EmailVerificationService;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpFoundation\RequestStack;
use ApiPlatform\Validator\Exception\ValidationException;
use Symfony\Component\HttpKernel\Exception\TooManyRequestsHttpException;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\RateLimiter\RateLimiterFactory;
use Symfony\Component\Validator\ConstraintViolation;
use Symfony\Component\Validator\ConstraintViolationList;

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

        $violations = new ConstraintViolationList();

        if ($this->entityManager->getRepository(User::class)->findOneBy(['email' => $data->email]) !== null) {
            $violations->add(new ConstraintViolation('This email is already registered.', null, [], $data, 'email', $data->email));
        }

        if ($this->entityManager->getRepository(User::class)->findOneBy(['userName' => $data->userName]) !== null) {
            $violations->add(new ConstraintViolation('This username is already taken.', null, [], $data, 'userName', $data->userName));
        }

        if (count($violations) > 0) {
            throw new ValidationException($violations);
        }

        $user = new User();
        $user->setEmail($data->email);
        $user->setUserName($data->userName);
        $user->setGdprConsentAt(new \DateTimeImmutable());

        $hashedPassword = $this->passwordHasher->hashPassword($user, $data->password);
        $user->setPassword($hashedPassword);

        $this->entityManager->persist($user);
        $this->entityManager->flush();

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
