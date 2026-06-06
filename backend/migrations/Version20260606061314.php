<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260606061314 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Change app_card.owner_id FK from RESTRICT to CASCADE for safe hard-delete';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE app_card DROP CONSTRAINT fk_133abd737e3c61f9');
        $this->addSql('ALTER TABLE app_card ADD CONSTRAINT FK_133ABD737E3C61F9 FOREIGN KEY (owner_id) REFERENCES app_user (id) ON DELETE CASCADE NOT DEFERRABLE');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE app_card DROP CONSTRAINT FK_133ABD737E3C61F9');
        $this->addSql('ALTER TABLE app_card ADD CONSTRAINT fk_133abd737e3c61f9 FOREIGN KEY (owner_id) REFERENCES app_user (id) ON DELETE RESTRICT NOT DEFERRABLE INITIALLY IMMEDIATE');
    }
}
