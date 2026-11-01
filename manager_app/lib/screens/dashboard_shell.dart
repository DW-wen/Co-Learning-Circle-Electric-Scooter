import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/strings.dart';
import '../state/manager_controller.dart';
import '../wireframe/wire.dart';
import 'history/usage_logs_screen.dart';
import 'incidents/incidents_screen.dart';
import 'stations/stations_screen.dart';
import 'violations/ban_list_screen.dart';
import 'violations/points_lookup_screen.dart';

/// Left navigation rail + content area. Owns the shared [ManagerController].
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  static const int _incidentsIndex = 4;

  int _index = 0;

  final ManagerController _ctrl = ManagerController(
    students: ManagerMock.students,
    stations: ManagerMock.stations(),
    logs: ManagerMock.usageLogs(),
    pointRecords: ManagerMock.pointRecords(),
    bans: ManagerMock.bans(),
    incidents: ManagerMock.incidents(),
  );

  static const List<(IconData, String)> _destinations = [
    (Icons.ev_station, S.navStations),
    (Icons.receipt_long, S.navLogs),
    (Icons.person_search, S.navPoints),
    (Icons.block, S.navBans),
    (Icons.report_problem_outlined, S.navIncidents),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1280;
    return Scaffold(
      body: Row(
        children: [
          ListenableBuilder(
            listenable: _ctrl,
            builder: (context, _) {
              final open = _ctrl.openIncidentCount;
              return NavigationRail(
                extended: wide,
                minExtendedWidth: 220,
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Sp.x4),
                  child: wide
                      ? Row(
                          children: [
                            Icon(Icons.shield_outlined, color: Wf.primary),
                            SizedBox(width: Sp.x2),
                            Text(S.railTitle, style: Tx.bold),
                          ],
                        )
                      : Icon(Icons.shield_outlined, color: Wf.primary),
                ),
                trailing: const Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: Sp.x4),
                      child: ThemeToggleButton(),
                    ),
                  ),
                ),
                destinations: [
                  for (var i = 0; i < _destinations.length; i++)
                    NavigationRailDestination(
                      icon: i == _incidentsIndex
                          ? Badge(
                              isLabelVisible: open > 0,
                              label: Text('$open'),
                              child: Icon(_destinations[i].$1),
                            )
                          : Icon(_destinations[i].$1),
                      label: Text(_destinations[i].$2),
                    ),
                ],
              );
            },
          ),
          VerticalDivider(width: 1, color: Wf.border),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                StationsScreen(controller: _ctrl),
                UsageLogsScreen(controller: _ctrl),
                PointsLookupScreen(controller: _ctrl),
                BanListScreen(controller: _ctrl),
                IncidentsScreen(controller: _ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
