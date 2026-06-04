<?php

declare(strict_types=1);

namespace App\Entity;

use App\Repository\CardShareRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Bridge\Doctrine\IdGenerator\UuidGenerator;
use Symfony\Bridge\Doctrine\Types\UuidType;
use Symfony\Component\Uid\Uuid;

#[ORM\Entity(repositoryClass: CardShareRepository::class)]
#[ORM\Table(name: 'app_card_share')]
#[ORM\HasLifecycleCallbacks]
class CardShare
{
    #[ORM\Id]
    #[ORM\Column(type: UuidType::NAME, unique: true)]
    #[ORM\GeneratedValue(strategy: 'CUSTOM')]
    #[ORM\CustomIdGenerator(class: UuidGenerator::class)]
    private Uuid $id;

    #[ORM\ManyToOne(targetEntity: Card::class)]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private Card $card;

    #[ORM\ManyToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private User $viewer;

    #[ORM\Column(length: 255, nullable: true)]
    private ?string $viewerNickname = null;

    #[ORM\Column]
    private \DateTimeImmutable $createdAt;

    public function getId(): Uuid
    {
        return $this->id;
    }

    public function getCard(): Card
    {
        return $this->card;
    }

    public function setCard(Card $card): static
    {
        $this->card = $card;

        return $this;
    }

    public function getViewer(): User
    {
        return $this->viewer;
    }

    public function setViewer(User $viewer): static
    {
        $this->viewer = $viewer;

        return $this;
    }

    public function getViewerNickname(): ?string
    {
        return $this->viewerNickname;
    }

    public function setViewerNickname(?string $viewerNickname): static
    {
        $this->viewerNickname = $viewerNickname;

        return $this;
    }

    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }

    #[ORM\PrePersist]
    public function onPrePersist(): void
    {
        $this->createdAt = new \DateTimeImmutable();
    }
}
