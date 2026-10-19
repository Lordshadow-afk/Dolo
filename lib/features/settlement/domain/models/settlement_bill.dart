/// Represents a single outstanding bill in a settle-up session.
class SettlementBill {
  final String id;
  final String description;
  final int amountRs;
  final String peerId;
  final String peerName;
  final DateTime date;
  final bool isSelected;

  const SettlementBill({
    required this.id,
    required this.description,
    required this.amountRs,
    required this.peerId,
    required this.peerName,
    required this.date,
    this.isSelected = true,
  });

  SettlementBill copyWith({bool? isSelected}) => SettlementBill(
        id: id,
        description: description,
        amountRs: amountRs,
        peerId: peerId,
        peerName: peerName,
        date: date,
        isSelected: isSelected ?? this.isSelected,
      );

  static List<SettlementBill> mock(String peerId, String peerName) => [
        SettlementBill(
          id: 'bill_1',
          description: 'Biryani dinner',
          amountRs: 800,
          peerId: peerId,
          peerName: peerName,
          date: DateTime.now().subtract(const Duration(days: 3)),
          isSelected: true,
        ),
        SettlementBill(
          id: 'bill_2',
          description: 'Rickshaw split',
          amountRs: 500,
          peerId: peerId,
          peerName: peerName,
          date: DateTime.now().subtract(const Duration(days: 1)),
          isSelected: true,
        ),
        SettlementBill(
          id: 'bill_3',
          description: 'Printouts',
          amountRs: 300,
          peerId: peerId,
          peerName: peerName,
          date: DateTime.now(),
          isSelected: false,
        ),
      ];
}
