<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260620203100 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'BE-EXPIRY: add Card.expires_at (nullable) and User.expiry_policy (default KEEP)';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE app_card ADD expires_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL');
        // Add with a DEFAULT to backfill existing rows, then drop it so the schema matches the
        // mapping (which has no DB-level default — the KEEP default lives in the PHP entity).
        $this->addSql("ALTER TABLE app_user ADD expiry_policy VARCHAR(255) NOT NULL DEFAULT 'KEEP'");
        $this->addSql('ALTER TABLE app_user ALTER COLUMN expiry_policy DROP DEFAULT');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE app_card DROP expires_at');
        $this->addSql('ALTER TABLE app_user DROP expiry_policy');
    }
}
