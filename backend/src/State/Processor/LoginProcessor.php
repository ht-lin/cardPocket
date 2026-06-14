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
    // Precomputed bcrypt hash of a throwaway password. Verified against the supplied password
    // when the account does not exist so the response time matches the real-user path and
    // cannot be used to enumerate registered emails.
    private const string DUMMY_HASH = '$2y$10$HgO5EgA7x6smYKC0yYUTMehAOk.vGY2r5AYPvOFas5dRWqHMDpYPi';

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
        #[Autowire(service: 'limiter.login_by_account')]
        private readonly RateLimiterFactory $loginByAccountLimiter,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): LoginOutput
    {
        assert($data instanceof LoginInput);

        $ip = $this->requestStack->getCurrentRequest()?->getClientIp() ?? '127.0.0.1';
        if (!$this->loginByIpLimiter->create($ip)->consume()->isAccepted()) {
            throw new TooManyRequestsHttpException();
        }

        if (!$this->loginByAccountLimiter->create($data->email)->consume()->isAccepted()) {
            throw new TooManyRequestsHttpException();
        }

        $user = $this->entityManager->getRepository(User::class)->findOneBy(['email' => $data->email]);

        if (!$user instanceof User) {
            // Burn equivalent hashing time so a missing account is indistinguishable from a
            // wrong password (anti-enumeration), then fail with the same generic error.
            $dummy = (new User())->setPassword(self::DUMMY_HASH);
            $this->passwordHasher->isPasswordValid($dummy, $data->password);

            throw new UnauthorizedHttpException('Bearer', 'Invalid credentials.');
        }

        if (!$this->passwordHasher->isPasswordValid($user, $data->password)) {
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
