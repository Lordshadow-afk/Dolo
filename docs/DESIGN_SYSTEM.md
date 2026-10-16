# UI/UX Design System Specification — Dolo

**Aesthetic Direction:** Deel-Inspired Modern Fintech for Students  
**Theme Support:** Full Light Mode & Obsidian Dark Mode  
**Key Visual Hook:** Two-Tone Cockpit & Surface Sheet with Encapsulated Glass Triad  

---

## 1. Color Palette & Semantic Tokens

### A. Dark Cockpit & Deep Obsidian Tones
| Token | Hex | Usage |
| :--- | :--- | :--- |
| `cockpitStart` | `#09121F` | Header gradient start (Light mode cockpit) |
| `cockpitEnd` | `#132238` | Header gradient end (Light mode cockpit) |
| `darkCockpitStart` | `#060D17` | True Dark theme cockpit top |
| `darkCockpitEnd` | `#0B1626` | True Dark theme cockpit bottom |
| `darkSurface` | `#14233A` | Elevated surface sheet in Dark mode |
| `darkCard` | `#1B2B44` | Card & QR background container in Dark mode |
| `darkPill` | `#1F3049` | Inactive pill & subtle border in Dark mode |
| `darkPillActive` | `#2A3E5C` | Active secondary pill in Dark mode |
| `darkBorder` | `#3A4B66` | Dashed receipt perforations & borders in Dark mode |

### B. Crisp Surface Sheet (Light Mode)
| Token | Hex | Usage |
| :--- | :--- | :--- |
| `lightSurface` | `#FFFFFF` | Main elevated 32px rounded surface sheet |
| `lightBackground` | `#F6F8FB` | Secondary card background, Pay Me QR card |
| `lightPillInactive`| `#EEF1F6` | Inactive filter chip & toggle pill background |
| `lightBorder` | `#CBD5E1` | Dashed receipt borders & divider lines |
| `lightTextPrimary` | `#09121F` | High-contrast black body text |
| `lightTextSecondary`| `#64748B` | Subtitles, date stamps, and secondary copy |

### C. The Triad & Financial Status Colors
| Metric | Primary Hex | Dark Text | Light Text | Light Container | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **You Are Owed** | `#00D1B2` / `#10B981` | `#2DD4BF` | `#0B7A6B` | `#DDF7F2` | Positive balance, lent funds, active pills |
| **You Owe** | `#F43F5E` | `#FB7185` | `#BE123C` | `#FFE4EA` | Debt balance, borrowed funds, danger buttons |
| **Settled** | `#818CF8` | `#A5B4FC` | `#5B4FD6` | `#E8E6FF` | Settled receipts, offset notice cards |
| **Printouts** | `#F59E0B` | `#FBBF24` | `#D97706` | `#FEF3C7` | Academic spending category |
| **Udhār / Cash** | `#38BDF8` | `#7DD3FC` | `#0284C7` | `#E0F2FE` | Informal cash loans category |

---

## 2. Typography & Layout Metrics

### Typography Rules
* **Font Family:** `Plus Jakarta Sans` (fallback to system sans-serif).
* **Tabular Numbers (Mandatory):** All numeric metrics, balances, prices, and rupee amounts MUST use `font-variant-numeric: tabular-nums` to eliminate layout jitter during balance updates.
* **Text Scale:**
  * **Hero Balance (Header):** `40px` / `48px`, Weight: `800` (ExtraBold), Letter-spacing: `-1px`
  * **Screen Titles:** `22px` / `26px`, Weight: `800`
  * **Section Headings / Labels:** `12px`, Weight: `700`, Uppercase, Letter-spacing: `0.5px`
  * **Card Titles:** `15px` / `16px`, Weight: `700`
  * **Body & Explanations:** `13px` / `14px`, Weight: `500` / `600`
  * **Subtitles & Badges:** `11px` / `12px`, Weight: `600` / `700`

---

## 3. Signature UI Components

### 1. Two-Tone Ratio
* **Top 35%:** Dark cockpit displaying status bar, user greeting (*"Salaam, Ali"*), net standing balance, and the glass triad.
* **Bottom 65%:** Elevated surface sheet with `border-radius: 32px 32px 0 0` containing action buttons, filter pills, and scrollable transaction feed.

