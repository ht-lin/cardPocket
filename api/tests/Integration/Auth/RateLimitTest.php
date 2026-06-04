<?php

declare(strict_types=1);

namespace App\Tests\Integration\Auth;

use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class RateLimitTest extends AbstractApiTestCase
{
    use Factories;

    public function testRegisterRateLimitReturns429(): void
    {
        // TODO: Symfony compiled container stores private services in $privates[], which
        // cannot be replaced via getContainer()->set() before first instantiation.
        // Need a reliable way to swap limiter.register_by_ip in the test container.
        $this->markTestSkipped('Rate limit container override pending investigation.');
    }
}
