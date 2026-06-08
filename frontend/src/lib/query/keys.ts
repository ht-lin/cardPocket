export const queryKeys = {
  me: ['me'] as const,
  cards: {
    all: ['cards'] as const,
    detail: (id: string) => ['cards', id] as const,
    shared: ['cards', 'shared'] as const,
  },
  friends: {
    all: ['friends'] as const,
    requests: ['friends', 'requests'] as const,
  },
  shares: {
    card: (cardId: string) => ['shares', cardId] as const,
  },
  users: {
    search: (q: string) => ['users', 'search', q] as const,
  },
} as const;
