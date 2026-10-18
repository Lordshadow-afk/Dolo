class KhataTimelineEntry {
  final String id;
  final String title;
  final String category; // Udhar, Lunch, Printouts, Fuel, etc.
  final DateTime date;
  final int amount; // in whole Rupees
  final bool isLent; // true if I lent (owed to me +), false if I borrowed (-)
  final bool isSettled;
  final String? receiptPath;

  const KhataTimelineEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isLent,
    this.isSettled = false,
    this.receiptPath,
  });
}
