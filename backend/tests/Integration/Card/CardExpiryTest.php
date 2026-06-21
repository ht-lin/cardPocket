<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Factory\CardFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class CardExpiryTest extends AbstractApiTestCase
{
    use Factories;

    public function testCreateCardWithExpiresAt(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $expiresAt = (new \DateTimeImmutable('+1 year'))->format(\DateTimeInterface::ATOM);
        $response = $this->authenticatedRequest($client, 'POST', '/api/cards', $token, [
            'json' => [
                'name'           => 'Loyalty',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'ABC123',
                'expiresAt'      => $expiresAt,
            ],
        ]);

        $this->assertResponseStatusCodeSame(201);
        $this->assertSame($expiresAt, $response->toArray()['expiresAt']);
    }

    public function testCreateCardWithoutExpiresAtDefaultsToNull(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'POST', '/api/cards', $token, [
            'json' => [
                'name'           => 'Loyalty',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'ABC123',
            ],
        ]);

        $this->assertResponseStatusCodeSame(201);
        $this->assertNull($response->toArray()['expiresAt']);
    }

    public function testPatchSetsExpiresAt(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $expiresAt = (new \DateTimeImmutable('+30 days'))->format(\DateTimeInterface::ATOM);
        $response = $this->authenticatedRequest($client, 'PATCH', '/api/cards/' . $card->getId(), $token, [
            'json' => ['expiresAt' => $expiresAt],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame($expiresAt, $response->toArray()['expiresAt']);
    }

    public function testPatchWithExplicitNullClearsExpiresAt(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user, 'expiresAt' => new \DateTimeImmutable('+30 days')]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'PATCH', '/api/cards/' . $card->getId(), $token, [
            'json' => ['expiresAt' => null],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertNull($response->toArray()['expiresAt']);
    }

    public function testPatchWithoutExpiresAtKeyPreservesExistingValue(): void
    {
        $expiresAt = new \DateTimeImmutable('+30 days');
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user, 'expiresAt' => $expiresAt]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        // Omitting expiresAt must not wipe the previously set value.
        $response = $this->authenticatedRequest($client, 'PATCH', '/api/cards/' . $card->getId(), $token, [
            'json' => ['name' => 'Renamed'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertSame('Renamed', $data['name']);
        $this->assertSame($expiresAt->format(\DateTimeInterface::ATOM), $data['expiresAt']);
    }

    public function testPatchWithInvalidDateFormatFails(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'PATCH', '/api/cards/' . $card->getId(), $token, [
            'json' => ['expiresAt' => 'not-a-date'],
        ]);

        $this->assertResponseStatusCodeSame(400);
    }

    public function testListExposesExpiresAt(): void
    {
        $expiresAt = new \DateTimeImmutable('+30 days');
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $user, 'expiresAt' => $expiresAt]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, [
            'headers' => ['Accept' => 'application/ld+json'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $members = $response->toArray()['member'];
        $this->assertCount(1, $members);
        $this->assertSame($expiresAt->format(\DateTimeInterface::ATOM), $members[0]['expiresAt']);
    }
}
