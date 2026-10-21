import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../home/domain/models/dashboard_summary.dart';

final dashboardProvider = FutureProvider<DashboardSummary>((ref) async {
  final db = await AppDatabase.instance.database;

  // 1. Calculate Owed total (money others owe you)
  final owedResult = await db.rawQuery('''
    SELECT SUM(amount_rs) as total 
    FROM expenses 
    WHERE is_deleted = 0 AND type = 'owed'
  ''');

  // 2. Calculate Owe total (money you owe others)
  final oweResult = await db.rawQuery('''
    SELECT SUM(amount_rs) as total 
    FROM expenses 
    WHERE is_deleted = 0 AND type = 'owe'
  ''');

  // 3. Count settled transactions
  final settledCountResult = await db.rawQuery('''
    SELECT COUNT(*) as count 
    FROM settlements
  ''');

  final int totalOwed = (owedResult.first['total'] as num?)?.toInt() ?? 0;
  final int totalOwe = (oweResult.first['total'] as num?)?.toInt() ?? 0;
  final int settledCount = (settledCountResult.first['count'] as num?)?.toInt() ?? 0;

  // 4. Query dynamic feed entries from expenses table
  final List<Map<String, dynamic>> expenseRows = await db.query(
    'expenses',
    where: 'is_deleted = 0',
    orderBy: 'created_at DESC',
    limit: 20,
  );

  final List<DashboardFeedItem> feedItems = expenseRows.map((row) {
    final String title = row['title'] as String? ?? 'Expense';
    final int amount = (row['amount_rs'] as num?)?.toInt() ?? 0;
    final String typeStr = row['type'] as String? ?? 'friend';
    final bool isSettled = (row['is_settled'] as int? ?? 0) == 1;

    FeedItemType type;
    if (isSettled) {
      type = FeedItemType.settled;
    } else if (typeStr == 'group') {
      type = FeedItemType.group;
    } else if (typeStr == 'pending') {
      type = FeedItemType.pending;
    } else {
      type = FeedItemType.friend;
    }

    final String initials = title.trim().isNotEmpty
        ? title.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'EX';

    return DashboardFeedItem(
      id: row['id'].toString(),
      title: title,
      subtitle: row['category'] as String? ?? 'General',
      initials: initials,
      amount: isSettled ? null : (typeStr == 'owe' ? -amount : amount),
      isSettled: isSettled,
      type: type,
      receiptPath: row['receipt_path'] as String?,
    );
  }).toList();

  return DashboardSummary(
    userName: 'Ashir',
    netStanding: totalOwed - totalOwe,
    totalOwed: totalOwed,
    totalOwe: totalOwe,
    settledCount: settledCount,
    feedItems: feedItems,
  );
});