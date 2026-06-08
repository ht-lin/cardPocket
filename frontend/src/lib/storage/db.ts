import * as SQLite from 'expo-sqlite';

export type CardRow = {
  id: string;
  name: string;
  barcode_type: string;
  barcode_content: string;
  color: string | null;
  gradient: string | null;
  icon: string | null;
  expires_at: string | null;
  archived_at: string | null;
  created_at: string;
  updated_at: string;
  is_shared: number;
  share_id: string | null;
  viewer_nickname: string | null;
};

let db: SQLite.SQLiteDatabase | null = null;

async function getDb(): Promise<SQLite.SQLiteDatabase> {
  if (!db) {
    db = await SQLite.openDatabaseAsync('cardpocket.db');
  }
  return db;
}

export async function initDb(): Promise<void> {
  const database = await getDb();
  await database.execAsync(`
    CREATE TABLE IF NOT EXISTS cards (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      barcode_type TEXT NOT NULL,
      barcode_content TEXT NOT NULL,
      color TEXT,
      gradient TEXT,
      icon TEXT,
      expires_at TEXT,
      archived_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_shared INTEGER NOT NULL DEFAULT 0,
      share_id TEXT,
      viewer_nickname TEXT
    );
  `);
  try {
    await database.execAsync('ALTER TABLE cards ADD COLUMN share_id TEXT;');
  } catch {
    // column already exists
  }
}

export async function insertOrReplaceCards(cards: CardRow[]): Promise<void> {
  if (cards.length === 0) return;
  const database = await getDb();
  await database.withTransactionAsync(async () => {
    for (const card of cards) {
      await database.runAsync(
        `INSERT OR REPLACE INTO cards
          (id, name, barcode_type, barcode_content, color, gradient, icon,
           expires_at, archived_at, created_at, updated_at, is_shared, share_id, viewer_nickname)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        card.id,
        card.name,
        card.barcode_type,
        card.barcode_content,
        card.color,
        card.gradient,
        card.icon,
        card.expires_at,
        card.archived_at,
        card.created_at,
        card.updated_at,
        card.is_shared,
        card.share_id,
        card.viewer_nickname,
      );
    }
  });
}

export async function selectAllCards(): Promise<CardRow[]> {
  const database = await getDb();
  return database.getAllAsync<CardRow>('SELECT * FROM cards ORDER BY created_at DESC');
}

export async function deleteCardsByIds(ids: string[]): Promise<void> {
  if (ids.length === 0) return;
  const database = await getDb();
  const placeholders = ids.map(() => '?').join(', ');
  await database.runAsync(`DELETE FROM cards WHERE id IN (${placeholders})`, ids);
}

export async function selectCardById(id: string): Promise<CardRow | null> {
  const database = await getDb();
  return database.getFirstAsync<CardRow>('SELECT * FROM cards WHERE id = ?', id);
}

export async function selectSharedCards(): Promise<CardRow[]> {
  const database = await getDb();
  return database.getAllAsync<CardRow>(
    'SELECT * FROM cards WHERE is_shared = 1 ORDER BY created_at DESC',
  );
}

export async function updateCardNicknameByShareId(
  shareId: string,
  nickname: string | null,
): Promise<void> {
  const database = await getDb();
  await database.runAsync(
    'UPDATE cards SET viewer_nickname = ? WHERE share_id = ?',
    nickname,
    shareId,
  );
}
