<?php

declare(strict_types=1);

namespace App\Service\Fcm;

enum FcmSendResult
{
    case SUCCESS;
    /** Token is no longer valid (UNREGISTERED / NOT_FOUND) — caller should deactivate it. */
    case UNREGISTERED;
    /** Transient failure (network, 5xx) — token stays active for a later retry. */
    case TRANSIENT_ERROR;
}
