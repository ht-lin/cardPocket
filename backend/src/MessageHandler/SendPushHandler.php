<?php

declare(strict_types=1);

namespace App\MessageHandler;

use App\Entity\User;
use App\Message\SendPushMessage;
use App\Repository\PushTokenRepository;
use App\Service\Fcm\FcmClientInterface;
use App\Service\Fcm\FcmSendResult;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;
use Symfony\Component\Uid\Uuid;

/**
 * Fans a SendPushMessage out to every active FCM token of the target user. Tokens FCM reports as
 * dead (UNREGISTERED / NOT_FOUND) are deactivated so they are skipped next time.
 */
#[AsMessageHandler]
final class SendPushHandler
{
    public function __construct(
        private readonly PushTokenRepository $pushTokenRepository,
        private readonly FcmClientInterface $fcmClient,
        private readonly EntityManagerInterface $entityManager,
    ) {
    }

    public function __invoke(SendPushMessage $message): void
    {
        $user = $this->entityManager->find(User::class, Uuid::fromString($message->userId));
        if ($user === null) {
            return;
        }

        $deactivated = false;
        foreach ($this->pushTokenRepository->findActiveByUser($user) as $token) {
            $result = $this->fcmClient->send($token, $message->title, $message->body, $message->data);

            if ($result === FcmSendResult::UNREGISTERED) {
                $token->setIsActive(false);
                $deactivated = true;
            }
        }

        if ($deactivated) {
            $this->entityManager->flush();
        }
    }
}
