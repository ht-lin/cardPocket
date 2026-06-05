<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260605232342 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add bidirectional unique index on app_friendship to prevent (A→B)+(B→A) duplicates';
    }

    public function up(Schema $schema): void
    {
        $this->addSql("CREATE UNIQUE INDEX uniq_friendship_pair ON app_friendship (LEAST(requester_id::text, addressee_id::text), GREATEST(requester_id::text, addressee_id::text))");
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP INDEX IF EXISTS uniq_friendship_pair');
    }
}
