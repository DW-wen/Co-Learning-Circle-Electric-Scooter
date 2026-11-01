# co-learning_circle — layout wireframes

Two independent Flutter apps, one per audience:

| Folder | Audience | Form factor | Contents |
|---|---|---|---|
| `user_app/` | Students — **Traditional Chinese (zh-TW)** | Mobile (phone-width frame on desktop/web) | 充電: live session + last charge · 違規: standing & history · 充電站: spot availability, QR unlock, charging history, problem reports |
| `manager_app/` | Campus Security Team (駐警隊) — **Traditional Chinese (zh-TW)** | Desktop | 充電站總覽: live spot status, threshold alerts, 記點 / 維修 actions · 使用紀錄: audit log · 記點查詢: points + 記點 / 停權 · 停權名單: + 解除停權 · 異常與回報: student reports, sensor & patrol incidents with a handling workflow |

**Stage: styled prototype** (light + dark themes), mock data, no backend,
no third-party packages (only Flutter SDK packages, incl. `flutter_localizations`).
Map, camera/QR scanner and push notifications are grey placeholders or simulated.

**Product concept (student side):** a shared *charging-station* service. Students
park their own electric vehicles at designated charging spots, scan the spot's
QR code to unlock it and start charging, and unlock again to leave. There is no
vehicle rental.

## Visual style

Minimalist, two modes (sun / moon button: student app top bar, dashboard
side rail bottom; starts from the OS setting):

| Mode | Base | Accent | Notes |
|---|---|---|---|
| Light | warm paper `#EFE9E1` / cards `#FAF7F2` | copper `#AD6442` | soft paper shadows |
| Dark | navy `#1C1F2B` / cards `#262A39` | sand `#C49B76` | slate borders, grey-blue `#8E9BA5` text |

Status colours (ok / warn / bad / info) are muted per mode. All colours and
text styles live in `lib/wireframe/theme.dart` (`Palette.light`,
`Palette.dark`, `buildTheme`) — identical in both apps; components in
`lib/wireframe/wire.dart`. Targets Flutter 3.29 (checked against 3.29.3 and
current stable sources).

## Run it

Platform folders (`android/`, `web/`, `windows/` …) are not included; generate
them once per app (this does **not** overwrite `lib/`, `test/` or `pubspec.yaml`):

```bash
cd user_app
flutter create . --platforms=android,web,windows
flutter pub get
flutter run -d chrome          # or an Android emulator / -d windows
flutter test                   # smoke test: all tabs build, no overflow

cd ../manager_app
flutter create . --platforms=web,windows
flutter pub get
flutter run -d chrome          # or -d windows
flutter test
```

### Reviewing states without a backend

The student screens have an orange **"Preview state"** strip (dev-only) to flip
between layouts:

- 充電: `A · 充電中` / `B · 充電完成` / `未充電`
- 違規: `可使用＋有記點` / `停權中` / `無違規` (停權中 also blocks QR unlocking)

End-to-end flow: 充電 → 解鎖並離開 → 充電站 › 掃碼充電 → 掃描 QR Code（模擬）
or type a spot ID such as `NSA-04` → the app jumps back to 充電 with the new
session live → 結束充電並解鎖 → the session appears in 充電站 › 充電紀錄.

On the dashboard (shared state across pages, like the student app):

- 充電站總覽: − / + threshold steppers recalculate 超時 / 將超時 alerts live;
  each spot's ⋮ menu has 記點 and 設為維修中 / 恢復服務. A spot parked without a
  scanned session shows 「未掃碼佔用」.
- 異常與回報: filter by status / source → select a case → 開始處理 →
  為相關學生記點 / 將充電位設為維修中 → 標記已解決. The rail badge counts 未處理 cases.
- Points recorded anywhere appear in 記點查詢; 停權 there appears in 停權名單,
  where 解除停權 ends it early.

### History date filter (both apps)

Student 充電站 › 充電紀錄 and dashboard 使用紀錄 share the same control:
**近 3 個月** (everything in the window) or **指定日期** with three dropdowns
`[年] - [月] - [日]` (Gregorian). Only dates from *today minus 3 calendar
months* to *today* are offered (month-end and leap years clamped, e.g.
05-31 → 02-28/29); a blue dot marks days that have records. The 3-month limit
is enforced in each app's data layer (`historyQuery` / `logsQuery`), where the
real API call will go. Widget: `lib/wireframe/ymd_dropdown.dart` (identical
copy in both apps).

## Where each requirement lives

