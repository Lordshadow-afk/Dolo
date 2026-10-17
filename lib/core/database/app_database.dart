import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'tables.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const String _databaseName = 'dolo_khata.db';
  static const int _databaseVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute(DbTables.createContactsTable);
      await txn.execute(DbTables.createGroupsTable);
      await txn.execute(DbTables.createGroupMembersTable);
      await txn.execute(DbTables.createExpensesTable);
      await txn.execute(DbTables.createExpenseSplitsTable);
      await txn.execute(DbTables.createSettlementsTable);
      await txn.execute(DbTables.createSyncJournalTable);
      await txn.execute(DbTables.createAppSettingsTable);

      for (final indexQuery in DbTables.createIndexes) {
        await txn.execute(indexQuery);
      }

      // Seed Default User Contact ("You")
      final now = DateTime.now().toIso8601String();
      await txn.insert(DbTables.contacts, {
        'id': 'user_self',
        'name': 'You',
        'phone': '',
        'raast_id': '',
        'avatar_initials': 'AL',
        'avatar_color': '#00D1B2',
        'is_shadow': 0,
        'created_at': now,
      });

      // Seed Default App Settings
      await txn.insert(DbTables.appSettings, {
        'key': 'theme_mode',
        'value': 'system',
      });
      await txn.insert(DbTables.appSettings, {
        'key': 'auto_purge_images_days',
        'value': '7',
      });
      await txn.insert(DbTables.appSettings, {
        'key': 'auto_purge_metadata_days',
        'value': 'never',
      });
      await txn.insert(DbTables.appSettings, {
        'key': 'active_app_icon',
        'value': 'interlocking_coins',
      });
    });
  }

  /// Close database instance when needed
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
