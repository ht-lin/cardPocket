<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Entity\Card;
use App\Factory\CardFactory;
use App\Factory\UserFactory;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use Zenstruck\Foundry\Test\Factories;

final class CardRepositoryTest extends KernelTestCase
{
    use Factories;

    public function testFindActiveByOwnerExcludesSoftDeletedWhenFilterDisabled(): void
    {
        $owner = UserFactory::createOne();
        CardFactory::createOne(['owner' => $owner, 'name' => 'Active Card']);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Deleted Card', 'deletedAt' => new \DateTimeImmutable()]);

        /** @var EntityManagerInterface $em */
        $em = self::getContainer()->get(EntityManagerInterface::class);
        $em->getFilters()->disable('soft_delete');

        $cards = $em->getRepository(Card::class)->findActiveByOwner($owner);

        $this->assertCount(1, $cards);
        $this->assertSame('Active Card', $cards[0]->getName());
    }

    public function testCountActiveByOwnerExcludesSoftDeletedWhenFilterDisabled(): void
    {
        $owner = UserFactory::createOne();
        CardFactory::createOne(['owner' => $owner]);
        CardFactory::createOne(['owner' => $owner, 'deletedAt' => new \DateTimeImmutable()]);

        /** @var EntityManagerInterface $em */
        $em = self::getContainer()->get(EntityManagerInterface::class);
        $em->getFilters()->disable('soft_delete');

        $count = $em->getRepository(Card::class)->countActiveByOwner($owner);

        $this->assertSame(1, $count);
    }
}
