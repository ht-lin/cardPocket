<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * BE-PRIVACY: add User.discoverable (default true) — opt-out flag for friend search.
 */
final class Version20260622090000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'BE-PRIVACY: add User.discoverable (default true)';
    }

    public function up(Schema $schema): void
    {
        // Add with a DEFAULT to backfill existing rows, then drop it so the schema matches the
        // mapping (which has no DB-level default — the true default lives in the PHP entity).
        $this->addSql('ALTER TABLE app_user ADD discoverable BOOLEAN NOT NULL DEFAULT true');
        $this->addSql('ALTER TABLE app_user ALTER COLUMN discoverable DROP DEFAULT');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE app_user DROP discoverable');
    }
}
