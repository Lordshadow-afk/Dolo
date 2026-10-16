# Product Requirements Document (PRD) — Dolo
**Product Name:** Dolo  
**Category:** Peer Lending (Khata) & Expense Splitting  
**Target Audience:** University and hostel students, roommates, and budget-conscious peer groups (Pakistan-first focus)  
**Cost Model:** $0 Cloud Budget, Zero-Cost Communication, 100% Offline-First  
**Platform:** Flutter (Android & iOS)
---
## 1. Executive Summary & Core Philosophy
Dolo is a student-focused financial utility designed to eliminate social friction and mental math around peer lending and group expenses. Built with a **Deel-inspired fintech aesthetic** (two-tone composition with an Obsidian dark cockpit and high-contrast surface sheet), Dolo is optimized for rapid use in fast-paced student environments (canteen, hostel mess, print shop, dhabas).
### Core Pillars
1. **Instant Entry (< 5 Seconds):** Log a loan, expense, or settlement with minimal taps and zero mandatory forms.
2. **Zero Mental Math:** Automated split allocation, remainder reconciliation, and counter-debt offsets.
3. **Zero Cloud Costs:** Private 1-on-1 personal khatas remain strictly local on device via SQLite. Cloud sync (Supabase free tier) is used strictly for multi-user shared groups and nickname relay.
4. **Dispute-Proof Tactile Receipts:** High-contrast, ticket-style slips that export directly to WhatsApp as rendered PNGs.
---
## 2. Complete 22 Feature Modules
### Module 1: 1-on-1 Peer Ledger (Khata)
* Direct personal lending and borrowing between two individuals.
* Instant visual balance indicator (*"Sheeda owes you Rs 1,200"* or *"You owe Kaptaan Rs 450"*).
* 100% private and offline on the local device SQLite storage.
### Module 2: Shared Groups & Public Nicknames
* Creation of multi-user groups (e.g., "Hostel Gang", "Trip to Murree", "Flat 402").
* Custom group-specific nicknames (e.g., "Sheeda", "Kaptaan", "Doctor") displayed across group feeds, split cards, and receipts.
* Synchronized across group members via Supabase Cloud Relay.
### Module 3: Smart Split Engine (4 Modes)
1. **Equal:** Automated even division across selected members.
2. **Custom Exact:** Specific rupee allocations per person with real-time balance validation.
3. **Percentage:** Ratio-based allocations with progress bar validation (must equal 100%).
4. **Dhaba & Canteen Itemized Tally (Module 20 integration):** Fast per-item entry without manual calculation.
* **Automated Remainder Allocation:** Odd rupees resulting from integer divisions (e.g., Rs 1,000 / 3) are assigned to the payer or first debtor with an inline visual badge.
### Module 4: Digital Receipt & Bill Slip Generator
* Tactile, ticket-style digital receipts with dashed perforations, breakdown shares, timestamp, and status badges (`SETTLED`, `PENDING`).
* Off-screen rendering to PNG image via Flutter `RepaintBoundary` for direct one-tap WhatsApp sharing via `share_plus`.
### Module 5: Proof-of-Payment & Compression Engine
* Built-in camera and gallery bill capture.
* Native client-side JPEG compression via `flutter_image_compress` ensuring all bill snaps and payment screenshots are strictly `< 150 KB`.
* Sandboxed local filesystem storage; zero image storage on cloud.
### Module 6: Settlement Clearance & Local Alerts
* Instant settlement clearance engine with one-tap status updates.
* * Local on-device scheduled reminders and alerts (no expensive push-server infrastructure).
* Automated WhatsApp acknowledgment slips.
### Module 7: Group Clearance (Batch Multi-Bill Settlement)
* Consolidated multi-bill settlement modal.
* Checkbox selection of multiple pending dues (e.g., Dinner + Mess Bill + Cash Loan) cleared in a single payment transaction.
### Module 8: Minimalist Payment Method Tagging & Banking Quick-Launchers
* One-tap toggle: `[ 💵 Cash ]` vs. `[ 📱 Online ]`.
* Integrated Pakistani student wallet launcher pills:
  * `[ Copy Raast ID ]`
  * `[ Open SadaPay ]`
  * `[ Open NayaPay ]`
  * `[ Open Easypaisa ]`
  * `[ Open JazzCash ]`
### Module 9: Granular Auto-Purge & Retention Engine
* Independent user-configurable retention sliders:
  * **Receipt Images:** Auto-purged after `3 Days`, `7 Days` (default), `14 Days`, or `Never`.
  * **Settled Metadata:** Cleared text entries auto-purged after `Instant upon settle`, `7 Days`, `30 Days`, or `Keep Forever` (default).
