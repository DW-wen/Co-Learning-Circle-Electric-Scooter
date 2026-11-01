import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../state/manager_controller.dart';
import '../../utils/format.dart';
import '../../wireframe/wire.dart';
import '../../wireframe/ymd_dropdown.dart';

enum _Mode { recent, date }

/// Part 2 · section 2: searchable / filterable audit trail of who used
/// which charging spot and when — the last
/// [ManagerController.historyMonths] months, or one day picked with the
/// 年 - 月 - 日 dropdowns.
class UsageLogsScreen extends StatefulWidget {
  const UsageLogsScreen({super.key, required this.controller});

  final ManagerController controller;

  @override
  State<UsageLogsScreen> createState() => _UsageLogsScreenState();
}

class _UsageLogsScreenState extends State<UsageLogsScreen> {
  String _query = '';
  String? _zone;
  String? _stationId;
  _Mode _mode = _Mode.recent;
  DateTime? _day; // null until the officer picks one

  bool _matches(UsageLog l) {
    if (_zone != null && l.zone != _zone) return false;
    if (_stationId != null && l.stationId != _stationId) return false;
    if (_query.isNotEmpty) {
      final hay = '${l.student.id} ${l.student.name} ${l.stationId} '
              '${l.zone}'
          .toLowerCase();
      if (!hay.contains(_query)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: S.logsTitle,
      subtitle: S.logsSubtitle,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) => _body(),
      ),
    );
  }

  Widget _body() {
    final c = widget.controller;
    final now = DateTime.now();
    final today = dateOnly(now);
    final first = c.historyStart(now);

    // Zone / spot / search filters apply to the whole 3-month window, so the
    // dots in the day dropdown show only days with matching records.
    final inWindow = c.logsQuery(now).where(_matches).toList()
      ..sort((a, b) => b.start.compareTo(a.start));
    final marked = {for (final l in inWindow) dateOnly(l.start)};
    final day = clampDate(
      _day ?? (inWindow.isEmpty ? today : dateOnly(inWindow.first.start)),
      first,
      today,
    );
    final rows = _mode == _Mode.recent
        ? inWindow
        : inWindow.where((l) => sameDay(l.start, day)).toList();
    final spotsInZone =
        c.stations.where((s) => _zone == null || s.zone == _zone).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.x6, Sp.x4, Sp.x6, Sp.x3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: Sp.x3,
                runSpacing: Sp.x3,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SearchField(
                    hint: S.searchLogs,
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                  ),
                  LabeledDropdown<String?>(
                    label: S.zone,
                    value: _zone,
                    items: {
                      null: S.allZones,
                      for (final z in c.zones) z: z,
                    },
                    onChanged: (v) => setState(() {
                      _zone = v;
                      _stationId = null; // spot list depends on zone
                    }),
                  ),
                  LabeledDropdown<String?>(
                    label: S.spot,
                    value: _stationId,
                    items: {
                      null: S.allSpots,
                      for (final s in spotsInZone) s.id: s.id,
                    },
                    onChanged: (v) => setState(() => _stationId = v),
                  ),
                ],
              ),
              const SizedBox(height: Sp.x3),
              Wrap(
                spacing: Sp.x3,
                runSpacing: Sp.x3,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<_Mode>(
                    segments: [
                      ButtonSegment(
                        value: _Mode.recent,
                        label: Text(
                            S.modeRecent(ManagerController.historyMonths)),
                      ),
                      const ButtonSegment(
                          value: _Mode.date, label: Text(S.modeDate)),
                    ],
                    selected: {_mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) =>
                        setState(() => _mode = s.first),
                  ),
                  if (_mode == _Mode.date) ...[
                    Text(S.dateLabel, style: Tx.muted),
                    YmdDropdown(
                      value: day,
                      first: first,
                      last: today,
                      marked: marked,
                      onChanged: (d) => setState(() => _day = d),
                    ),
                  ],
                  Text(
                    _mode == _Mode.recent
                        ? S.records(rows.length)
                        : S.dayRecords(fmtYmd(day), rows.length),
                    style: Tx.bold,
                  ),
                ],
              ),
              const SizedBox(height: Sp.x1),
              Text(
                S.retentionNote(ManagerController.historyMonths, fmtYmd(first)),
                style: Tx.small,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Sp.x6, 0, Sp.x6, Sp.x6),
            child: rows.isEmpty
                ? const WirePlaceholder(
                    label: S.noRecords,
                    icon: Icons.search_off,
                    height: 160,
                  )
                : TableCard(
                    table: DataTable(
                      headingRowColor: WidgetStatePropertyAll(Wf.bg),
                      columns: const [
                        DataColumn(label: Text(S.colSpot)),
                        DataColumn(label: Text(S.colZone)),
                        DataColumn(label: Text(S.colStudentId)),
                        DataColumn(label: Text(S.colName)),
                        DataColumn(label: Text(S.colStart)),
                        DataColumn(label: Text(S.colEnd)),
                        DataColumn(label: Text(S.colDuration)),
                      ],
                      rows: [
                        for (final l in rows)
                          DataRow(cells: [
                            DataCell(Text(l.stationId)),
                            DataCell(Text(l.zone)),
                            DataCell(Text(l.student.id)),
                            DataCell(Text(l.student.name)),
                            DataCell(Text(fmtDateTime(l.start))),
                            DataCell(l.end == null
                                ? StatusBadge(S.inProgress,
                                    color: Wf.info)
                                : Text(fmtDateTime(l.end!))),
                            DataCell(Text(
                                fmtHm((l.end ?? now).difference(l.start)))),
                          ]),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
