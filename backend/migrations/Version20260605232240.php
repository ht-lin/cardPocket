<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260605232240 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add updated_at to app_card_share for incremental sync support';
    }

    public function up(Schema $schema): void
    {
        $this->addSql("ALTER TABLE app_card_share ADD updated_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL DEFAULT NOW()");
        $this->addSql("ALTER TABLE app_card_share ALTER COLUMN updated_at DROP DEFAULT");
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE app_card_share DROP COLUMN updated_at');
    }
}
