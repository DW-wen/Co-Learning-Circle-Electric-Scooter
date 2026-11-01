# manager_app — 駐警隊充電站監控台 (desktop, 繁體中文)

Styled prototype (light + dark). See the root `README.md` for run instructions and open questions.

```
lib/
  main.dart                          app entry; zh-Hant-TW locale
  l10n/strings.dart                  ALL dashboard wording (Traditional Chinese)
  l10n/labels.dart                   enum -> label mapping
  wireframe/theme.dart               light / dark palettes, Material theme, mode toggle
  wireframe/wire.dart                spacing/radius tokens + components (PageScaffold, StatTile, TableCard …)
  wireframe/ymd_dropdown.dart        年 - 月 - 日 date dropdowns
  utils/format.dart                  zh-TW date / duration / "N 分鐘前" formatting
  models/models.dart                 Student, Station (spot), UsageLog, PointRecord, Ban, Incident
  logic/thresholds.dart              charging / occupied alert rules (adjustable)
  state/manager_controller.dart      shared state: spot status, 記點, 停權, incidents
  data/mock_data.dart                mock data (replace with API); IDs match user_app
  screens/
    dashboard_shell.dart             navigation rail (+ open-incident badge) + pages
    stations/stations_screen.dart    充電站總覽
    history/usage_logs_screen.dart   使用紀錄 (近 3 個月 / 指定日期 年-月-日)
    violations/points_lookup_screen.dart   記點查詢 (+ 記點 / 停權)
    violations/ban_list_screen.dart  停權名單 (+ 解除停權)
    incidents/incidents_screen.dart  異常與回報
    common/dialogs.dart              記點 / 停權 / 確認 / 解決 dialogs
test/widget_test.dart                smoke test at 1600×1000
```

Best viewed at ≥ 1280 px wide (navigation rail collapses to icons below that).
Platform folders are not generated yet: run `flutter create . --platforms=web,windows` once.
