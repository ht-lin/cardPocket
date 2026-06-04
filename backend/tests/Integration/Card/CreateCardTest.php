<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Factory\CardFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class CreateCardTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/cards';

    public function testCreateCardSuccessfully(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => [
                'name'           => 'My Loyalty Card',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'https://example.com/loyalty/12345',
            ],
        ]);

        $this->assertResponseStatusCodeSame(201);
        $data = $response->toArray();
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/',
            $data['id'],
        );
        $this->assertSame('My Loyalty Card', $data['name']);
        $this->assertSame('QR_CODE', $data['barcodeType']);
        $this->assertSame('https://example.com/loyalty/12345', $data['barcodeContent']);
        $this->assertTrue($data['isOwner']);
        $this->assertMatchesRegularExpression(
            '/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+\-]\d{2}:\d{2}$/',
            $data['createdAt'],
        );
        $this->assertMatchesRegularExpression(
            '/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+\-]\d{2}:\d{2}$/',
            $data['updatedAt'],
        );
    }

    public function testCreateCardFailsWithoutAuth(): void
    {
        $client = static::createClient();

        $client->request('POST', self::ENDPOINT, [
            'json' => [
                'name'           => 'Some Card',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'content',
            ],
        ]);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testCreateCardFailsWhenEmailNotVerified(): void
    {
        UserFactory::createOne(['email' => 'unverified@example.com', 'emailVerifiedAt' => null]);
        $client = static::createClient();
        $token = $this->getToken($client, 'unverified@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => [
                'name'           => 'Some Card',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'content',
            ],
        ]);

        $this->assertResponseStatusCodeSame(403);
    }

    public function testCreateCardFailsWhenLimitReached(): void
    {
        $user = UserFactory::createOne(['email' => 'limited@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createMany(200, ['owner' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'limited@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => [
                'name'           => 'Card 201',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'overflow',
            ],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['detail' => 'You have reached the maximum limit of 200 cards.']);
    }

    public function testCreateCardFailsWithBlankName(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => [
                'name'           => '',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'content',
            ],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'name']]]);
    }

    public function testCreateCardFailsWithBlankBarcodeContent(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => [
                'name'           => 'My Card',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => '',
            ],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'barcodeContent']]]);
    }

    public function testCreateCardFailsWithInvalidBarcodeType(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => [
                'name'           => 'My Card',
                'barcodeType'    => 'INVALID_TYPE',
                'barcodeContent' => 'content',
            ],
        ]);

        $this->assertResponseStatusCodeSame(400);
    }

    public function testCreateCardFailsWithMissingBarcodeType(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => [
                'name'           => 'My Card',
                'barcodeContent' => 'content',
            ],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'barcodeType']]]);
    }

    public function testBarcodeTypeAndContentCannotBeUpdated(): void
    {
        $user = UserFactory::createOne(['email' => 'patcher@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne([
            'owner'          => $user,
            'barcodeType'    => \App\Enum\BarcodeType::QR_CODE,
            'barcodeContent' => 'original-content',
            'name'           => 'Original Name',
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'patcher@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/cards/' . $card->getId(),
            $token,
            [
                'json' => [
                    'name'           => 'Updated Name',
                    'barcodeType'    => 'CODE_128',
                    'barcodeContent' => 'hacked-content',
                ],
            ],
        );

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertSame('Updated Name', $data['name']);
        $this->assertSame('QR_CODE', $data['barcodeType']);
        $this->assertSame('original-content', $data['barcodeContent']);
    }
}
