enum FeedItemType {
  friend,
  group,
  settled,
  pending,
}

class DashboardFeedItem {
  final String id;
  final String title;
  final String subtitle;
  final String initials;
  final int? amount; // positive means owed to you, negative means you owe, null if settled
  final bool isSettled;
  final FeedItemType type;
  final String? receiptPath;

  const DashboardFeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.initials,
    this.amount,
    this.isSettled = false,
    required this.type,
    this.receiptPath,
  });
}

class DashboardSummary {
  final String userName;
  final int netStanding; // in whole Rupees (+ve or -ve)
  final int totalOwed;
  final int totalOwe;
  final int settledCount;
  final List<DashboardFeedItem> feedItems;

  const DashboardSummary({
    required this.userName,
    required this.netStanding,
    required this.totalOwed,
    required this.totalOwe,
    required this.settledCount,
    required this.feedItems,
  });

  factory DashboardSummary.mock() {
    return const DashboardSummary(
      userName: 'Ali',
      netStanding: 4250,
      totalOwed: 9100,
      totalOwe: 4850,
      settledCount: 12,
      feedItems: [
        DashboardFeedItem(
          id: '1',
          title: 'Sheeda',
          subtitle: 'Lunch, 2 receipts',
          initials: 'SH',
          amount: 1200,
          isSettled: false,
          type: FeedItemType.friend,
        ),
        DashboardFeedItem(
          id: '2',
          title: 'Hostel Gang',
          subtitle: 'Mess bill, 4 members',
          initials: 'HG',
          amount: -850,
          isSettled: false,
          type: FeedItemType.group,
        ),
        DashboardFeedItem(
          id: '3',
          title: 'Kaptaan',
          subtitle: 'Settled in cash',
          initials: 'KP',
          amount: null,
          isSettled: true,
          type: FeedItemType.settled,
        ),
        DashboardFeedItem(
          id: '4',
          title: 'Fuel trip',
          subtitle: 'Pending, 3 days',
          initials: 'FZ',
          amount: 2400,
          isSettled: false,
          type: FeedItemType.pending,
        ),
      ],
    );
  }
}
