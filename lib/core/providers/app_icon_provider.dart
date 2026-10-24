import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_icons_config.dart';
import '../database/app_database.dart';
import '../database/tables.dart';

final appIconProvider = StateNotifierProvider<AppIconNotifier, AppIconOption>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppIconNotifier(db);
});

class AppIconNotifier extends StateNotifier<AppIconOption> {
  final AppDatabase _dbHelper;

  AppIconNotifier(this._dbHelper) : super(AppIconsConfig.defaultIcon) {
    _loadSavedIcon();
  }

  Future<void> _loadSavedIcon() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        DbTables.appSettings,
        where: 'key = ?',
        whereArgs: ['active_app_icon'],
        limit: 1,
      );

      if (results.isNotEmpty) {
        final iconId = results.first['value'] as String?;
        if (iconId != null) {
          state = AppIconsConfig.getById(iconId);
        }
      }
    } catch (_) {
      // Keep default icon if database query fails or during cold start
    }
  }

  Future<void> setAppIcon(AppIconOption icon) async {
    state = icon;
    try {
      final db = await _dbHelper.database;
      // INSERT OR REPLACE to upsert the single settings row
      await db.rawInsert('''
        INSERT OR REPLACE INTO ${DbTables.appSettings} (key, value)
        VALUES ('active_app_icon', ?)
      ''', [icon.id]);
    } catch (_) {
      // Log or ignore offline persistence error
    }
  }
}