### Module 10: 30-Day Trash & Soft-Delete Safety Bin
* Protection against accidental deletions.
* Dedicated Trash screen showing days remaining before permanent wipe.
* Instant options for `Restore`, `Delete Forever`, or `Empty Trash`.
### Module 11: Transparent Cross-Khata Debt Offset Engine
* Automatic counter-debt reconciliation between personal 1-on-1 loans and shared group balances.
* Explicit user toggle with audit clarity:
  * `[✓] Offset applied: Sheeda owes you Rs 250 in 1-on-1, so you pay Rs 1,600.`
* Itemized offset clearly printed on WhatsApp slips.
### Module 12: Micro-Budgeting & Student Category Spends
* Pre-configured student spending categories:
  * `Food` (Teal `#00D1B2`)
  * `Hostel` (Indigo `#818CF8`)
  * `Fuel` (Rose `#F43F5E`)
  * `Printouts` (Amber `#F59E0B`)
  * `Udhār` (Sky `#38BDF8`)
* Interactive SVG/Canvas Donut analytics chart with Month / Week / Year filters and budget headroom indicators (`"Rs 2,100 under budget"`).
### Module 13: Debt Simplification Algorithm
* Greedy balance minimization algorithm (Minimum Cash Flow problem).
* Collapses redundant group debt chains into the absolute minimum number of peer-to-peer transfers.
### Module 14: $0 WhatsApp Communication Engine
* Native URL scheme builder (`https://wa.me/<phone>?text=<encoded_msg>`).
* Configurable reminder tones with Pakistani campus presets:
  * **Friendly:** *"Salaam Sheeda, friendly reminder: Rs 1,200 from Hostel Gang is pending. Pay whenever you can, thanks!"*
  * **Campus / Roman Urdu:** *"Oye Sheeda, mess ka hisaab Rs 1,200 clear kar le jaldi!"*
  * **Firm:** *"Payment reminder: Outstanding Rs 1,200 due for Hostel Gang."*
### Module 15: Offline-First SQLite Core
* Complete local CRUD operations via `sqflite`.
* 0ms latency; zero dependence on internet connectivity for personal ledger and local caching.
### Module 16: Supabase Cloud Relay Sync
* Background cloud sync strictly for shared groups, member nicknames, and lightweight split records.
* Append-only event journal syncing for zero-conflict eventual consistency.
### Module 17: Profile & "Pay Me" QR
* User profile management storing Full Name, WhatsApp Phone, and Raast ID / IBAN.
* Dynamic, on-device scannable QR code generator displaying verified Account Title & Bank Name.
### Module 18: Shadow / Ghost Members (Zero-Friction Adoption)
* Ability to add non-registered friends as "Offline Contacts" using their phone number or nickname.
* Balances track seamlessly even if only one person in a hostel uses Dolo.
* Automatic history merge if the shadow contact later installs Dolo.
### Module 19: 1-Tap Quick Lend / Borrow Micro-FAB
* Long-press or micro-sheet entry for instant cash loans.
* Preset numeric chips (`Rs 100`, `Rs 200`, `Rs 500`, `Rs 1,000`).
* Logged in under 2 seconds with zero keyboard typing.
### Module 20: Dhaba & Canteen "Quick Tally" Itemized Mode
* Rapid line-item entry for shared meals (e.g., Biryani Rs 350 -> Ali, Roll Rs 220 -> Sheeda, Chai Rs 80 -> Hamza).
* Automatically calculates total and populates ledger.
### Module 21: Local Encrypted Backup & Disaster Recovery
* 1-tap backup of SQLite database to an encrypted JSON / CSV file.
* Can be saved to local storage, Google Drive, or shared to WhatsApp "Message Yourself".
* Instant 1-tap restore on new device with zero cloud server dependency.
### Module 22: Custom App Icons (Alternative App Icon Switcher)
* Home screen icon customization inside *Settings -> Appearance*.
* Preset icon themes:
  * **Obsidian Teal (Default):** Deep dark navy with bright mint icon.
  * **Midnight Gold:** Luxury dark obsidian with golden emblem.
  * **Emerald Clean:** Vibrant mint surface icon.
  * **Student Khata:** Vintage tactile ledger notebook styling.
  * **Stealth Carbon:** Monochromatic matte dark icon.
---
## 3. Non-Functional Requirements & Performance Targets
* **Cold Start Time:** `< 800ms` to interactive Home dashboard.
* **Frame Rate:** 60fps / 120fps smooth animations on low-to-mid range Android devices.
* **Database Query Latency:** `< 10ms` for SQLite queries.
* **Image Compression Speed:** `< 400ms` per photo on device.
* **Network Independence:** 100% functionality for all local features during complete internet outage.