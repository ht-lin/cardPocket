<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\Auth\ResendVerificationInput;
use App\Entity\User;
use App\Service\EmailVerificationService;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpKernel\Exception\TooManyRequestsHttpException;
use Symfony\Component\RateLimiter\RateLimiterFactory;

/**
 * @implements ProcessorInterface<ResendVerificationInput, null>
 */
final class ResendVerificationProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly EmailVerificationService $emailVerificationService,
        #[Autowire(service: 'limiter.resend_verification_by_user')]
        private readonly RateLimiterFactory $resendLimiter,
    ) {
    }

    public function process(
        mixed $data,
        Operation $operation,
        array $uriVariables = [],
        array $context = [],
    ): null {
        assert($data instanceof ResendVerificationInput);

        if (!$this->resendLimiter->create($data->email)->consume()->isAccepted()) {
            throw new TooManyRequestsHttpException();
        }

        $user = $this->entityManager
            ->getRepository(User::class)
            ->findOneBy(['email' => $data->email]);

        // Return 200 regardless — do not reveal whether the email is registered
        if ($user === null || $user->getEmailVerifiedAt() !== null) {
            return null;
        }

        $this->emailVerificationService->sendVerification($user);

        return null;
    }
}
