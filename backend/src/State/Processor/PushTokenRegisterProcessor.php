<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\Auth\PushTokenInput;
use App\Entity\PushToken;
use App\Entity\User;
use App\Enum\PushPlatform;
use App\Repository\PushTokenRepository;
use Doctrine\DBAL\Exception\UniqueConstraintViolationException;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;

/**
 * Registers (upserts) a device's FCM token for the authenticated user. Keyed by fcmToken so a
 * device that changes hands re-points to the new owner; reactivates a previously invalidated row.
 *
 * @implements ProcessorInterface<mixed, null>
 */
final class PushTokenRegisterProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
        private readonly PushTokenRepository $pushTokenRepository,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): null
    {
        assert($data instanceof PushTokenInput);

        $user = $this->security->getUser();
        assert($user instanceof User);

        $platform = PushPlatform::from($data->platform);

        $token = $this->pushTokenRepository->findOneByFcmToken($data->fcmToken);

        if ($token === null) {
            $token = new PushToken();
            $token->setFcmToken($data->fcmToken);
            $this->entityManager->persist($token);
        }

        $token->setUser($user);
        $token->setPlatform($platform);
        $token->setIsActive(true);

        try {
            $this->entityManager->flush();
        } catch (UniqueConstraintViolationException $e) {
            // Two concurrent registrations of the same fcmToken: the unique index is the backstop.
            throw new \RuntimeException('Push token registration conflict.', 0, $e);
        }

        return null;
    }
}
