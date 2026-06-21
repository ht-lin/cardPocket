<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260621165404 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'BE-PUSH: add app_push_token (fcmToken unique, user FK CASCADE)';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('CREATE TABLE app_push_token (id UUID NOT NULL, fcm_token VARCHAR(512) NOT NULL, platform VARCHAR(255) NOT NULL, is_active BOOLEAN NOT NULL, created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, updated_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, user_id UUID NOT NULL, PRIMARY KEY (id))');
        $this->addSql('CREATE UNIQUE INDEX UNIQ_7A7B8FD19B88AF9 ON app_push_token (fcm_token)');
        $this->addSql('CREATE INDEX IDX_7A7B8FDA76ED395 ON app_push_token (user_id)');
        $this->addSql('ALTER TABLE app_push_token ADD CONSTRAINT FK_7A7B8FDA76ED395 FOREIGN KEY (user_id) REFERENCES app_user (id) ON DELETE CASCADE NOT DEFERRABLE');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE app_push_token DROP CONSTRAINT FK_7A7B8FDA76ED395');
        $this->addSql('DROP TABLE app_push_token');
    }
}