### 2. Encapsulated Glass Triad
* Floating capsule in the cockpit:
  * `background: rgba(255, 255, 255, 0.08)`
  * `border: 1px solid rgba(255, 255, 255, 0.14)`
  * `border-radius: 20px`, `padding: 14px 8px`
  * Divided into 3 equal columns with vertical borders:
    1. `● OWED` (Mint `#00D1B2` dot + amount)
    2. `● OWE` (Rose `#F43F5E` dot + amount)
    3. `● SETTLED` (Indigo `#818CF8` dot + count)

### 3. Micro-Pills & Filter Chips
* `min-height: 44px`, `border-radius: 999px`, `padding: 10px 16px`.
* Active State: `#00D1B2` background with `#09121F` bold text.
* Inactive State: `#EEF1F6` (Light) or `#1F3049` (Dark).

### 4. Squircle Avatars & Icons
* `44px x 44px` (lists), `52px x 52px` (headers), `76px x 76px` (profile).
* `border-radius: 14px` to `26px`.
* Uses two-letter uppercase initials (e.g. `SH`, `KP`, `AL`) with tinted contrast backgrounds.

### 5. Tactile Ticket Receipt Card
* White `#FFFFFF` / Dark `#14233A` card.
* `border: 2px dashed #CBD5E1` (Light) or `#3A4B66` (Dark).
* `border-radius: 24px`.
* Perforated dashed divider lines between metadata, itemized shares, and final total.
* Instant capture via `RepaintBoundary` to native PNG.

### 6. Alternative App Icon Switcher
* Rendered in *Settings -> Appearance*.
* Interactive icon cards showing preview icon, name, and active radio checkmark.

---

## 4. Complete Screen Inventory (16 Screens x 2 Themes)

1. **Screen 1: Home Dashboard** — Cockpit, glass triad, pill filters (All, Friends, Groups, Pending), quick CTAs (+ Add expense, Settle up), bottom navigation.
2. **Screen 2: Add Expense** — Hero amount (Rs 3,600), Paid by selector, 4 categories, split mode pills (Equal, Exact, %, Itemized), auto-compressed receipt attach.
3. **Screen 3: Group View** — Group header, "Simplified: 2 payments settle the whole group", tabs (Expenses, Balances, Members), Clear all dues CTA.
4. **Screen 4: Receipt Detail** — Ticket receipt #0142, SETTLED badge, member breakdown, total, auto-purge tag, WhatsApp & PNG export CTAs.
5. **Screen 5: Onboarding** — "Lend, split, settle. In 5 seconds.", 3-step value prop, Google Sign-in & Magic Link buttons.
6. **Screen 6: Spends Analytics** — Month/Week/Year selector, SVG/Canvas Donut chart with category shares, budget headroom tracker.
7. **Screen 7: Profile & Pay Me QR** — Profile header, scannable Raast QR code card, quick share, bank account title.
8. **Screen 8: Trash Bin** — 30-day countdown cards, Restore / Delete forever buttons, Empty trash CTA.
9. **Screen 9: Settle Up Modal** — Multi-bill selection checklist, counter-debt offset alert banner, Cash vs Online toggle, payment screenshot attach.
10. **Screen 10: 1-on-1 Khata** — Personal ledger timeline, net standing, "I lent" / "I borrowed" CTAs, Open / Cleared tabs.
11. **Screen 11: Settings** — Account, Preferences, Data, and About menu list.
12. **Screen 12: Appearance** — Light / Dark / System theme picker, 5 accent colors, text size scale, compact numbers & reduce motion toggles, Custom App Icon selector.
13. **Screen 13: Notifications** — Push toggles, reminder tones (Friendly / Campus Urdu / Firm), WhatsApp live message preview bubble.
14. **Screen 14: Storage & Sync** — 38 MB compression progress bar, group cloud sync status, independent receipt vs metadata purge sliders, CSV export.
15. **Screen 15: New Group** — Group name input, members with custom group nickname fields, WhatsApp invite CTA.
16. **Screen 16: Edit Profile** — Profile avatar upload, Full Name, WhatsApp phone, Raast ID / IBAN with live QR sync indicator.
