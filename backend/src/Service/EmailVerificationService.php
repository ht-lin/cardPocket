<?php

declare(strict_types=1);

namespace App\Service;

use App\Entity\EmailVerificationToken;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;

final class EmailVerificationService
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly MailerInterface $mailer,
        private readonly string $appUrl,
        private readonly string $senderEmail,
    ) {
    }

    public function sendVerification(User $user): void
    {
        $token = new EmailVerificationToken();
        $token->setUser($user);
        $token->setToken(bin2hex(random_bytes(32)));
        $token->setExpiresAt(new \DateTimeImmutable('+24 hours'));

        $this->entityManager->persist($token);
        $this->entityManager->flush();

        $verificationUrl = $this->appUrl.'/verify-email?token='.$token->getToken();

        $email = (new Email())
            ->from($this->senderEmail)
            ->to($user->getEmail())
            ->subject('Verify your CardPocket email')
            ->text("Click this link to verify your email: $verificationUrl");

        $this->mailer->send($email);
    }
}
