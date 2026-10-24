import 'dart:io';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';

/// Handles auto-purge of soft-deleted (trashed) expenses and their receipt files.
/// Purges records that have been trashed for more than [purgeDaysThreshold] days.
class RetentionService {
  final AppDatabase _dbProvider = AppDatabase.instance;

  static const int purgeDaysThreshold = 30;

  /// Purges soft-deleted records and associated receipt image files older than
  /// [purgeDaysThreshold] days. Uses correct schema columns: `is_trashed` / `trashed_at`.
  Future<void> runAutoPurgeTask() async {
    final db = await _dbProvider.database;
    final cutoffDate = DateTime.now()
        .subtract(const Duration(days: purgeDaysThreshold))
        .toIso8601String();

    // Fetch receipt paths before deletion so we can clean up local files
    final expiredItems = await db.query(
      DbTables.expenses,
      columns: ['receipt_image_path'],
      where: 'is_trashed = 1 AND trashed_at <= ?',
      whereArgs: [cutoffDate],
    );

    // Delete local receipt image files
    for (final item in expiredItems) {
      final path = item['receipt_image_path'] as String?;
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // Permanently delete trashed expenses from SQLite
    await db.delete(
      DbTables.expenses,
      where: 'is_trashed = 1 AND trashed_at <= ?',
      whereArgs: [cutoffDate],
    );
  }

  /// Soft-delete (trash) a single expense by [expenseId].
  Future<void> trashExpense(String expenseId) async {
    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      DbTables.expenses,
      {'is_trashed': 1, 'trashed_at': now},
      where: 'id = ?',
      whereArgs: [expenseId],
    );
  }

  /// Restore a trashed expense back to active state.
  Future<void> restoreExpense(String expenseId) async {
    final db = await _dbProvider.database;
    await db.update(
      DbTables.expenses,
      {'is_trashed': 0, 'trashed_at': null},
      where: 'id = ?',
      whereArgs: [expenseId],
    );
  }
}
