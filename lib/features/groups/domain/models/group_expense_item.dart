class GroupExpenseItem {
  final String id;
  final String title;
  final String categoryTag; // FD for Food, HS for Hostel, PR for Printouts, FL for Fuel, UD for Udhar
  final String subtitle; // e.g. "Paid by Sheeda, Equal"
  final int yourShare; // -ve means you owe, +ve means you are owed
  final bool isSettled;

  const GroupExpenseItem({
    required this.id,
    required this.title,
    required this.categoryTag,
    required this.subtitle,
    required this.yourShare,
    this.isSettled = false,
  });
}

class GroupMemberDisplay {
  final String id;
  final String name;
  final String nickname;
  final String initials;
  final int netBalance; // +ve means owed, -ve means owes
  final bool isShadow;

  const GroupMemberDisplay({
    required this.id,
    required this.name,
    required this.nickname,
    required this.initials,
    this.netBalance = 0,
    this.isShadow = false,
  });
}
