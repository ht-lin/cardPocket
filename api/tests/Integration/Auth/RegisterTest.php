<?php

declare(strict_types=1);

namespace App\Tests\Integration\Auth;

use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class RegisterTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/auth/register';
    private const array VALID_PAYLOAD = [
        'email' => 'new@example.com',
        'password' => 'Str0ng!Pass#2024',
        'userName' => 'new_user',
        'gdprConsent' => true,
    ];

    public function testRegisterSuccessfully(): void
    {
        $client = static::createClient();

        $response = $client->request('POST', self::ENDPOINT, ['json' => self::VALID_PAYLOAD]);

        $this->assertResponseStatusCodeSame(201);

        $data = $response->toArray();
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i',
            $data['id'],
            'id must be a UUID',
        );
        $this->assertSame('new@example.com', $data['email']);
        $this->assertSame('new_user', $data['userName']);
        $this->assertFalse($data['emailVerified']);
        $this->assertMatchesRegularExpression(
            '/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/',
            $data['createdAt'],
            'createdAt must be an ISO 8601 timestamp',
        );
        $this->assertArrayNotHasKey('password', $data);
        $this->assertArrayNotHasKey('deletedAt', $data);
        $this->assertArrayNotHasKey('gdprConsentAt', $data);
    }

    public function testRegisterFailsWithDuplicateEmail(): void
    {
        UserFactory::createOne(['email' => 'existing@example.com']);

        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, ['json' => array_merge(self::VALID_PAYLOAD, [
            'email' => 'existing@example.com',
            'userName' => 'different_user',
        ])]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'email']]]);
    }

    public function testRegisterFailsWithDuplicateUserName(): void
    {
        UserFactory::createOne(['userName' => 'takenname']);

        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, ['json' => array_merge(self::VALID_PAYLOAD, [
            'email' => 'another@example.com',
            'userName' => 'takenname',
        ])]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'userName']]]);
    }

    public function testRegisterFailsWithoutGdprConsent(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, ['json' => array_merge(self::VALID_PAYLOAD, [
            'gdprConsent' => false,
        ])]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'gdprConsent']]]);
    }

    public function testRegisterFailsWithWeakPassword(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, ['json' => array_merge(self::VALID_PAYLOAD, [
            'password' => '123456',
        ])]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'password']]]);
    }
}
