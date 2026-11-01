import 'package:flutter/material.dart';

import '../../l10n/labels.dart';
import '../../l10n/strings.dart';
import '../../logic/thresholds.dart';
import '../../models/models.dart';
import '../../state/manager_controller.dart';
import '../../utils/format.dart';
import '../../wireframe/wire.dart';
import '../common/dialogs.dart';

/// Part 2 · section 1: spots grouped by station, live status, threshold
/// alerts, the student using each spot, and per-spot actions.
class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key, required this.controller});

  final ManagerController controller;

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  Thresholds _th = const Thresholds();
  StationStatus? _statusFilter; // null = all
  bool _alertsOnly = false;

  static const Duration _chargingStep = Duration(minutes: 15);
  static const Duration _occupiedStep = Duration(minutes: 5);

  ManagerController get _c => widget.controller;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: S.stationsTitle,
      subtitle: S.stationsSubtitle,
      child: ListenableBuilder(
        listenable: _c,
        builder: (context, _) =>
            LiveTick(builder: (context, now) => _body(now)),
      ),
    );
  }

  Widget _body(DateTime now) {
    final stations = _c.stations;
    int count(StationStatus s) => stations.where((x) => x.status == s).length;
    final over =
        stations.where((s) => _th.evaluate(s, now) == AlertLevel.over).length;
    final nearing = stations
        .where((s) => _th.evaluate(s, now) == AlertLevel.nearing)
        .length;

    final visible = stations.where((s) {
      if (_statusFilter != null && s.status != _statusFilter) return false;
      if (_alertsOnly && _th.evaluate(s, now) == AlertLevel.none) return false;
      return true;
    }).toList();

    final byZone = <String, List<Station>>{};
    for (final s in visible) {
      byZone.putIfAbsent(s.zone, () => []).add(s);
    }

    Widget kpi(String label, String value, {Color? color, IconData? icon}) =>
        Expanded(
          child: StatTile(label: label, value: value, color: color, icon: icon),
        );

    return ListView(
      padding: const EdgeInsets.all(Sp.x6),
      children: [
        _thresholdBar(),
        const SizedBox(height: Sp.x4),
        Row(
          children: [
            kpi(S.kpiSpots, '${stations.length}'),
            const SizedBox(width: Sp.x3),
            kpi(S.kpiCharging, '${count(StationStatus.charging)}',
                color: Wf.info),
            const SizedBox(width: Sp.x3),
            kpi(S.kpiOccupied, '${count(StationStatus.occupied)}',
                color: Wf.warn),
            const SizedBox(width: Sp.x3),
            kpi(S.kpiFree, '${count(StationStatus.notCharging)}',
                color: Wf.ok),
            const SizedBox(width: Sp.x3),
            kpi(S.kpiOffline, '${count(StationStatus.offline)}'),
            const SizedBox(width: Sp.x3),
            kpi(S.kpiAlerts, '$over / $nearing',
                color: Wf.bad, icon: Icons.warning_amber_rounded),
          ],
        ),
        const SizedBox(height: Sp.x4),
        Wrap(
          spacing: Sp.x2,
          runSpacing: Sp.x2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(S.filter, style: Tx.muted),
            ChoiceChip(
              label: const Text(S.all),
              selected: _statusFilter == null,
              onSelected: (_) => setState(() => _statusFilter = null),
            ),
            for (final s in StationStatus.values)
              ChoiceChip(
                label: Text(stationStatusLabel(s)),
                selected: _statusFilter == s,
                onSelected: (_) => setState(() => _statusFilter = s),
              ),
            const SizedBox(width: Sp.x4),
            FilterChip(
              label: const Text(S.alertsOnly),
              selected: _alertsOnly,
              onSelected: (v) => setState(() => _alertsOnly = v),
            ),
          ],
        ),
        const SizedBox(height: Sp.x4),
        if (byZone.isEmpty)
          const WirePlaceholder(
            label: S.noMatch,
            icon: Icons.filter_alt_off_outlined,
            height: 120,
          ),
        for (final e in byZone.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.x2),
            child: Row(
              children: [
                Icon(Icons.place_outlined, size: 18, color: Wf.muted),
                const SizedBox(width: Sp.x1),
                Text(e.key, style: Tx.label),
                const SizedBox(width: Sp.x2),
                Text(S.spotCount(e.value.length), style: Tx.small),
              ],
            ),
          ),
          Wrap(
            spacing: Sp.x3,
            runSpacing: Sp.x3,
            children: [
              for (final s in e.value)
                SizedBox(
                  width: 290,
                  child: _SpotTile(
                    station: s,
                    level: _th.evaluate(s, now),
                    limit: _th.limitFor(s.status),
                    now: now,
                    onAction: (a) => _onAction(s, a),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Sp.x6),
        ],
      ],
    );
  }

  Future<void> _onAction(Station s, _SpotAction a) async {
    switch (a) {
      case _SpotAction.recordPoints:
        final user = s.user;
        if (user == null) return;
        await recordPointsFlow(
          context,
          _c,
          student: user,
          location: S.fullSpot(s.zone, s.label),
          reason: s.status == StationStatus.occupied
              ? S.violationReasons[1]
              : S.violationReasons[0],
        );
      case _SpotAction.setOffline:
        if (_c.setSpotOffline(s.id, true) && mounted) {
          showSnack(context, S.setOfflineDone(s.id));
        }
      case _SpotAction.setOnline:
        if (_c.setSpotOffline(s.id, false) && mounted) {
          showSnack(context, S.setOnlineDone(s.id));
        }
    }
  }

  Widget _thresholdBar() {
    Duration clampMin(Duration d, Duration min) => d < min ? min : d;
    return WireCard(
      title: S.thresholdsTitle,
      child: Wrap(
        spacing: Sp.x8,
        runSpacing: Sp.x3,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _Stepper(
            label: S.chargingLimit,
            value: fmtHm(_th.chargingLimit),
            onDec: () => setState(() => _th = _th.copyWith(
                chargingLimit: clampMin(_th.chargingLimit - _chargingStep,
                    const Duration(minutes: 30)))),
            onInc: () => setState(() => _th =
                _th.copyWith(chargingLimit: _th.chargingLimit + _chargingStep)),
          ),
          _Stepper(
            label: S.occupiedLimit,
            value: S.minutes(_th.occupiedLimit.inMinutes),
            note: S.placeholderRule,
            onDec: () => setState(() => _th = _th.copyWith(
                occupiedLimit: clampMin(_th.occupiedLimit - _occupiedStep,
                    const Duration(minutes: 5)))),
            onInc: () => setState(() => _th =
                _th.copyWith(occupiedLimit: _th.occupiedLimit + _occupiedStep)),
          ),
          Text(
            S.nearingNote(_th.chargingNearing.inMinutes,
                _th.occupiedNearing.inMinutes),
            style: Tx.small,
          ),
        ],
      ),
    );
  }
}

