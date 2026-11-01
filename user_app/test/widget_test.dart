// Smoke test at phone size (Flutter reports RenderFlex overflow as a test
// failure). Walks the main flow: end session -> restricted blocks unlock ->
// unlock a spot by ID -> session shows up in the 充電 tab -> history
// date filter (年 - 月 - 日 dropdowns).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/l10n/strings.dart';
import 'package:user_app/main.dart';
import 'package:user_app/screens/charging/charging_screen.dart';
import 'package:user_app/screens/station/station_screen.dart';
import 'package:user_app/wireframe/ymd_dropdown.dart';

Finder _nav(String label) => find.descendant(
    of: find.byType(NavigationBar), matching: find.text(label));

/// Text inside the 充電 tab only (other tabs reuse words like 充電中).
Finder _charging(String text) => find.descendant(
    of: find.byType(ChargingScreen), matching: find.text(text));

Finder _station(String text) => find.descendant(
    of: find.byType(StationScreen), matching: find.text(text));

void main() {
  testWidgets('Student app: charging + violations + station flow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const UserApp());
    await tester.pump(); // localization delegates

    // --- 充電: starts in state A (charging)
    expect(find.text(S.currentStatus), findsOneWidget);
    expect(_charging(S.badgeCharging), findsOneWidget);
    expect(find.text(S.stopAndUnlock), findsOneWidget);
    expect(find.text(S.lastSuccessfulCharge), findsOneWidget);

    // State B (finished) -> unlock & leave
    await tester.tap(find.text(S.previewFinished));
    await tester.pump();
    expect(_charging(S.badgeFinished), findsOneWidget);
    await tester.tap(find.text(S.unlockAndLeave));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(S.confirmUnlock));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_charging(S.noActiveSession), findsOneWidget);
    expect(find.text(S.findSpot), findsOneWidget);

    // --- 違規: switch to restricted
    await tester.tap(_nav(S.navViolations));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(S.currentStanding), findsOneWidget);
    await tester.tap(find.text(S.previewRestricted).first);
    await tester.pump();
    expect(find.text(S.resumeFrom), findsOneWidget);

    // --- 充電站: nearby list, then scan tab shows the restriction banner
    await tester.tap(_nav(S.navStation));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(S.tabNearby), findsOneWidget);
    expect(_station('夜讀區充電站'), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byType(TabBar), matching: find.text(S.tabScan)));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('停權中，'), findsOneWidget);

    // Lift the restriction, come back, unlock NSA-04 by ID.
    await tester.tap(_nav(S.navViolations));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(S.previewAllowed));
    await tester.pump();
    await tester.tap(_nav(S.navStation));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'nsa-04');
    await tester.tap(find.widgetWithText(OutlinedButton, S.unlockSpot));
    await tester.pump(const Duration(milliseconds: 400));

    // Shell switched to 充電 and shows the new session.
    expect(_charging(S.badgeCharging), findsOneWidget);
    expect(_charging(S.spotName('夜讀區充電站', '04')), findsOneWidget);

    // --- 充電站 › 充電紀錄: 近 3 個月 by default, then 指定日期 (年-月-日).
    await tester.tap(_nav(S.navStation));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.descendant(
        of: find.byType(TabBar), matching: find.text(S.tabHistory)));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('可查詢近 3 個月'), findsOneWidget);
    expect(find.byType(YmdDropdown), findsNothing);
    await tester.tap(find.text(S.modeDate));
    await tester.pump();
    expect(find.byType(YmdDropdown), findsOneWidget);
    expect(find.byType(DropdownButton<int>), findsNWidgets(3));

    // Let snackbars time out before teardown.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
  });
}
