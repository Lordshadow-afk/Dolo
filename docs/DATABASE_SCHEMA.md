# Database Schema & Data Dictionary — Dolo

**Local Storage Engine:** SQLite (via `sqflite`)  
**Cloud Storage Engine:** Supabase PostgreSQL (Relay only)  
**ID Generation:** UUIDv4 string on client for offline-first uniqueness  

---

## 1. Local SQLite Schema (DDL)

```sql
-- 1. Contacts & Shadow Members
CREATE TABLE contacts (
    id TEXT PRIMARY KEY,               -- UUIDv4
    name TEXT NOT NULL,
    phone TEXT,                        -- For WhatsApp URI generation
    raast_id TEXT,                     -- Raast ID / IBAN / Account Number
    avatar_initials TEXT NOT NULL,     -- e.g. "SH", "KP", "AL"
    avatar_color TEXT NOT NULL,        -- Hex string e.g. "#DDF7F2"
    is_shadow INTEGER NOT NULL DEFAULT 0, -- 1 if offline/unregistered peer
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 2. Shared Groups
CREATE TABLE groups (
    id TEXT PRIMARY KEY,               -- UUIDv4
    name TEXT NOT NULL,                -- e.g. "Hostel Gang"
    icon TEXT,                         -- Squircle category/icon tag
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    cloud_synced INTEGER NOT NULL DEFAULT 0
);

-- 3. Group Members & Custom Nicknames
CREATE TABLE group_members (
    id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL,
    contact_id TEXT NOT NULL,
    nickname TEXT NOT NULL,            -- Group-specific nickname e.g. "Kaptaan"
    joined_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
);

-- 4. Expenses & Transactions
CREATE TABLE expenses (
    id TEXT PRIMARY KEY,               -- UUIDv4
    group_id TEXT,                     -- NULL for 1-on-1 private khata
    payer_id TEXT NOT NULL,            -- Contact ID who paid
    title TEXT NOT NULL,               -- e.g. "Dinner at Bundu Khan"
    category TEXT NOT NULL,            -- Food, Hostel, Fuel, Printouts, Udhar
    total_amount INTEGER NOT NULL,     -- Stored in whole Rupees (integer)
    split_mode TEXT NOT NULL,          -- EQUAL, EXACT, PERCENT, ITEMIZED
    payment_method TEXT NOT NULL,      -- CASH, ONLINE
    receipt_image_path TEXT,           -- Sandboxed local file path
    is_settled INTEGER NOT NULL DEFAULT 0,
    settled_at TEXT,
    is_trashed INTEGER NOT NULL DEFAULT 0,
    trashed_at TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (payer_id) REFERENCES contacts(id)
);

-- 5. Individual Expense Splits
CREATE TABLE expense_splits (
    id TEXT PRIMARY KEY,
    expense_id TEXT NOT NULL,
    contact_id TEXT NOT NULL,
    share_amount INTEGER NOT NULL,     -- Rupee share for this person
    is_paid INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES contacts(id)
);

-- 6. Settlement Records
CREATE TABLE settlements (
    id TEXT PRIMARY KEY,
    payer_id TEXT NOT NULL,
    payee_id TEXT NOT NULL,
    total_paid INTEGER NOT NULL,
    payment_method TEXT NOT NULL,      -- CASH, ONLINE
    offset_amount INTEGER NOT NULL DEFAULT 0, -- Counter-debt deducted
    screenshot_path TEXT,              -- Local path
    settled_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 7. Offline Sync Journal (Append-Only)
CREATE TABLE sync_journal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id TEXT NOT NULL UNIQUE,     -- UUIDv4
    group_id TEXT NOT NULL,
    event_type TEXT NOT NULL,          -- CREATE_EXPENSE, SETTLE_EXPENSE, CANCEL_EXPENSE
    payload TEXT NOT NULL,             -- JSON string
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    is_synced INTEGER NOT NULL DEFAULT 0
);

-- 8. Key-Value App Settings & Preferences
CREATE TABLE app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
```

---

## 2. Automated Retention & Purge Queries

### A. Media Auto-Purge (Daily SQLite Worker)
```sql
-- Selects receipt photos older than configured threshold (e.g. 7 days)
SELECT id, receipt_image_path FROM expenses
WHERE is_settled = 1
  AND receipt_image_path IS NOT NULL
  AND settled_at <= datetime('now', '-7 days');

-- After Dart deletes file from disk:
UPDATE expenses 
SET receipt_image_path = NULL 
WHERE id = :expense_id;
```

### B. Settled Metadata Auto-Purge (Configurable 7/30 days)
```sql
-- Moves settled transactions past user retention window into Trash Bin
UPDATE expenses 
SET is_trashed = 1, trashed_at = datetime('now')
WHERE is_settled = 1 
  AND is_trashed = 0
  AND settled_at <= datetime('now', '-30 days');
```

### C. 30-Day Trash Hard Purge
```sql
-- Hard purges items in trash longer than 30 days
DELETE FROM expenses 
WHERE is_trashed = 1 
  AND trashed_at <= datetime('now', '-30 days');
```

---

## 3. Performance Indexes

```sql
CREATE INDEX idx_expenses_group_id ON expenses(group_id);
CREATE INDEX idx_expenses_settled ON expenses(is_settled, settled_at);
CREATE INDEX idx_expenses_trashed ON expenses(is_trashed, trashed_at);
CREATE INDEX idx_splits_expense ON expense_splits(expense_id);
CREATE INDEX idx_sync_unpushed ON sync_journal(is_synced);
```
