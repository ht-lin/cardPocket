<?php

declare(strict_types=1);

namespace App\Tests\Integration\Maintenance;

use App\Entity\CardDeletion;
use App\Entity\EmailVerificationToken;
use App\Entity\RefreshToken;
use App\Enum\ExpiryPolicy;
use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
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

    public function testAutoTrashesExpiredCardsForAutoTrashUsers(): void
    {
        $autoUser = UserFactory::createOne(['expiryPolicy' => ExpiryPolicy::AUTO_TRASH]);
        $keepUser = UserFactory::createOne(['expiryPolicy' => ExpiryPolicy::KEEP]);

        // AUTO_TRASH user, expired -> should be trashed, with owner + viewer tombstones.
        $expiredCard = CardFactory::createOne([
            'owner'     => $autoUser,
            'expiresAt' => new \DateTimeImmutable('-1 day'),
        ]);
        CardShareFactory::createOne(['card' => $expiredCard]);

        // KEEP user, expired -> must be left untouched.
        $keepExpiredCard = CardFactory::createOne([
            'owner'     => $keepUser,
            'expiresAt' => new \DateTimeImmutable('-1 day'),
        ]);

        // AUTO_TRASH user, not yet expired / no expiry -> left untouched.
        $futureCard = CardFactory::createOne([
            'owner'     => $autoUser,
            'expiresAt' => new \DateTimeImmutable('+1 day'),
        ]);
        $noExpiryCard = CardFactory::createOne([
            'owner'     => $autoUser,
            'expiresAt' => null,
        ]);

        $expiredId   = (string) $expiredCard->getId();
        $keepId      = (string) $keepExpiredCard->getId();
        $futureId    = (string) $futureCard->getId();
        $noExpiryId  = (string) $noExpiryCard->getId();

        /** @var EntityManagerInterface $em */
        $em = self::getContainer()->get(EntityManagerInterface::class);

        $handler = self::getContainer()->get(CleanupExpiredDataHandler::class);
        $handler(new CleanupExpiredDataMessage());
        $em->clear();

        $conn = $em->getConnection();

        $this->assertNotNull(
            $conn->fetchOne('SELECT deleted_at FROM app_card WHERE id = :id', ['id' => $expiredId]),
            'Expired card of an AUTO_TRASH user should be soft-deleted',
        );
        $this->assertNull(
            $conn->fetchOne('SELECT deleted_at FROM app_card WHERE id = :id', ['id' => $keepId]),
            'Expired card of a KEEP user must stay active',
        );
        $this->assertNull(
            $conn->fetchOne('SELECT deleted_at FROM app_card WHERE id = :id', ['id' => $futureId]),
            'Not-yet-expired card must stay active',
        );
        $this->assertNull(
            $conn->fetchOne('SELECT deleted_at FROM app_card WHERE id = :id', ['id' => $noExpiryId]),
            'Card without an expiry must stay active',
        );

        // One tombstone for the owner + one for the single viewer of the trashed card.
        $this->assertSame(
            2,
            (int) $conn->fetchOne('SELECT COUNT(*) FROM app_card_deletion'),
            'Owner + viewer tombstones should be written for the auto-trashed card only',
        );
    }

    public function testPurgesCardsTrashedBeyondRetention(): void
    {
        $owner = UserFactory::createOne();

        // Trashed longer than the 30-day retention window -> physically purged.
        $oldCard = CardFactory::createOne([
            'owner'     => $owner,
            'deletedAt' => new \DateTimeImmutable('-31 days'),
        ]);
        CardShareFactory::createOne(['card' => $oldCard]);

        // Trashed recently -> kept.
        $recentCard = CardFactory::createOne([
            'owner'     => $owner,
            'deletedAt' => new \DateTimeImmutable('-10 days'),
        ]);

        $oldId    = (string) $oldCard->getId();
        $recentId = (string) $recentCard->getId();

        /** @var EntityManagerInterface $em */
        $em = self::getContainer()->get(EntityManagerInterface::class);

        $handler = self::getContainer()->get(CleanupExpiredDataHandler::class);
        $handler(new CleanupExpiredDataMessage());
        $em->clear();

        $conn = $em->getConnection();

        $this->assertSame(
            0,
            (int) $conn->fetchOne('SELECT COUNT(*) FROM app_card WHERE id = :id', ['id' => $oldId]),
            'Card trashed beyond the retention window should be physically deleted',
        );
        $this->assertSame(
            0,
            (int) $conn->fetchOne('SELECT COUNT(*) FROM app_card_share WHERE card_id = :id', ['id' => $oldId]),
            'CardShare rows of a purged card should be deleted',
        );
        $this->assertSame(
            1,
            (int) $conn->fetchOne('SELECT COUNT(*) FROM app_card WHERE id = :id', ['id' => $recentId]),
            'Recently trashed card should be kept',
        );

        // One tombstone for the owner + one for the single viewer of the purged card.
        $this->assertSame(
            2,
            (int) $conn->fetchOne('SELECT COUNT(*) FROM app_card_deletion'),
            'Owner + viewer tombstones should be written for the purged card',
        );
    }
}
