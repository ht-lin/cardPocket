<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260621004857 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'BE-CARD-CUSTOM: add Card.color (nullable #RRGGBB hex)';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE app_card ADD color VARCHAR(7) DEFAULT NULL');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE app_card DROP color');
    }
}
