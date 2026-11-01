// Smoke test at desktop size (Flutter reports RenderFlex overflow as a test
// failure). Visits every page, then walks one incident through
// 開始處理 -> 為相關學生記點 and checks the record shows up in 記點查詢.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager_app/l10n/strings.dart';
import 'package:manager_app/main.dart';
import 'package:manager_app/screens/stations/stations_screen.dart';
import 'package:manager_app/screens/violations/points_lookup_screen.dart';
import 'package:manager_app/wireframe/ymd_dropdown.dart';

Finder _rail(String label) => find.descendant(
    of: find.byType(NavigationRail), matching: find.text(label));

void main() {
  testWidgets('Security dashboard: all pages + incident flow', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ManagerApp());
    await tester.pump(); // localization delegates

    // 充電站總覽
    expect(find.text(S.thresholdsTitle), findsOneWidget);
    // (zone names also appear in the usage-log table, so scope the finder)
    expect(
        find.descendant(
            of: find.byType(StationsScreen), matching: find.text('夜讀區充電站')),
        findsOneWidget);
    expect(find.text(S.unscanned), findsOneWidget);

    const pages = {
      S.navLogs: S.logsSubtitle,
      S.navPoints: S.selectStudent,
      S.navBans: '位學生停權中',
      S.navIncidents: S.kpiResolvedToday,
    };
    for (final e in pages.entries) {
      await tester.tap(_rail(e.key));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining(e.value), findsOneWidget);
    }

    // 使用紀錄: 近 3 個月 by default, then 指定日期 (年 - 月 - 日 dropdowns).
    await tester.tap(_rail(S.navLogs));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('可查詢近 3 個月'), findsOneWidget);
    expect(find.byType(YmdDropdown), findsNothing);
    await tester.tap(find.text(S.modeDate));
    await tester.pump();
    expect(find.byType(YmdDropdown), findsOneWidget);
    expect(find.byType(DropdownButton<int>), findsNWidgets(3));
    await tester.tap(_rail(S.navIncidents));
    await tester.pump(const Duration(milliseconds: 500));

    // 異常與回報: open the newest open case (INC-2041, 充電位被他人佔用).
    await tester.tap(find.text(S.typeOccupiedByOther).first);
    await tester.pump();
    expect(find.text('INC-2041'), findsOneWidget);

    await tester.tap(find.text(S.startHandling));
    await tester.pump();
    expect(find.text(S.incidentStarted('INC-2041')), findsOneWidget);

    // 為相關學生記點 (黃敏) -> confirm with defaults (1 點).
    await tester.tap(find.text(S.recordPointsForInvolved));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(S.confirmRecord));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(S.pointsRecorded('黃敏', 1)), findsOneWidget);

    // 記點查詢 shows the new record, recorded by the current officer.
    await tester.tap(_rail(S.navPoints));
    await tester.pump(const Duration(milliseconds: 500));
    final points = find.byType(PointsLookupScreen);
    await tester.tap(
        find.descendant(of: points, matching: find.text('黃敏')).first);
    await tester.pump();
    expect(
        find.descendant(of: points, matching: find.text(S.currentOfficer)),
        findsWidgets);

    // Let snackbars time out before teardown.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
  });
}
