<?php

declare(strict_types=1);

namespace App\EventSubscriber;

use Lexik\Bundle\JWTAuthenticationBundle\Event\AuthenticationSuccessEvent;
use Lexik\Bundle\JWTAuthenticationBundle\Events;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

final class AuthenticationSuccessSubscriber implements EventSubscriberInterface
{
    public function __construct(private readonly int $jwtTtl) {}

    public static function getSubscribedEvents(): array
    {
        return [
            Events::AUTHENTICATION_SUCCESS => ['onAuthenticationSuccess', -10],
        ];
    }

    public function onAuthenticationSuccess(AuthenticationSuccessEvent $event): void
    {
        $data = $event->getData();

        if (!isset($data['token'])) {
            return;
        }

        $data['access_token'] = $data['token'];
        unset($data['token']);
        $data['expires_in'] = $this->jwtTtl;

        $event->setData($data);
    }
}
