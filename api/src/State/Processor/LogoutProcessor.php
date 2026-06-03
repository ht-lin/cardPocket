<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\Auth\LogoutInput;
use Gesdinet\JWTRefreshTokenBundle\Model\RefreshTokenManagerInterface;

/**
 * @implements ProcessorInterface<LogoutInput, null>
 */
final class LogoutProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly RefreshTokenManagerInterface $refreshTokenManager,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): null
    {
        assert($data instanceof LogoutInput);

        $token = $this->refreshTokenManager->get($data->refresh_token);
        if ($token !== null) {
            $this->refreshTokenManager->delete($token);
        }

        return null;
    }
}
