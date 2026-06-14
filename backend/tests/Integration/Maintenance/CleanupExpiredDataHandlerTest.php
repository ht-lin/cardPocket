<?php

declare(strict_types=1);

namespace App\Tests\Integration\Maintenance;

use App\Entity\CardDeletion;
use App\Entity\EmailVerificationToken;
use App\Entity\RefreshToken;
use App\Factory\UserFactory;
use App\Message\CleanupExpiredDataMessage;
use App\MessageHandler\CleanupExpiredDataHandler;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use Zenstruck\Foundry\Test\Factories;

final class CleanupExpiredDataHandlerTest extends KernelTestCase
{
    use Factories;

    public function testPrunesExpiredDataButKeepsFreshData(): void
    {
        $user = UserFactory::createOne();

        /** @var EntityManagerInterface $em */
        $em = self::getContainer()->get(EntityManagerInterface::class);

        // Expired vs fresh verification tokens.
        $expiredToken = (new EmailVerificationToken())
            ->setUser($user)
            ->setToken(bin2hex(random_bytes(16)))
            ->setExpiresAt(new \DateTimeImmutable('-1 hour'));
        $freshToken = (new EmailVerificationToken())
            ->setUser($user)
            ->setToken(bin2hex(random_bytes(16)))
            ->setExpiresAt(new \DateTimeImmutable('+1 hour'));
        $em->persist($expiredToken);
        $em->persist($freshToken);

        // Invalid (expired) vs valid refresh tokens.
        $expiredRefresh = new RefreshToken();
        $expiredRefresh->setRefreshToken(bin2hex(random_bytes(16)));
        $expiredRefresh->setUsername($user->getEmail());
        $expiredRefresh->setValid(new \DateTime('-1 day'));
        $validRefresh = new RefreshToken();
        $validRefresh->setRefreshToken(bin2hex(random_bytes(16)));
        $validRefresh->setUsername($user->getEmail());
        $validRefresh->setValid(new \DateTime('+1 day'));
        $em->persist($expiredRefresh);
        $em->persist($validRefresh);

        $em->flush();

        // Old vs recent tombstones (createdAt is set on prePersist, so backdate via SQL).
        $oldTombstone = new CardDeletion();
        $oldTombstone->setUserId((string) $user->getId());
        $oldTombstone->setCardId('11111111-1111-1111-1111-111111111111');
        $recentTombstone = new CardDeletion();
        $recentTombstone->setUserId((string) $user->getId());
        $recentTombstone->setCardId('22222222-2222-2222-2222-222222222222');
        $em->persist($oldTombstone);
        $em->persist($recentTombstone);
        $em->flush();

        $em->getConnection()->executeStatement(
            "UPDATE app_card_deletion SET created_at = :old WHERE card_id = :id",
            ['old' => (new \DateTimeImmutable('-100 days'))->format('Y-m-d H:i:s'), 'id' => '11111111-1111-1111-1111-111111111111'],
        );

        $handler = self::getContainer()->get(CleanupExpiredDataHandler::class);
        $handler(new CleanupExpiredDataMessage());
        $em->clear();

        $conn = $em->getConnection();
        $this->assertSame(
            1,
            (int) $conn->fetchOne('SELECT COUNT(*) FROM email_verification_token'),
            'Only the fresh verification token should remain',
        );
        $this->assertSame(
            1,
            (int) $conn->fetchOne('SELECT COUNT(*) FROM refresh_tokens'),
            'Only the valid refresh token should remain',
        );
        $this->assertSame(
            1,
            (int) $conn->fetchOne('SELECT COUNT(*) FROM app_card_deletion'),
            'Only the recent tombstone should remain',
        );
    }
}
