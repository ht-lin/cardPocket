<?php

declare(strict_types=1);

namespace App\Tests\Integration\User;

use App\Entity\RefreshToken;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class UpdateMeTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/users/me';

    public function testUpdateUserNameSuccessfully(): void
    {
        UserFactory::createOne(['email' => 'update@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'update@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => ['userName' => 'updatedName'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertSame('updatedName', $data['userName']);
        $this->assertSame('update@example.com', $data['email']);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/',
            $data['id'],
        );
        $this->assertFalse($data['emailVerified']);

        $getResponse = $this->authenticatedRequest($client, 'GET', self::ENDPOINT, $token);
        $this->assertSame('updatedName', $getResponse->toArray()['userName']);
    }

    public function testUpdateUserNameFailsWithDuplicate(): void
    {
        UserFactory::createOne(['email' => 'user-a@example.com', 'userName' => 'userA']);
        UserFactory::createOne(['email' => 'user-b@example.com', 'userName' => 'userB']);

        $client = static::createClient();
        $token = $this->getToken($client, 'user-a@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => ['userName' => 'userB'],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertStringContainsString('username', strtolower($response->toArray(throw: false)['detail'] ?? ''));
    }

    public function testChangePasswordSuccessfully(): void
    {
        UserFactory::createOne(['email' => 'pwchange@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'pwchange@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => [
                'currentPassword' => 'Password1!',
                'newPassword' => 'Tr0ub4dor&3secure',
            ],
        ]);
        $this->assertResponseStatusCodeSame(200);

        $newToken = $this->getToken($client, 'pwchange@example.com', 'Tr0ub4dor&3secure');
        $response = $this->authenticatedRequest($client, 'GET', self::ENDPOINT, $newToken);
        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('pwchange@example.com', $response->toArray()['email']);
    }

    public function testChangePasswordRevokesRefreshTokens(): void
    {
        UserFactory::createOne(['email' => 'pwrevoke@example.com']);

        $client = static::createClient();
        $loginResponse = $client->request('POST', '/api/auth/login', [
            'json' => ['email' => 'pwrevoke@example.com', 'password' => 'Password1!'],
        ]);
        $oldRefreshToken = $loginResponse->toArray()['refresh_token'];

        $token = $this->getToken($client, 'pwrevoke@example.com', 'Password1!');
        $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => [
                'currentPassword' => 'Password1!',
                'newPassword' => 'Tr0ub4dor&3secure',
            ],
        ]);
        $this->assertResponseStatusCodeSame(200);

        // The previously issued refresh token must no longer be usable.
        $em = static::getContainer()->get('doctrine')->getManager();
        $this->assertNull(
            $em->getRepository(RefreshToken::class)->findOneBy(['refreshToken' => $oldRefreshToken]),
            'Refresh tokens must be revoked after a password change',
        );

        $client->request('POST', '/api/auth/refresh', [
            'json' => ['refresh_token' => $oldRefreshToken],
        ]);
        $this->assertResponseStatusCodeSame(401);
    }

    public function testChangePasswordFailsWithWrongCurrentPassword(): void
    {
        UserFactory::createOne(['email' => 'wrongpw@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'wrongpw@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => [
                'currentPassword' => 'WrongPass!',
                'newPassword' => 'Tr0ub4dor&3secure',
            ],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertStringContainsString('password', strtolower($response->toArray(throw: false)['detail'] ?? ''));
    }

    public function testUpdateMeFailsWithoutAuth(): void
    {
        $client = static::createClient();
        $response = $client->request('PATCH', self::ENDPOINT, [
            'json' => ['userName' => 'someNewName'],
        ]);

        $this->assertResponseStatusCodeSame(401);
        $this->assertSame(401, $response->toArray(throw: false)['code']);
    }

    public function testChangePasswordFailsWhenCurrentPasswordMissing(): void
    {
        UserFactory::createOne(['email' => 'nopw@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'nopw@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => ['newPassword' => 'Tr0ub4dor&3secure'],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }

    public function testUpdateUserNameFailsWhenTooShort(): void
    {
        UserFactory::createOne(['email' => 'short@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'short@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => ['userName' => 'x'],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }

    public function testChangePasswordFailsWithWeakNewPassword(): void
    {
        UserFactory::createOne(['email' => 'weaknew@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'weaknew@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => [
                'currentPassword' => 'Password1!',
                'newPassword' => '123',
            ],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }

    public function testPatchWithEmptyBodyReturnsCurrentData(): void
    {
        $user = UserFactory::createOne(['email' => 'noop@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'noop@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => [],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertSame('noop@example.com', $data['email']);
        $this->assertSame($user->getUserName(), $data['userName']);
    }
}
