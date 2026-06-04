<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260604192248 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE TABLE app_card_share (id UUID NOT NULL, viewer_nickname VARCHAR(255) DEFAULT NULL, created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, card_id UUID NOT NULL, viewer_id UUID NOT NULL, PRIMARY KEY (id))');
        $this->addSql('CREATE INDEX IDX_8129C7E04ACC9A20 ON app_card_share (card_id)');
        $this->addSql('CREATE INDEX IDX_8129C7E06C59C752 ON app_card_share (viewer_id)');
        $this->addSql('ALTER TABLE app_card_share ADD CONSTRAINT FK_8129C7E04ACC9A20 FOREIGN KEY (card_id) REFERENCES app_card (id) ON DELETE CASCADE NOT DEFERRABLE');
        $this->addSql('ALTER TABLE app_card_share ADD CONSTRAINT FK_8129C7E06C59C752 FOREIGN KEY (viewer_id) REFERENCES app_user (id) ON DELETE CASCADE NOT DEFERRABLE');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE app_card_share DROP CONSTRAINT FK_8129C7E04ACC9A20');
        $this->addSql('ALTER TABLE app_card_share DROP CONSTRAINT FK_8129C7E06C59C752');
        $this->addSql('DROP TABLE app_card_share');
    }
}
