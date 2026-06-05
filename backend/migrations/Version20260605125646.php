<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260605125646 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('CREATE TABLE app_friendship (id UUID NOT NULL, status VARCHAR(255) NOT NULL, created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, updated_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, requester_id UUID NOT NULL, addressee_id UUID NOT NULL, PRIMARY KEY (id))');
        $this->addSql('CREATE INDEX IDX_242F0F23ED442CF4 ON app_friendship (requester_id)');
        $this->addSql('CREATE INDEX IDX_242F0F232261B4C3 ON app_friendship (addressee_id)');
        $this->addSql('CREATE INDEX idx_friendship_addressee_status ON app_friendship (addressee_id, status)');
        $this->addSql('CREATE UNIQUE INDEX UNIQ_242F0F23ED442CF42261B4C3 ON app_friendship (requester_id, addressee_id)');
        $this->addSql('ALTER TABLE app_friendship ADD CONSTRAINT FK_242F0F23ED442CF4 FOREIGN KEY (requester_id) REFERENCES app_user (id) ON DELETE CASCADE NOT DEFERRABLE');
        $this->addSql('ALTER TABLE app_friendship ADD CONSTRAINT FK_242F0F232261B4C3 FOREIGN KEY (addressee_id) REFERENCES app_user (id) ON DELETE CASCADE NOT DEFERRABLE');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE app_friendship DROP CONSTRAINT FK_242F0F23ED442CF4');
        $this->addSql('ALTER TABLE app_friendship DROP CONSTRAINT FK_242F0F232261B4C3');
        $this->addSql('DROP TABLE app_friendship');
    }
}
