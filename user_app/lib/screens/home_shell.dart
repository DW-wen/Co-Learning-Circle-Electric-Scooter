import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/strings.dart';
import '../state/charging_controller.dart';
import 'charging/charging_screen.dart';
import 'station/station_screen.dart';
import 'violations/violation_screen.dart';

/// Bottom-navigation shell: 充電 | 違規 | 充電站.
/// Owns the shared [ChargingController] so a session started by scanning a
/// QR code in 充電站 shows up live in 充電, and vice versa.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const int _tabCharging = 0;
  static const int _tabStation = 2;

  int _index = _tabCharging;

  final ChargingController _ctrl = ChargingController(
    stations: MockData.stations(),
    history: MockData.sessionHistory(),
    standing: MockData.standingAllowed(),
    current: MockData.chargingNow(),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ChargingScreen(
            controller: _ctrl,
            onFindSpot: () => _go(_tabStation),
          ),
          ViolationScreen(controller: _ctrl),
          StationScreen(
            controller: _ctrl,
            onShowSession: () => _go(_tabCharging),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.battery_charging_full_outlined),
            selectedIcon: Icon(Icons.battery_charging_full),
            label: S.navCharging,
          ),
          NavigationDestination(
            icon: Icon(Icons.gpp_maybe_outlined),
            selectedIcon: Icon(Icons.gpp_maybe),
            label: S.navViolations,
          ),
          NavigationDestination(
            icon: Icon(Icons.ev_station_outlined),
            selectedIcon: Icon(Icons.ev_station),
            label: S.navStation,
          ),
        ],
      ),
    );
  }
}
