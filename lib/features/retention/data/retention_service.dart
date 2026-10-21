import 'dart:io';
import '../../../core/database/app_database.dart';

class RetentionService {
  final AppDatabase _dbProvider = AppDatabase.instance;

  /// Purges soft-deleted records and receipt files older than 30 days
  Future<void> runAutoPurgeTask() async {
    final db = await _dbProvider.database;
    final cutoffDate = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String();

    final expiredItems = await db.query(
      'expenses',
      columns: ['receipt_path'],
      where: 'is_deleted = 1 AND deleted_at <= ?',
      whereArgs: [cutoffDate],
    );

    for (var item in expiredItems) {
      final path = item['receipt_path'] as String?;
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    await db.delete(
      'expenses',
      where: 'is_deleted = 1 AND deleted_at <= ?',
      whereArgs: [cutoffDate],
    );
  }
}