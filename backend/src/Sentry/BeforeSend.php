<?php

declare(strict_types=1);

namespace App\Sentry;

use Sentry\Event;
use Sentry\EventHint;

/**
 * Scrubs sensitive data from Sentry events before they are sent (ADR-019).
 *
 * User email, card content, credentials and tokens must never reach Sentry.
 * Registered as the `before_send` callback in config/packages/sentry.yaml (prod only).
 */
final class BeforeSend
{
    private const REDACTED = '[Filtered]';

    /**
     * Keys whose values are redacted wherever they appear (case-insensitive).
     */
    private const SENSITIVE_KEYS = [
        'password',
        'token',
        'secret',
        'authorization',
        'cookie',
        'email',
        'refresh_token',
        'jwt',
        'dsn',
    ];

    public function __invoke(Event $event, ?EventHint $hint = null): Event
    {
        $this->scrubRequest($event);

        $event->setExtra($this->scrubArray($event->getExtra()));
        $event->setTags($this->scrubStringMap($event->getTags()));

        foreach ($event->getContexts() as $name => $data) {
            $event->setContext($name, $this->scrubArray($data));
        }

        // Defensive: drop user identity even if send_default_pii were ever enabled.
        $event->setUser(null);

        return $event;
    }

    /**
     * Drops the request body/query/cookies and redacts auth headers; the URL
     * and method are kept for debugging context.
     */
    private function scrubRequest(Event $event): void
    {
        $request = $event->getRequest();

        if ($request === []) {
            return;
        }

        unset($request['data'], $request['query_string'], $request['cookies']);

        if (isset($request['headers']) && \is_array($request['headers'])) {
            $request['headers'] = $this->scrubStringMap($request['headers']);
        }

        $event->setRequest($request);
    }

    /**
     * Recursively redacts values whose key matches a sensitive key.
     *
     * @param array<array-key, mixed> $data
     *
     * @return array<array-key, mixed>
     */
    private function scrubArray(array $data): array
    {
        foreach ($data as $key => $value) {
            if (\is_string($key) && $this->isSensitiveKey($key)) {
                $data[$key] = self::REDACTED;
                continue;
            }

            if (\is_array($value)) {
                $data[$key] = $this->scrubArray($value);
            }
        }

        return $data;
    }

    /**
     * @param array<string, string> $map
     *
     * @return array<string, string>
     */
    private function scrubStringMap(array $map): array
    {
        foreach ($map as $key => $value) {
            if ($this->isSensitiveKey($key)) {
                $map[$key] = self::REDACTED;
            }
        }

        return $map;
    }

    private function isSensitiveKey(string $key): bool
    {
        $needle = strtolower($key);

        foreach (self::SENSITIVE_KEYS as $sensitive) {
            if (str_contains($needle, $sensitive)) {
                return true;
            }
        }

        return false;
    }
}
