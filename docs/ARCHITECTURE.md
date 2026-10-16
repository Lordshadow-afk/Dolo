# System Architecture & Technical Specification — Dolo

**Core Architecture:** Offline-First Clean Architecture  
**State Management:** Riverpod 2.x  
**Local Storage:** SQLite (`sqflite`)  
**Cloud Relay:** Supabase (Free Tier strictly for shared groups)  
**Cost Model:** $0 Infrastructure  

---

## 1. High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter UI Presentation                  │
│       (Cockpit, Glass Triad, Surface Sheet, Settle Up)      │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                Riverpod State Management                    │
│      (DashboardProvider, KhataProvider, ExpenseProvider)    │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               Domain & Repository Layer                     │
│    (ExpenseRepository, KhataRepository, SyncRepository)     │
└───────────────┬─────────────────────────────┬───────────────┘
                │                             │
                ▼                             ▼
┌──────────────────────────────┐ ┌────────────────────────────┐
│   Local SQLite (sqflite)     │ │  Device Hardware & Media   │
│  - Single Source of Truth    │ │  - Camera / Gallery        │
│  - 100% Offline Access       │ │  - flutter_image_compress  │
│  - Append-Only Sync Journal  │ │  - Local Filesystem Sandbox│
└───────────────┬──────────────┘ └────────────────────────────┘
                │
         (Background Sync)
                │
                ▼
┌──────────────────────────────┐ ┌────────────────────────────┐
│    Supabase Cloud Relay      │ │ Native OS Integrations     │
│  - Free-Tier Auth (Google)   │ │ - WhatsApp URL Launcher    │
│  - Shared Group Events Relay │ │ - RepaintBoundary to PNG   │
│  - Member Nicknames Sync     │ │ - Dynamic App Icon Aliases │
└──────────────────────────────┘ └────────────────────────────┘
```

---

## 2. The $0 Cloud & Offline-First Guarantees

1. **Zero Cloud File Storage:**  
   Bill images and payment screenshots are compressed on-device using `flutter_image_compress` (target `< 150 KB`) and stored in the app’s sandboxed documents directory. Receipts are never uploaded to cloud buckets; they are shared peer-to-peer via WhatsApp.
2. **Zero Messaging API Cost:**  
   Zero reliance on paid SMS or WhatsApp Business APIs. Communications trigger the OS native WhatsApp intent via URI scheme `whatsapp://send` and `https://wa.me/` with pre-filled slips.
3. **Sovereign Personal Khatas:**  
   Private 1-on-1 lending records exist solely on the phone's SQLite database. They are never sent to Supabase, guaranteeing absolute privacy and zero server load.

---

## 3. Append-Only Sync Protocol (Conflict-Free Ledger)

In collaborative student groups, offline expense creation leads to sync collisions if simple `UPDATE` queries are used. Dolo solves this with an **Append-Only Event Sourcing Journal**:

1. Every action creates an immutable event record:
   * `EVENT_EXPENSE_CREATED`
   * `EVENT_EXPENSE_EDITED`
   * `EVENT_EXPENSE_CANCELLED`
   * `EVENT_SETTLEMENT_RECORDED`
2. Each event contains:
   * `event_id`: Unique UUIDv4 generated on the client.
   * `group_id`: Target group identifier.
   * `timestamp`: ISO-8601 UTC timestamp.
   * `payload`: JSON payload of the action.
3. When internet is active:
   * Client pushes uncommitted local events to Supabase `group_events` table.
   * Realtime listeners stream new events to other group members.
   * Local SQLite tables ingest incoming events in chronological sequence.

---

## 4. Core Algorithms

### A. Automated Remainder Split Algorithm (Whole-Rupee Math)
To prevent balance drift from floating-point division (e.g. Rs 1,000 / 3 = 333.33):
```dart
List<int> calculateEqualSplit(int totalAmount, int memberCount) {
  int baseShare = totalAmount ~/ memberCount; // Integer division
  int remainder = totalAmount % memberCount;

  List<int> shares = List.filled(memberCount, baseShare);
  // Payer or first debtors absorb the 1-rupee remainder
  for (int i = 0; i < remainder; i++) {
    shares[i] += 1;
  }
  return shares;
}
```

### B. Greedy Debt Simplification Algorithm (Min-Cash-Flow)
Reduces a web of multi-person group debts to the minimum number of transactions:
1. Compute the net balance $B_i$ for each member:
   $$B_i = \sum \text{Credited} - \sum \text{Debited}$$
2. Divide members into two heaps:
   * **Creditors** ($B_i > 0$, sorted descending)
   * **Debtors** ($B_j < 0$, sorted ascending by absolute value)
3. Greedily match the largest creditor with the largest debtor:
   $$\text{Settlement} = \min(B_{\text{max\_creditor}}, |B_{\text{max\_debtor}}|)$$
4. Update balances and repeat until all balances reach zero. This reduces an $N \times (N-1)$ debt web down to at most $N-1$ payments.

### C. Dynamic Alternative App Icon Architecture
* **Android:** Implemented via `<activity-alias>` tags in `AndroidManifest.xml` targeting distinct launcher icons (`.MainActivityTeal`, `.MainActivityMidnight`, `.MainActivityKhata`). The active alias is enabled dynamically while others are disabled via `PackageManager`.
* **iOS:** Implemented via `setAlternateIconName` using `CFBundleIcons` configuration in `Info.plist`.