enum _SpotAction { recordPoints, setOffline, setOnline }

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onDec,
    required this.onInc,
    this.note,
  });

  final String label;
  final String value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Tx.body),
            if (note != null)
              Text(note!, style: TextStyle(fontSize: 11, color: Wf.warn)),
          ],
        ),
        const SizedBox(width: Sp.x3),
        IconButton.outlined(
          onPressed: onDec,
          icon: const Icon(Icons.remove, size: 18),
          visualDensity: VisualDensity.compact,
          tooltip: S.decrease,
        ),
        SizedBox(
          width: 96,
          child: Text(value, textAlign: TextAlign.center, style: Tx.bold),
        ),
        IconButton.outlined(
          onPressed: onInc,
          icon: const Icon(Icons.add, size: 18),
          visualDensity: VisualDensity.compact,
          tooltip: S.increase,
        ),
      ],
    );
  }
}

class _SpotTile extends StatelessWidget {
  const _SpotTile({
    required this.station,
    required this.level,
    required this.limit,
    required this.now,
    required this.onAction,
  });

  final Station station;
  final AlertLevel level;
  final Duration? limit;
  final DateTime now;
  final ValueChanged<_SpotAction> onAction;

  Color get _statusColor => switch (station.status) {
        StationStatus.charging => Wf.info,
        StationStatus.occupied => Wf.warn,
        StationStatus.notCharging => Wf.ok,
        StationStatus.offline => Wf.muted,
      };

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (level) {
      AlertLevel.over => Wf.bad,
      AlertLevel.nearing => Wf.warn,
      AlertLevel.none => Wf.border,
    };
    final user = station.user;
    final since = station.since;

