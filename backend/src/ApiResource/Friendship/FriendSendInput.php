<?php

declare(strict_types=1);

namespace App\ApiResource\Friendship;

use Symfony\Component\Validator\Constraints as Assert;

final class FriendSendInput
{
    #[Assert\NotBlank]
    #[Assert\Uuid]
    public string $addresseeId = '';
}
