import 'package:flutter/material.dart';

import '../../l10n/labels.dart';
import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../state/manager_controller.dart';
import '../../utils/format.dart';
import '../../wireframe/wire.dart';
import '../common/dialogs.dart';

/// Part 2 · section 4 (charging-spot incidents; replaces the fleet page):
/// charging-spot incidents from student reports (回報問題), system / sensor
/// detection, and patrol officers — with a 未處理 -> 處理中 -> 已解決 workflow.
class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key, required this.controller});

  final ManagerController controller;

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  IncidentStatus? _status = IncidentStatus.open; // null = all
  IncidentSource? _source; // null = all
  String? _selectedId;

  ManagerController get _c => widget.controller;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: S.incidentsTitle,
      subtitle: S.incidentsSubtitle,
      child: ListenableBuilder(
        listenable: _c,
        builder: (context, _) => LiveTick(
          interval: const Duration(seconds: 30),
          builder: (context, now) => _body(now),
        ),
      ),
    );
  }

  Widget _body(DateTime now) {
    final all = _c.incidents;
    int count(IncidentStatus s) => all.where((i) => i.status == s).length;
    final today = DateTime(now.year, now.month, now.day);
    final resolvedToday = all
        .where((i) =>
            i.status == IncidentStatus.resolved &&
            i.resolvedAt != null &&
            !i.resolvedAt!.isBefore(today))
        .length;
    final offline =
        _c.stations.where((s) => s.status == StationStatus.offline).length;

    final visible = all.where((i) {
      if (_status != null && i.status != _status) return false;
      if (_source != null && i.source != _source) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));

    Incident? selected;
    for (final i in all) {
      if (i.id == _selectedId) selected = i;
    }

    return Padding(
      padding: const EdgeInsets.all(Sp.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                  child: StatTile(
                      label: S.kpiOpen,
                      value: '${count(IncidentStatus.open)}',
                      color: Wf.bad,
                      icon: Icons.mark_email_unread_outlined)),
              const SizedBox(width: Sp.x3),
              Expanded(
                  child: StatTile(
                      label: S.kpiInProgress,
                      value: '${count(IncidentStatus.inProgress)}',
                      color: Wf.warn)),
              const SizedBox(width: Sp.x3),
              Expanded(
                  child: StatTile(
                      label: S.kpiResolvedToday,
                      value: '$resolvedToday',
                      color: Wf.ok)),
              const SizedBox(width: Sp.x3),
              Expanded(
                  child: StatTile(
                      label: S.kpiOfflineSpots, value: '$offline')),
            ],
          ),
          const SizedBox(height: Sp.x4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 440, child: _list(visible, now)),
                const SizedBox(width: Sp.x4),
                Expanded(
                  child: selected == null
                      ? const WirePlaceholder(
                          label: S.selectIncident,
                          icon: Icons.touch_app_outlined,
                          height: null,
                        )
                      : _detail(selected, now),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ list

  Widget _list(List<Incident> visible, DateTime now) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Wf.border),
        borderRadius: BorderRadius.circular(Rd.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(Sp.x3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: Sp.x2,
                  runSpacing: Sp.x2,
                  children: [
                    ChoiceChip(
                      label: const Text(S.allStatuses),
                      selected: _status == null,
                      onSelected: (_) => setState(() => _status = null),
                    ),
                    for (final s in IncidentStatus.values)
                      ChoiceChip(
                        label: Text(incidentStatusLabel(s)),
                        selected: _status == s,
                        onSelected: (_) => setState(() => _status = s),
                      ),
                  ],
                ),
                const SizedBox(height: Sp.x2),
                Wrap(
                  spacing: Sp.x2,
                  runSpacing: Sp.x2,
                  children: [
                    ChoiceChip(
                      label: const Text(S.allSources),
                      selected: _source == null,
                      onSelected: (_) => setState(() => _source = null),
                    ),
                    for (final s in IncidentSource.values)
                      ChoiceChip(
                        label: Text(incidentSourceLabel(s)),
                        selected: _source == s,
                        onSelected: (_) => setState(() => _source = s),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text(S.noIncidents, style: Tx.muted))
                // Material so ListTile selection / ink paints above white bg.
                : Material(
                    type: MaterialType.transparency,
                    child: ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => _listItem(visible[i], now),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _listItem(Incident inc, DateTime now) {
    final spot = _c.stationById(inc.spotId);
    return ListTile(
      selected: inc.id == _selectedId,
      selectedTileColor: Wf.info.withAlpha(18),
      leading: Icon(_sourceIcon(inc.source), color: Wf.muted),
      title: Text(incidentTypeLabel(inc.type), style: Tx.bold),
      subtitle: Text(
        '${spot == null ? inc.spotId : S.fullSpot(spot.zone, spot.label)}'
        ' · ${fmtAgo(inc.reportedAt, now)}',
        style: Tx.small,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _statusBadge(inc.status),
      onTap: () => setState(() => _selectedId = inc.id),
    );
  }

  // ---------------------------------------------------------------- detail

  Widget _detail(Incident inc, DateTime now) {
    final spot = _c.stationById(inc.spotId);
    final involved = inc.involved;
    final canSetOffline =
        spot != null && spot.status == StationStatus.notCharging;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Wf.border),
        borderRadius: BorderRadius.circular(Rd.xl),
      ),
      child: ListView(
        padding: const EdgeInsets.all(Sp.x6),
        children: [
          Row(
            children: [
              Icon(_sourceIcon(inc.source), color: Wf.muted),
              const SizedBox(width: Sp.x2),
              Expanded(
                child: Text(incidentTypeLabel(inc.type),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              _statusBadge(inc.status),
            ],
          ),
          const SizedBox(height: Sp.x4),
          KeyValue(S.fieldId, inc.id),
          KeyValue(
            S.fieldSpot,
            spot == null
                ? inc.spotId
                : '${S.fullSpot(spot.zone, spot.label)}（${spot.id}）',
          ),
          KeyValue(S.fieldSpotStatus,
              spot == null ? S.none : stationStatusLabel(spot.status)),
          KeyValue(S.fieldSource, incidentSourceLabel(inc.source)),
          KeyValue(S.fieldReportedAt,
              '${fmtDateTime(inc.reportedAt)}（${fmtAgo(inc.reportedAt, now)}）'),
          KeyValue(S.fieldReporter, _who(inc.reporter)),
          KeyValue(S.fieldInvolved, _who(involved)),
          KeyValue(S.fieldNote, inc.note ?? S.none),
          KeyValue(S.fieldHandler, inc.handledBy ?? S.none),
          if (inc.status == IncidentStatus.resolved) ...[
            KeyValue(S.fieldResolvedAt,
                inc.resolvedAt == null ? S.none : fmtDateTime(inc.resolvedAt!)),
            KeyValue(S.fieldResolution, inc.resolution ?? S.none),
          ],
          if (inc.source == IncidentSource.student) ...[
            const SizedBox(height: Sp.x3),
            const WirePlaceholder(
              label: S.photoPlaceholder,
              icon: Icons.photo_outlined,
              height: 120,
            ),
          ],
          const Divider(height: Sp.x8),
          Wrap(
            spacing: Sp.x2,
            runSpacing: Sp.x2,
            children: [
              if (inc.status == IncidentStatus.open)
                FilledButton.icon(
                  onPressed: () {
                    _c.startIncident(inc.id);
                    showSnack(context, S.incidentStarted(inc.id));
                  },
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text(S.startHandling),
                ),
              if (inc.status != IncidentStatus.resolved)
                FilledButton.tonalIcon(
                  onPressed: () => _resolve(inc),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text(S.markResolved),
                ),
              if (involved != null)
                OutlinedButton.icon(
                  onPressed: () => recordPointsFlow(
                    context,
                    _c,
                    student: involved,
                    location: spot == null
                        ? inc.spotId
                        : S.fullSpot(spot.zone, spot.label),
                    reason: _reasonFor(inc.type),
                  ),
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text(S.recordPointsForInvolved),
                ),
              if (spot != null && spot.status != StationStatus.offline)
                _withTooltip(
                  canSetOffline ? null : S.spotInUse,
                  OutlinedButton.icon(
                    onPressed: canSetOffline
                        ? () {
                            if (_c.setSpotOffline(spot.id, true)) {
                              showSnack(context, S.setOfflineDone(spot.id));
                            }
                          }
                        : null,
                    icon: const Icon(Icons.build_outlined, size: 18),
                    label: const Text(S.setSpotOffline),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resolve(Incident inc) async {
    final note = await resolutionDialog(context);
    if (note == null || !mounted) return;
    _c.resolveIncident(inc.id, note);
    showSnack(context, S.incidentResolved(inc.id));
  }

  // --------------------------------------------------------------- helpers

  Widget _withTooltip(String? message, Widget child) =>
      message == null ? child : Tooltip(message: message, child: child);

  String _who(Student? s) => s == null ? S.none : '${s.name}（${s.id}）';

  /// Pre-selects the matching 記點 reason.
  String? _reasonFor(IncidentType t) => switch (t) {
        IncidentType.occupiedByOther => S.violationReasons[1],
        IncidentType.unscannedOccupancy => S.violationReasons[2],
        IncidentType.unregisteredVehicle => S.violationReasons[3],
        _ => null,
      };

  IconData _sourceIcon(IncidentSource s) => switch (s) {
        IncidentSource.student => Icons.person_outline,
        IncidentSource.system => Icons.sensors,
        IncidentSource.patrol => Icons.local_police_outlined,
      };

  Widget _statusBadge(IncidentStatus s) {
    final color = switch (s) {
      IncidentStatus.open => Wf.bad,
      IncidentStatus.inProgress => Wf.warn,
      IncidentStatus.resolved => Wf.ok,
    };
    return StatusBadge(incidentStatusLabel(s), color: color);
  }
}
