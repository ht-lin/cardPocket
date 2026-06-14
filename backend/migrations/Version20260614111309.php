<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260614111309 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add unique constraint on app_card_share (card_id, viewer_id) to prevent duplicate shares';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('CREATE UNIQUE INDEX uniq_card_share_card_viewer ON app_card_share (card_id, viewer_id)');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP INDEX uniq_card_share_card_viewer');
    }
}
