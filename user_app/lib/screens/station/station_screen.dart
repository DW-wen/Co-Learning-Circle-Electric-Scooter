import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/station.dart';
import '../../state/charging_controller.dart';
import '../../wireframe/wire.dart';
import '../common/report_issue_sheet.dart';
import 'charge_history_tab.dart';
import 'nearby_stations_tab.dart';
import 'scan_tab.dart';

/// Part 1 · section 4: shared charging-station service.
/// 附近充電站 (availability) -> 掃碼充電 (QR unlock) -> 充電紀錄 (history).
/// The live session itself is shown in the 充電 tab.
class StationScreen extends StatefulWidget {
  const StationScreen({
    super.key,
    required this.controller,
    required this.onShowSession,
  });

  final ChargingController controller;

  /// Switch to the 充電 tab (after unlocking, or "查看本次充電").
  final VoidCallback onShowSession;

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen>
    with SingleTickerProviderStateMixin {
  static const int _tabScan = 1;

  late final TabController _tabs = TabController(length: 3, vsync: this);

  ChargingController get _c => widget.controller;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _unlock(String raw) {
    final id = ChargingController.normalizeId(raw);
    if (id.isEmpty) {
      _snack(S.enterSpotId);
      return;
    }
    switch (_c.unlock(id)) {
      case UnlockResult.ok:
        _snack(S.unlockedPlugIn(id));
        widget.onShowSession();
      case UnlockResult.alreadyInSession:
        _snack(S.alreadyInSession);
      case UnlockResult.restricted:
        _snack(S.restrictedCannotUse);
      case UnlockResult.notFound:
        _snack(S.spotNotFound(id));
      case UnlockResult.unavailable:
        _snack(S.spotUnavailable(id));
    }
  }

  /// Simulated QR scan: the first free spot at the nearest station with one.
  void _simulateScan() {
    final byDistance = [..._c.stations]
      ..sort((a, b) => a.distanceM.compareTo(b.distanceM));
    for (final st in byDistance) {
      for (final sp in st.spots) {
        if (sp.status == SpotStatus.available) {
          _unlock(sp.id);
          return;
        }
      }
    }
    _snack(S.noSpotAvailable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.stationTitle),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: S.report,
            icon: const Icon(Icons.report_problem_outlined),
            onPressed: () => showReportIssueSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: S.tabNearby),
            Tab(text: S.tabScan),
            Tab(text: S.tabHistory),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) => TabBarView(
          controller: _tabs,
          children: [
            NearbyStationsTab(
              stations: _c.stations,
              onScan: () => _tabs.animateTo(_tabScan),
            ),
            ScanTab(
              current: _c.current,
              standing: _c.standing,
              onUnlock: _unlock,
              onScan: _simulateScan,
              onShowSession: widget.onShowSession,
            ),
            ChargeHistoryTab(controller: _c),
          ],
        ),
      ),
    );
  }
}
