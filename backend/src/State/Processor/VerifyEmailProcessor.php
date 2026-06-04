<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use ApiPlatform\Validator\Exception\ValidationException;
use App\ApiResource\Auth\VerifyEmailInput;
use App\ApiResource\Auth\VerifyEmailOutput;
use App\Entity\EmailVerificationToken;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Validator\ConstraintViolation;
use Symfony\Component\Validator\ConstraintViolationList;

/**
 * @implements ProcessorInterface<VerifyEmailInput, VerifyEmailOutput>
 */
final class VerifyEmailProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function process(
        mixed $data,
        Operation $operation,
        array $uriVariables = [],
        array $context = [],
    ): VerifyEmailOutput {
        assert($data instanceof VerifyEmailInput);

        $token = $this->entityManager
            ->getRepository(EmailVerificationToken::class)
            ->findOneBy(['token' => $data->token]);

        $now = new \DateTimeImmutable();

        if ($token === null || $token->getExpiresAt() < $now || $token->getUsedAt() !== null) {
            $violations = new ConstraintViolationList([
                new ConstraintViolation(
                    message: 'Invalid or expired token.',
                    messageTemplate: 'Invalid or expired token.',
                    parameters: [],
                    root: null,
                    propertyPath: 'token',
                    invalidValue: $data->token,
                ),
            ]);
            throw new ValidationException($violations);
        }

        $token->setUsedAt($now);
        $token->getUser()->setEmailVerifiedAt($now);
        $this->entityManager->flush();

        return new VerifyEmailOutput(message: 'Email verified successfully');
    }
}
