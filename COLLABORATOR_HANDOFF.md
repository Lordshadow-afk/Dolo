# Dolo — Collaborator Handoff Document

*Last updated: 2026-10-24*

---

## 📌 Project Overview

**Dolo** is a $0-budget, offline-first Flutter app for Pakistani student peer lending (Khata) and expense splitting.

**Key rules every collaborator must follow:**
- 💰 **All currency is whole-rupee integers** — never use `double` for money. Always `int`. Display as `Rs 1,200` never `Rs 1200.00`
- 📵 **No cloud image uploads** — receipts stay on device, compressed to `< 150 KB`
- 📴 **Offline-first** — private khata data stays in local SQLite only. Only group sync events go to Supabase
- 🗃️ **Schema columns** — always use `total_amount` (not `amount_rs`), `is_trashed`/`trashed_at` (not `is_deleted`/`deleted_at`), `receipt_image_path` (not `receipt_path`)
- 🎨 **Design system** — use only colors from `AppColors`, radii from `AppDimensions`, typography from `AppTypography`. No hardcoded hex values

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                         ← App entry point
├── app.dart                          ← DoloApp + themeModeProvider
├── core/
│   ├── algorithms/                   ← Split/debt math (pure Dart, no Flutter)
│   ├── config/app_config.dart        ← AppConfig.init() loads .env
│   ├── constants/
│   │   ├── app_colors.dart           ← ALL color tokens
│   │   ├── app_dimensions.dart       ← ALL radii + size constants
│   │   ├── app_typography.dart       ← Plus Jakarta Sans setup
│   │   └── app_icons_config.dart     ← 14 SVG icon catalog
│   ├── database/
│   │   ├── app_database.dart         ← SQLite singleton (AppDatabase.instance)
│   │   └── tables.dart               ← ALL DDL + table name constants
│   ├── models/                       ← Shared domain models
│   ├── providers/app_icon_provider.dart ← AppIconNotifier
│   ├── theme/app_theme.dart          ← Light + Dark ThemeData
│   └── utils/image_compressor_helper.dart ← Camera/gallery + compress
├── features/
│   ├── navigation/main_scaffold.dart ← 4-tab BottomNavigationBar
│   ├── home/                         ← Tab 0 (DONE - mock data)
│   ├── groups/                       ← Tab 1 (DONE)
│   ├── settlement/                   ← Screens: settle-up, receipt, profile, spends
│   ├── khata_1on1/                   ← 1-on-1 lending screen (DONE)
│   ├── expense/                      ← Add expense screen (DONE)
│   ├── profile/                      ← Profile provider (DONE)
│   └── retention/                    ← RetentionService (DONE)
```

### Key State Management Pattern
```dart
// Family provider (per entity) — used for khata and group detail screens
final myProvider = StateNotifierProvider.family<MyNotifier, MyState, String>(
  (ref, entityId) => MyNotifier(entityId),
);