    return Container(
      padding: const EdgeInsets.fromLTRB(Sp.x3, Sp.x2, Sp.x1, Sp.x3),
      decoration: cardDecoration(
        radius: Rd.lg + 2,
        color: station.status == StationStatus.offline ? Wf.fill : null,
      ).copyWith(
        // alert outline replaces the hairline border
        border: level == AlertLevel.none
            ? null
            : Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(S.spotName(station.label), style: Tx.bold)),
              StatusBadge(stationStatusLabel(station.status),
                  color: _statusColor),
              _menu(),
            ],
          ),
          Text(station.id, style: Tx.small),
          const SizedBox(height: Sp.x2),
          if (station.unscannedOccupancy)
            _line(Icons.no_accounts_outlined, S.unscanned, color: Wf.bad)
          else
            _line(
              Icons.person_outline,
              user == null ? S.noUser : '${user.id} · ${user.name}',
              color: user == null ? Wf.muted : null,
            ),
          if (since != null) _line(Icons.schedule, _sinceText(since)),
          if (level != AlertLevel.none && since != null && limit != null) ...[
            const SizedBox(height: Sp.x2),
            _alert(now.difference(since), limit!),
          ],
        ],
      ),
    );
  }

  String _sinceText(DateTime since) {
    final d = fmtHm(now.difference(since));
    final t = fmtTime(since);
    return switch (station.status) {
      StationStatus.charging => S.chargingFor(d, t),
      StationStatus.occupied => S.parkedFor(d, t),
      StationStatus.offline => S.offlineSince(fmtDateTime(since)),
      StationStatus.notCharging => '',
    };
  }

  Widget _menu() {
    final s = station.status;
    return PopupMenuButton<_SpotAction>(
      tooltip: S.moreActions,
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: onAction,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _SpotAction.recordPoints,
          enabled: station.user != null,
          child: const Text(S.menuRecordPoints),
        ),
        if (s == StationStatus.offline)
          const PopupMenuItem(
            value: _SpotAction.setOnline,
            child: Text(S.menuSetOnline),
          )
        else
          PopupMenuItem(
            value: _SpotAction.setOffline,
            enabled: s == StationStatus.notCharging,
            child: const Text(S.menuSetOffline),
          ),
      ],
    );
  }

  Widget _line(IconData icon, String text, {Color? color}) {
    final c = color ?? Wf.text;
    return Padding(
      padding: const EdgeInsets.only(top: 2, right: Sp.x2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color == null ? Wf.muted : c),
          const SizedBox(width: Sp.x1),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: c),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _alert(Duration elapsed, Duration limit) {
    final isOver = level == AlertLevel.over;
    final color = isOver ? Wf.bad : Wf.warn;
    final text = !isOver
        ? S.alertNearing(fmtHm(limit - elapsed))
        : station.status == StationStatus.occupied
            ? S.alertOverOccupied(fmtHm(elapsed - limit))
            : S.alertOverCharging(fmtHm(elapsed - limit));
    return Container(
      margin: const EdgeInsets.only(right: Sp.x2),
      padding: const EdgeInsets.symmetric(horizontal: Sp.x2, vertical: Sp.x1),
      decoration: BoxDecoration(
        color: Wf.tint(color),
        borderRadius: BorderRadius.circular(Rd.md),
      ),
      child: Row(
        children: [
          Icon(isOver ? Icons.arrow_upward : Icons.hourglass_bottom,
              size: 16, color: color),
          const SizedBox(width: Sp.x1),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
