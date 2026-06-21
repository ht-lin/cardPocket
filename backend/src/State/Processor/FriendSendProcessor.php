<?php

declare(strict_types=1);

namespace App\State\Processor;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\ApiResource\Friendship\FriendRequestOutput;
use App\ApiResource\Friendship\FriendSendInput;
use App\Entity\Friendship;
use App\Entity\User;
use App\Enum\FriendshipStatus;
use App\Message\SendPushMessage;
use App\Repository\FriendshipRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\TooManyRequestsHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\RateLimiter\RateLimiterFactory;
use Symfony\Component\Uid\Uuid;

/**
 * @implements ProcessorInterface<FriendSendInput, FriendRequestOutput>
 */
final class FriendSendProcessor implements ProcessorInterface
{
    public function __construct(
        private readonly Security $security,
        private readonly EntityManagerInterface $entityManager,
        private readonly FriendshipRepository $friendshipRepository,
        private readonly MessageBusInterface $messageBus,
        #[Autowire(service: 'limiter.send_friend_request_by_user')]
        private readonly RateLimiterFactory $sendFriendRequestLimiter,
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): FriendRequestOutput
    {
        assert($data instanceof FriendSendInput);

        $me = $this->security->getUser();
        assert($me instanceof User);

        if ($me->getEmailVerifiedAt() === null) {
            throw new AccessDeniedHttpException();
        }

        if (!$this->sendFriendRequestLimiter->create((string) $me->getId())->consume()->isAccepted()) {
            throw new TooManyRequestsHttpException();
        }

        $addresseeUuid = Uuid::fromString($data->addresseeId);
        $addressee     = $this->entityManager->find(User::class, $addresseeUuid);

        if ($addressee === null) {
            throw new UnprocessableEntityHttpException('Target user not found.');
        }

        if ($addressee->getId()->equals($me->getId())) {
            throw new UnprocessableEntityHttpException('Cannot send a friend request to yourself.');
        }

        $existing = $this->friendshipRepository->findExistingBetweenUsers($me, $addressee);

        if ($existing !== null) {
            if ($existing->getStatus() === FriendshipStatus::ACCEPTED) {
                throw new UnprocessableEntityHttpException('You are already friends.');
            }
            throw new UnprocessableEntityHttpException('A pending friend request already exists.');
        }

        $friendship = new Friendship();
        $friendship->setRequester($me);
        $friendship->setAddressee($addressee);
        $friendship->setStatus(FriendshipStatus::PENDING);

        $this->entityManager->persist($friendship);
        $this->entityManager->flush();

        // Notify the addressee's devices that a friend request arrived (routed async; FCM failures
        // never affect this request's outcome).
        $this->messageBus->dispatch(new SendPushMessage(
            userId: (string) $addressee->getId(),
            title: 'New friend request',
            body: sprintf('%s wants to be your friend', $me->getUserName()),
        ));

        return new FriendRequestOutput(
            id: (string) $friendship->getId(),
            requester: [
                'id'       => (string) $me->getId(),
                'userName' => $me->getUserName(),
            ],
            status: $friendship->getStatus()->value,
            createdAt: $friendship->getCreatedAt()->format(\DateTimeInterface::ATOM),
        );
    }
}