// Watch in widget:
final state = ref.watch(myProvider(entityId));
final notifier = ref.read(myProvider(entityId).notifier);
```

---

## 📋 SQLite Schema Quick Reference

> Full DDL is in `lib/core/database/tables.dart`

| Table | Key Columns |
|-------|-------------|
| `contacts` | `id`, `name`, `phone`, `raast_id`, `avatar_initials`, `is_shadow` |
| `groups` | `id`, `name`, `icon`, `cloud_synced` |
| `group_members` | `group_id`, `contact_id`, `nickname` |
| `expenses` | `id`, `group_id`, `payer_id`, `title`, `category`, **`total_amount`** (INTEGER), `split_mode`, `payment_method`, `receipt_image_path`, `is_settled`, `settled_at`, **`is_trashed`**, **`trashed_at`** |
| `expense_splits` | `expense_id`, `contact_id`, `share_amount` (INTEGER), `is_paid` |
| `settlements` | `payer_id`, `payee_id`, `total_paid` (INTEGER), `payment_method`, `offset_amount`, `screenshot_path`, `settled_at` |
| `sync_journal` | `event_id`, `group_id`, `event_type`, `payload` (JSON), `is_synced` |
| `app_settings` | `key` (PK), `value` |

---

## 🚨 TASK 1 — Fix Chrome/Web SQLite
**Priority: IMMEDIATE**  
**File to modify:** `e:\antigravity project\lib\main.dart` ✅ (already updated)  
**File to modify:** `e:\antigravity project\pubspec.yaml` ✅ (already updated)

### What was done
`sqflite_common_ffi_web: ^0.4.5` was added to `pubspec.yaml` and `main.dart` now initializes `databaseFactoryFfiWeb` when running on Chrome.

### What YOU need to do
1. Run `flutter pub get` in the project directory
2. Run the following command to add the required WASM SQLite files to the web folder:
   ```bash
   dart run sqflite_common_ffi_web:setup
   ```
3. Hot restart the app (`R` in terminal or `Ctrl+Shift+F5` in VS Code)

### Why this matters
`sqflite` is a native package. Chrome/web cannot use it without the WASM bridge. Without this fix every screen that reads from SQLite shows: *"Bad state: databaseFactory not initialized"*

---

## 🚨 TASK 2 — Replace Mock Data on Home Screen
**Priority: HIGH**  
**File to modify:** `lib/features/home/presentation/providers/dashboard_provider.dart`

### Current state (broken)
```dart
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  return DashboardSummary.mock(); // ← hardcoded fake data
});
```

### What to build
Replace the mock with real SQLite queries. The provider should:

1. Query total money **owed to you** (you paid, others haven't settled):
   ```sql
   SELECT SUM(es.share_amount) FROM expense_splits es
   JOIN expenses e ON e.id = es.expense_id
   WHERE e.payer_id = 'user_self'
     AND es.contact_id != 'user_self'
     AND es.is_paid = 0
     AND e.is_trashed = 0
   ```

2. Query total money **you owe** (others paid, you haven't settled):
   ```sql
   SELECT SUM(es.share_amount) FROM expense_splits es
   JOIN expenses e ON e.id = es.expense_id
   WHERE e.payer_id != 'user_self'
     AND es.contact_id = 'user_self'
     AND es.is_paid = 0
     AND e.is_trashed = 0
   ```

3. Count settled transactions from `settlements` table

4. Build the feed list from recent `expenses` (join with `contacts` for names/initials), ordered by `created_at DESC`, limit 20

### Reference models
- `DashboardSummary` — `lib/features/home/domain/models/dashboard_summary.dart`
- `DashboardFeedItem` — same file. Fields: `id`, `title`, `subtitle`, `initials`, `amount` (int?), `isSettled`, `type` (FeedItemType enum), `receiptPath`

> **Note:** Keep `DashboardSummary.mock()` in the model file — it's used by widget tests.

---

## 🚨 TASK 3 — Build Receipt View Screen (Screen 4)
**Priority: HIGH**  
**File to create:** `lib/features/settlement/presentation/screens/receipt_view_screen.dart`

### What it is
A full-screen "digital ticket" that appears after the user confirms a settlement. It shows a dashed-border receipt and lets the user share it as a PNG via WhatsApp.

### Design spec
- **Background:** two-tone (dark cockpit top 35%, white bottom 65%) — same as home screen
- **Ticket widget:** already exists at `lib/features/settlement/presentation/widgets/tactile_ticket_receipt.dart` — just use `TactileTicketReceipt` widget
- **Dashed border:** `2px dashed #CBD5E1`, `24px` radius (use `AppDimensions.ticketRadius`)
- **Status badge:** `SETTLED` in Indigo, `PENDING` in Rose
- **Auto-purge tag:** small text "Auto-purge in 7 days" below badge
- **Action buttons:** "Share as PNG" (Mint button) + "Done" (close screen)

### Constructor signature
```dart
class ReceiptViewScreen extends StatelessWidget {
  final String peerId;
  final String peerName;
  final int amountRs;           // whole rupees — int only
  final String paymentMethod;   // 'Cash' or 'Online Transfer'
  final bool isSettled;

  const ReceiptViewScreen({ ... });

  // Static helper to push the screen
  static void show(BuildContext context, {
    required String peerId,
    required String peerName,
    required int amountRs,
    required String paymentMethod,
    required bool isSettled,
  }) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptViewScreen(...)));
  }
}
```

### How it connects
`SettleUpSheet` calls `ReceiptViewScreen.show(...)` on the "Confirm & send slip" button press (see `lib/features/settlement/presentation/screens/settle_up_sheet.dart` — the `_ConfirmCTA.onConfirm` callback).

Currently the settle_up_sheet just shows a SnackBar as a temporary placeholder — replace that with `ReceiptViewScreen.show(...)`.

---

## 📋 TASK 4 — Trash Screen (Screen 8)
**Priority: MEDIUM**  
**File to create:** `lib/features/trash/presentation/screens/trash_screen.dart`

### What it is
A list of expenses the user soft-deleted (swiped away). They have 30 days to restore before permanent deletion.

### Data source
```dart
final trashedExpensesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = await AppDatabase.instance.database;
  return db.query(
    DbTables.expenses,
    where: 'is_trashed = 1',
    orderBy: 'trashed_at DESC',
  );
});
```

