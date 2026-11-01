# user_app — Student app (mobile, 繁體中文)

Styled prototype (light + dark). See the root `README.md` for run instructions and open questions.

```
lib/
  main.dart                      app entry; zh-Hant-TW locale; phone-width frame on wide windows
  l10n/strings.dart              ALL student-facing wording (Traditional Chinese)
  wireframe/theme.dart           light / dark palettes, Material theme, mode toggle
  wireframe/wire.dart            spacing/radius tokens + shared components
  wireframe/ymd_dropdown.dart    年 - 月 - 日 date dropdowns
  utils/format.dart              zh-TW date & duration formatting
  models/                        charging.dart · station.dart · rules.dart · violation.dart
  state/charging_controller.dart shared session / stations / standing state
  data/mock_data.dart            mock data (replace with API)
  screens/
    home_shell.dart              bottom nav: 充電 | 違規 | 充電站
    charging/charging_screen.dart   live session, end/unlock, reminders, last charge
    violations/violation_screen.dart
    station/
      station_screen.dart        tabs + unlock logic
      nearby_stations_tab.dart   map placeholder + stations + spot availability
      scan_tab.dart              QR viewfinder placeholder + spot-ID entry + rules
      charge_history_tab.dart    past sessions (近 3 個月 / 指定日期 年-月-日)
    common/report_issue_sheet.dart  回報問題 bottom sheet
test/widget_test.dart            end-to-end smoke test at 390×844
```
