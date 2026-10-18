import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/khata_timeline_entry.dart';

class KhataState {
  final String peerName;
  final String peerInitials;
  final String? peerPhone;
  final String activeTab; // 'Open' or 'Cleared'
  final List<KhataTimelineEntry> entries;

  const KhataState({
    required this.peerName,
    required this.peerInitials,
    this.peerPhone,
    required this.activeTab,
    required this.entries,
  });

  /// Net standing: positive means peer owes you (+), negative means you owe peer (-)
  int get netStanding {
    int total = 0;
    for (final e in entries) {
      if (e.isSettled) continue;
      if (e.isLent) {
        total += e.amount;
      } else {
        total -= e.amount;
      }
    }
    return total;
  }

  List<KhataTimelineEntry> get filteredEntries {
    if (activeTab == 'Cleared') {
      return entries.where((e) => e.isSettled).toList();
    }
    return entries.where((e) => !e.isSettled).toList();
  }

  KhataState copyWith({
    String? peerName,
    String? peerInitials,
    String? peerPhone,
    String? activeTab,
    List<KhataTimelineEntry>? entries,
  }) {
    return KhataState(
      peerName: peerName ?? this.peerName,
      peerInitials: peerInitials ?? this.peerInitials,
      peerPhone: peerPhone ?? this.peerPhone,
      activeTab: activeTab ?? this.activeTab,
      entries: entries ?? this.entries,
    );
  }
}

final khataDetailProvider = StateNotifierProvider.family<KhataDetailNotifier, KhataState, String>(
  (ref, peerId) => KhataDetailNotifier(peerId),
);

class KhataDetailNotifier extends StateNotifier<KhataState> {
  final String peerId;

  KhataDetailNotifier(this.peerId)
      : super(
          KhataState(
            peerName: peerId == 'sheeda' ? 'Sheeda' : 'Kaptaan',
            peerInitials: peerId == 'sheeda' ? 'SH' : 'KP',
            peerPhone: '03001234567',
            activeTab: 'Open',
            entries: [
              KhataTimelineEntry(
                id: '1',
                title: 'Cash loan',
                category: 'Udhar',
                date: DateTime(2026, 10, 12),
                amount: 800,
                isLent: true,
                isSettled: false,
              ),
              KhataTimelineEntry(
                id: '2',
                title: 'Lunch',
                category: 'Lunch',
                date: DateTime(2026, 10, 14),
                amount: 650,
                isLent: true,
                isSettled: false,
                receiptPath: 'mock_receipt.jpg',
              ),
              KhataTimelineEntry(
                id: '3',
                title: 'Printouts',
                category: 'Printouts',
                date: DateTime(2026, 10, 15),
                amount: 250,
                isLent: false, // You borrowed
                isSettled: false,
              ),
            ],
          ),
        );

  void setTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  void addEntry({
    required int amount,
    required String title,
    required String category,
    required bool isLent,
  }) {
    final newEntry = KhataTimelineEntry(
      id: const Uuid().v4(),
      title: title,
      category: category,
      date: DateTime.now(),
      amount: amount,
      isLent: isLent,
      isSettled: false,
    );
    state = state.copyWith(entries: [newEntry, ...state.entries]);
  }

  void deleteEntry(String id) {
    state = state.copyWith(
      entries: state.entries.where((e) => e.id != id).toList(),
    );
  }

  void settleAll() {
    state = state.copyWith(
      entries: state.entries.map((e) => KhataTimelineEntry(
        id: e.id,
        title: e.title,
        category: e.category,
        date: e.date,
        amount: e.amount,
        isLent: e.isLent,
        isSettled: true,
        receiptPath: e.receiptPath,
      )).toList(),
    );
  }
}