### UI requirements
- AppBar titled "Trash"
- Each tile shows: expense title, category, `total_amount` in Rs, days remaining until purge
- Days remaining calculation: `30 - DateTime.now().difference(DateTime.parse(trashed_at)).inDays`
- **Swipe right** → Restore (calls `RetentionService().restoreExpense(id)`)
- **Swipe left** → Delete Forever (calls `db.delete(...)` directly, no soft-delete)
- Empty state: illustration + "Trash is empty" text
- Use `RetentionService` from `lib/features/retention/data/retention_service.dart` — it has `trashExpense()` and `restoreExpense()` already built

### Where to navigate to it
Add a "Trash" row in the Profile screen settings list (`lib/features/settlement/presentation/screens/profile_screen.dart`) — the `_SettingsRow` for it is already there with `onTap: () {}` — wire it up.

---

## 📋 TASK 5 — Storage & Sync Screen (Screen 14)
**Priority: MEDIUM**  
**File to create:** `lib/features/settings/presentation/screens/storage_sync_screen.dart`

### What to build
- **Section: Auto-purge**
  - Slider: "Delete receipt images after X days" (7 / 14 / 30 / Never) → saves to `app_settings` key `auto_purge_images_days`
  - Slider: "Delete expense records after X days" (30 / 60 / 90 / Never) → saves to `app_settings` key `auto_purge_metadata_days`
- **Section: Export**
  - Button: "Export all data as CSV" → builds a CSV string from `expenses` + `expense_splits` tables and shares via `share_plus`
- **Section: Sync**
  - Shows count of unsynced journal entries: `SELECT COUNT(*) FROM sync_journal WHERE is_synced = 0`
  - Button: "Sync now" (placeholder for Step 10 Supabase work)

### Saving settings pattern
```dart
final db = await AppDatabase.instance.database;
await db.rawInsert(
  'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
  ['auto_purge_images_days', '14'],
);
```

---

## 📋 TASK 6 — Notifications Screen (Screen 11)
**Priority: MEDIUM**  
**File to create:** `lib/features/settings/presentation/screens/notifications_screen.dart`

### What to build
- **Toggle: Local push reminders** — `Switch` widget. When ON, show a sub-option for reminder frequency (Daily / Weekly)
- **WhatsApp tone presets** — 3 selectable cards:
  - 🤝 **Friendly** — "Hey! Just a reminder about the Rs {amount} from our last hangout 😊"
  - 🎓 **Campus Urdu** — "Bhai, woh Rs {amount} yaad hai? Settle kar do yaar"
  - 📋 **Firm** — "Payment of Rs {amount} is overdue. Please settle at your earliest."
- Tapping a card previews the message in a dialog and saves the selection to `app_settings` key `whatsapp_tone`
- No actual notification scheduling needed yet — just save the preference

---

## 📋 TASK 7 — Appearance Screen (Screen 12) + App Icon Picker (Screen 13)
**Priority: MEDIUM**  
**File to create:** `lib/features/settings/presentation/screens/appearance_screen.dart`

### Appearance section
- **Theme picker** — 3 options: Light / Dark / System → updates `themeModeProvider` in `lib/app.dart` and saves to `app_settings` key `theme_mode`
- **Accent color** — 5 color swatches: Mint `#00D1B2`, Rose `#F43F5E`, Indigo `#818CF8`, Amber `#F59E0B`, Sky `#38BDF8`

### App Icon Picker section
- Grid (2 columns) of all 14 icons from `AppIconsConfig.availableIcons`
- Each card: `SvgPicture.asset(icon.assetPath)` (80×80), icon name below, checkmark overlay if selected
- Tapping selects it: `ref.read(appIconProvider.notifier).setAppIcon(icon)`
- Current selection comes from: `ref.watch(appIconProvider)`
- The `appIconProvider` and all SVG assets already exist — just build the UI

**Required import:**
```dart
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_icons_config.dart';
import '../../../core/providers/app_icon_provider.dart';
```

---

## 📋 TASK 8 — Wire Settings Navigation
**Priority: LOW (do after Tasks 4-7 are built)**  
**File to modify:** `lib/features/settlement/presentation/screens/profile_screen.dart`

The `_SettingsRow` items in `ProfileScreen` all have `onTap: () {}`. Wire them up:

```dart
_SettingsRow(
  icon: Icons.delete_rounded,
  label: 'Trash',
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrashScreen())),
),
_SettingsRow(
  icon: Icons.notifications_rounded,
  label: 'Reminders',
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
),
_SettingsRow(
  icon: Icons.sync_rounded,
  label: 'Cloud Sync',
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorageSyncScreen())),
),
_SettingsRow(
  icon: Icons.palette_rounded,
  label: 'Appearance & App Icon',
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceScreen())),
),
```

---

## 📋 TASK 9 — Supabase Group Sync
**Priority: LOW (do last)**  
**Files to create:** `lib/features/sync/`

### What it is
Groups with `cloud_synced = 1` in the `groups` table are shared with other users. When a group expense or settlement is created, an event is appended to the `sync_journal` table. This task syncs those events to/from Supabase.

### Supabase credentials
- Lives in `.env` file (already set up) — never hardcode keys
- Access via `AppConfig.supabaseUrl` and `AppConfig.supabaseAnonKey`
- Supabase is already initialized via `supabase_flutter` package in `pubspec.yaml`

### What to build
1. `SyncService` class — reads unsynced rows from `sync_journal` (`is_synced = 0`), pushes to Supabase `group_events` table, marks them `is_synced = 1`
2. Pull remote events for groups the user is in, insert into local `sync_journal`
3. Call `SyncService.syncNow()` from the "Sync now" button in Task 5's Storage & Sync screen

### Constraint
Only group data syncs. Personal 1-on-1 khata data **never** leaves the device.

---

## 🔧 Design System Cheat Sheet

### Colors (from `AppColors`)
```dart
AppColors.mint           // #00D1B2 — positive/owed/CTA
AppColors.rose           // #F43F5E — negative/owe
AppColors.indigo         // #818CF8 — groups/settled
AppColors.cockpitGradientStart  // #09121F — top header dark bg
AppColors.lightSurface   // #FFFFFF — card backgrounds (light)
AppColors.darkSurface    // #14233A — card backgrounds (dark)
AppColors.textLightMuted // #64748B — secondary text
```

### Radii (from `AppDimensions`)
```dart
AppDimensions.cardRadius    // 18 — standard card
AppDimensions.radiusMD      // 18 — medium
AppDimensions.radiusLG      // 18 — large
AppDimensions.radiusXL      // 32 — modal sheets
AppDimensions.ticketRadius  // 24 — receipt ticket
AppDimensions.pillRadius    // 999 — fully rounded
AppDimensions.ctaHeight     // 52 — CTA button height
```

### Two-tone screen layout pattern
Every main screen uses this structure:
```dart
Stack(
  children: [
    // Top 35% dark cockpit gradient
    Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.cockpitGradientStart, AppColors.cockpitGradientEnd],
        ),
      ),
    ),
    // Bottom 65% white/dark surface with 32px top radius
    Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.68,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.surfaceSheetRadius),
          ),
        ),
      ),
    ),
    // Actual content on top
    SafeArea(child: YourContent()),
  ],
)
```

---

## ✅ Already Done — Do NOT Rebuild

| Feature | Files |
|---------|-------|
| Home Dashboard (mock data) | `features/home/` |
| 1-on-1 Khata Screen | `features/khata_1on1/` |
| Add Expense Screen | `features/expense/` |
| Groups List + Detail + New Group | `features/groups/` |
| Settle Up Bottom Sheet | `settlement/screens/settle_up_sheet.dart` |
| Spends Analytics Screen | `settlement/screens/spends_screen.dart` |
| Profile Screen + Edit Sheet | `settlement/screens/profile_screen.dart` |
| Retention Service | `retention/data/retention_service.dart` |
| All 14 App Icon SVGs | `assets/icons/app_icons/` |
| App Icon Provider | `core/providers/app_icon_provider.dart` |
| Split Calculator | `core/algorithms/split_calculator.dart` |
| Debt Simplifier | `core/algorithms/debt_simplifier.dart` |
| Database + Schema | `core/database/` |

---

## 🧪 Testing

Unit tests live in `test/unit/`, widget tests in `test/widget/`.

After each task, add a test file:
```
test/widget/receipt_view_test.dart     ← Task 3
test/widget/trash_screen_test.dart    ← Task 4
test/widget/appearance_test.dart      ← Task 7
test/unit/retention_service_test.dart ← Task 4
```

Run tests with: `flutter test`

---

## ❓ Questions / Contact

If anything is unclear about the architecture, design system, or a specific screen, refer to:
- `docs/PRD.md` — full 22-module product spec
- `docs/DESIGN_SYSTEM.md` — colors, typography, components
- `docs/ARCHITECTURE.md` — sync protocol, algorithms
- `docs/DATABASE_SCHEMA.md` — full SQLite DDL with comments
