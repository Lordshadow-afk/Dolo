/// SQLite Table names, column definitions and DDL creation scripts.
class DbTables {
  DbTables._();

  // Table Names
  static const String contacts = 'contacts';
  static const String groups = 'groups';
  static const String groupMembers = 'group_members';
  static const String expenses = 'expenses';
  static const String expenseSplits = 'expense_splits';
  static const String settlements = 'settlements';
  static const String syncJournal = 'sync_journal';
  static const String appSettings = 'app_settings';

  // DDL Scripts
  static const String createContactsTable = '''
    CREATE TABLE $contacts (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      phone TEXT,
      raast_id TEXT,
      avatar_initials TEXT NOT NULL,
      avatar_color TEXT NOT NULL,
      is_shadow INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    );
  ''';

  static const String createGroupsTable = '''
    CREATE TABLE $groups (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT,
      created_at TEXT NOT NULL,
      cloud_synced INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createGroupMembersTable = '''
    CREATE TABLE $groupMembers (
      id TEXT PRIMARY KEY,
      group_id TEXT NOT NULL,
      contact_id TEXT NOT NULL,
      nickname TEXT NOT NULL,
      joined_at TEXT NOT NULL,
      FOREIGN KEY (group_id) REFERENCES $groups(id) ON DELETE CASCADE,
      FOREIGN KEY (contact_id) REFERENCES $contacts(id) ON DELETE CASCADE
    );
  ''';

  static const String createExpensesTable = '''
    CREATE TABLE $expenses (
      id TEXT PRIMARY KEY,
      group_id TEXT,
      payer_id TEXT NOT NULL,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      total_amount INTEGER NOT NULL,
      split_mode TEXT NOT NULL,
      payment_method TEXT NOT NULL,
      receipt_image_path TEXT,
      is_settled INTEGER NOT NULL DEFAULT 0,
      settled_at TEXT,
      is_trashed INTEGER NOT NULL DEFAULT 0,
      trashed_at TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (payer_id) REFERENCES $contacts(id)
    );
  ''';

  static const String createExpenseSplitsTable = '''
    CREATE TABLE $expenseSplits (
      id TEXT PRIMARY KEY,
      expense_id TEXT NOT NULL,
      contact_id TEXT NOT NULL,
      share_amount INTEGER NOT NULL,
      is_paid INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (expense_id) REFERENCES $expenses(id) ON DELETE CASCADE,
      FOREIGN KEY (contact_id) REFERENCES $contacts(id)
    );
  ''';

  static const String createSettlementsTable = '''
    CREATE TABLE $settlements (
      id TEXT PRIMARY KEY,
      payer_id TEXT NOT NULL,
      payee_id TEXT NOT NULL,
      total_paid INTEGER NOT NULL,
      payment_method TEXT NOT NULL,
      offset_amount INTEGER NOT NULL DEFAULT 0,
      screenshot_path TEXT,
      settled_at TEXT NOT NULL
    );
  ''';

  static const String createSyncJournalTable = '''
    CREATE TABLE $syncJournal (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      event_id TEXT NOT NULL UNIQUE,
      group_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      payload TEXT NOT NULL,
      created_at TEXT NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createAppSettingsTable = '''
    CREATE TABLE $appSettings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
  ''';

  // Indexes for high performance
  static const List<String> createIndexes = [
    'CREATE INDEX idx_expenses_group_id ON $expenses(group_id);',
    'CREATE INDEX idx_expenses_settled ON $expenses(is_settled, settled_at);',
    'CREATE INDEX idx_expenses_trashed ON $expenses(is_trashed, trashed_at);',
    'CREATE INDEX idx_splits_expense ON $expenseSplits(expense_id);',
    'CREATE INDEX idx_sync_unpushed ON $syncJournal(is_synced);',
  ];
}
