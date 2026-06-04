<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\Auth\LoginInput;
use App\ApiResource\Auth\LoginOutput;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Gesdinet\JWTRefreshTokenBundle\Generator\RefreshTokenGeneratorInterface;
use Gesdinet\JWTRefreshTokenBundle\Model\RefreshTokenManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\HttpKernel\Exception\TooManyRequestsHttpException;
use Symfony\Component\HttpKernel\Exception\UnauthorizedHttpException;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\RateLimiter\RateLimiterFactory;

/**
 * @implements ProcessorInterface<LoginInput, LoginOutput>
 */
final class LoginProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly UserPasswordHasherInterface $passwordHasher,
        private readonly JWTTokenManagerInterface $jwtManager,
        private readonly RefreshTokenGeneratorInterface $refreshTokenGenerator,
        private readonly RefreshTokenManagerInterface $refreshTokenManager,
        private readonly int $jwtTtl,
        private readonly RequestStack $requestStack,
        #[Autowire(service: 'limiter.login_by_ip')]
        private readonly RateLimiterFactory $loginByIpLimiter,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): LoginOutput
    {
        assert($data instanceof LoginInput);

        $ip = $this->requestStack->getCurrentRequest()?->getClientIp() ?? '127.0.0.1';
        if (!$this->loginByIpLimiter->create($ip)->consume()->isAccepted()) {
            throw new TooManyRequestsHttpException();
        }

        $user = $this->entityManager->getRepository(User::class)->findOneBy(['email' => $data->email]);

        if (!$user instanceof User || !$this->passwordHasher->isPasswordValid($user, $data->password)) {
            throw new UnauthorizedHttpException('Bearer', 'Invalid credentials.');
        }

        $accessToken = $this->jwtManager->create($user);

        $refreshToken = $this->refreshTokenGenerator->createForUserWithTtl($user, 2592000);
        $this->refreshTokenManager->save($refreshToken);

        return new LoginOutput(
            access_token: $accessToken,
            refresh_token: $refreshToken->getRefreshToken(),
            token_type: 'Bearer',
            expires_in: $this->jwtTtl,
        );
    }
}