| Spec item | File |
|---|---|
| Student · History (last successful charge) | `user_app/lib/screens/charging/charging_screen.dart` (`_LastChargeCard`) |
| Student · Charging status A/B + badge | `user_app/lib/screens/charging/charging_screen.dart` (`_StatusCard`) |
| Student · Violation standing / points / resume date | `user_app/lib/screens/violations/violation_screen.dart` (`_StandingCard`) |
| Student · Violation history by month/week/day | `user_app/lib/screens/violations/violation_screen.dart` |
| Student · session controls (end / unlock, report, reminders, move-out countdown) | `user_app/lib/screens/charging/charging_screen.dart` |
| Station · nearby stations + per-spot availability + map | `user_app/lib/screens/station/nearby_stations_tab.dart` |
| Station · QR / ID unlock + usage rules | `user_app/lib/screens/station/scan_tab.dart` |
| Station · charging history (fee, overstay flags) | `user_app/lib/screens/station/charge_history_tab.dart` |
| Station · report a problem | `user_app/lib/screens/common/report_issue_sheet.dart` |
| Shared session state (all three tabs) | `user_app/lib/state/charging_controller.dart` |
| All student-facing wording (zh-TW) | `user_app/lib/l10n/strings.dart` |
| Security · stations by zone, status, thresholds, user, spot actions | `manager_app/lib/screens/stations/stations_screen.dart` + `lib/logic/thresholds.dart` |
| Security · usage audit trail | `manager_app/lib/screens/history/usage_logs_screen.dart` |
| Security · student points lookup | `manager_app/lib/screens/violations/points_lookup_screen.dart` |
| Security · ban list | `manager_app/lib/screens/violations/ban_list_screen.dart` |
| Security · incidents (reports / sensor / patrol) + workflow | `manager_app/lib/screens/incidents/incidents_screen.dart` |
| Security · 記點 / 停權 / 解決 dialogs | `manager_app/lib/screens/common/dialogs.dart` |
| Security · shared dashboard state | `manager_app/lib/state/manager_controller.dart` |
| All dashboard wording (zh-TW) | `manager_app/lib/l10n/strings.dart` + `labels.dart` |

Styling tokens: spacing `Sp` and radius `Rd` in `lib/wireframe/wire.dart`;
colours `Wf` and text styles `Tx` (light/dark) in `lib/wireframe/theme.dart`.

## Open questions / assumptions baked into the wireframes

These are rules the spec leaves undefined. The UI shows them as placeholders —
please confirm before the next stage:

1. **"Not charging" vs "Occupied".** Assumed: *Not charging* = bay free;
   *Occupied* = vehicle parked at the bay but not drawing current. If
   "Not charging" actually means "plugged in but idle", the two states merge
   and we need a separate "Free" state.
2. **Occupied limit ("? min").** Placeholder 30 min, adjustable in the UI.
3. **"4h ↑↓".** Implemented as (a) an adjustable limit (− / + in 15-min steps)
   and (b) alerts for *over* (↑) and *nearing* (within 30 min). Tell me if ↑↓
   meant something else.
4. **Estimated time remaining** needs a data source (charger power × battery
   size, or historical average). Mocked as a fixed 2 h 30 m.
5. **Points → ban rule** (threshold, ban length, do points expire?) is
   undefined. Student app shows "Suspension threshold: ? pts"; security app
   sums all-time mock records.
6. **"Active violation"** is assumed to mean points > 0 or currently restricted.
7. **Charging fee** — placeholder NT$5 / hour of charging (could be free,
   per-kWh, or credit-based).
8. **Vehicle type** — UI says 「車輛」 neutrally. Confirm whether these are
   電動機車, 電動自行車 or 電動滑板車 (affects wording and the registration rule).
9. **What the QR unlock physically does** (opens a socket cover / cable lock /
   enables power) and whether unlocking again is required to leave.
10. **Move-out reminder** default 10 min after charge completes (UI toggle only;
    push notifications not wired).
11. **Detecting 「未掃碼佔用」** (a vehicle at a spot with no scanned session)
    assumes each spot has an occupancy sensor. Without one, only student
    reports and patrols can catch it.
12. **Who may 記點 / 停權 / 解除停權** — the dashboard lets any officer do all
    three; the signed-in officer is a placeholder (「值班員 #101」). Roles and an
    audit trail for these actions are not designed yet.
13. **Student reports → incidents.** The student app's 回報問題 sheet and the
    dashboard's 異常與回報 page use the same issue types, but are not connected
    (no backend yet).
14. **History date filter.** Records are grouped by *start* date (a session
    crossing midnight belongs to the day it started). The 3-month window is
    calendar months back from today; confirm whether retention should
    instead be a fixed 90 days, and whether older records are deleted or
    just hidden from these views.

## Structure note

The two apps deliberately share no code yet (each has its own copy of the
models, `wire.dart` and `format.dart`). Mock station / spot IDs are kept
identical (NSA-01 … ENG-04) so the two drafts tell the same story. Once a backend/API exists, consider a
third `shared/` Dart package for models and API client so the two apps can't
drift apart.
