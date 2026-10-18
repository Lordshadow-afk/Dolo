import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_summary.dart';

final activeFilterProvider = StateProvider<String>((ref) => 'All');

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  // In initial phase, provides rich mock state matching design bundle.
  // In Step 4/5/6, connects directly to SQLite queries.
  return DashboardSummary.mock();
});

final filteredFeedProvider = Provider<List<DashboardFeedItem>>((ref) {
  final summaryAsync = ref.watch(dashboardSummaryProvider);
  final activeFilter = ref.watch(activeFilterProvider);

  return summaryAsync.maybeWhen(
    data: (summary) {
      if (activeFilter == 'All') return summary.feedItems;
      if (activeFilter == 'Friends') {
        return summary.feedItems.where((i) => i.type == FeedItemType.friend).toList();
      }
      if (activeFilter == 'Groups') {
        return summary.feedItems.where((i) => i.type == FeedItemType.group).toList();
      }
      if (activeFilter == 'Pending') {
        return summary.feedItems.where((i) => !i.isSettled).toList();
      }
      return summary.feedItems;
    },
    orElse: () => const [],
  );
});
