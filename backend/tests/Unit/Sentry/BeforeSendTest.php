<?php

declare(strict_types=1);

namespace App\Tests\Unit\Sentry;

use App\Sentry\BeforeSend;
use PHPUnit\Framework\TestCase;
use Sentry\Event;
use Sentry\UserDataBag;

final class BeforeSendTest extends TestCase
{
    public function testDropsRequestBodyQueryAndCookies(): void
    {
        $event = Event::createEvent();
        $event->setRequest([
            'url' => 'https://api.cardpocket.app/api/cards',
            'method' => 'POST',
            'data' => ['name' => 'My Card', 'password' => 's3cret'],
            'query_string' => 'q=foo',
            'cookies' => ['SESSION' => 'abc'],
        ]);

        $result = (new BeforeSend())($event);

        $request = $result->getRequest();
        self::assertArrayNotHasKey('data', $request);
        self::assertArrayNotHasKey('query_string', $request);
        self::assertArrayNotHasKey('cookies', $request);
        // Non-sensitive context is preserved.
        self::assertSame('https://api.cardpocket.app/api/cards', $request['url']);
        self::assertSame('POST', $request['method']);
    }

    public function testRedactsSensitiveRequestHeaders(): void
    {
        $event = Event::createEvent();
        $event->setRequest([
            'headers' => [
                'Authorization' => 'Bearer eyJhbGciOi...',
                'Cookie' => 'SESSION=abc',
                'Accept' => 'application/ld+json',
            ],
        ]);

        $result = (new BeforeSend())($event);

        $headers = $result->getRequest()['headers'];
        self::assertSame('[Filtered]', $headers['Authorization']);
        self::assertSame('[Filtered]', $headers['Cookie']);
        self::assertSame('application/ld+json', $headers['Accept']);
    }

    public function testRedactsSensitiveKeysInExtraRecursively(): void
    {
        $event = Event::createEvent();
        $event->setExtra([
            'token' => 'abc123',
            'user_email' => 'alice@example.com',
            'safe' => 'keep',
            'nested' => ['refresh_token' => 'r123', 'count' => 3],
        ]);

        $result = (new BeforeSend())($event);

        $extra = $result->getExtra();
        self::assertSame('[Filtered]', $extra['token']);
        self::assertSame('[Filtered]', $extra['user_email']);
        self::assertSame('keep', $extra['safe']);
        self::assertSame('[Filtered]', $extra['nested']['refresh_token']);
        self::assertSame(3, $extra['nested']['count']);
    }

    public function testRedactsSensitiveTags(): void
    {
        $event = Event::createEvent();
        $event->setTags([
            'jwt' => 'eyJ...',
            'route' => '/api/cards',
        ]);

        $result = (new BeforeSend())($event);

        $tags = $result->getTags();
        self::assertSame('[Filtered]', $tags['jwt']);
        self::assertSame('/api/cards', $tags['route']);
    }

    public function testClearsUserIdentity(): void
    {
        $event = Event::createEvent();
        $event->setUser(UserDataBag::createFromArray([
            'id' => 42,
            'email' => 'alice@example.com',
        ]));

        $result = (new BeforeSend())($event);

        self::assertNull($result->getUser());
    }
}
