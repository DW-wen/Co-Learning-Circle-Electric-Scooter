import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../l10n/strings.dart';
import '../../models/violation.dart';
import '../../state/charging_controller.dart';
import '../../utils/format.dart';
import '../../wireframe/wire.dart';

enum _StandingPreview { allowed, restricted, clean }

enum HistoryGrouping { month, week, day }

/// Part 1 · section 3: violation standing, points / resume date, history.
/// Standing lives in the shared controller so a suspension also blocks
/// QR unlocking in the 充電站 tab.
class ViolationScreen extends StatefulWidget {
  const ViolationScreen({super.key, required this.controller});

  final ChargingController controller;

  @override
  State<ViolationScreen> createState() => _ViolationScreenState();
}

class _ViolationScreenState extends State<ViolationScreen> {
  _StandingPreview _preview = _StandingPreview.allowed;
  HistoryGrouping _grouping = HistoryGrouping.month;

  void _setPreview(_StandingPreview p) {
    setState(() => _preview = p);
    widget.controller.setStanding(switch (p) {
      _StandingPreview.allowed => MockData.standingAllowed(),
      _StandingPreview.restricted => MockData.standingRestricted(),
      _StandingPreview.clean => MockData.standingClean(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.violationsTitle)),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) => _body(widget.controller.standing),
      ),
    );
  }

  Widget _body(ViolationStanding standing) {
    return ListView(
        padding: const EdgeInsets.all(Sp.x4),
        children: [
          PreviewSwitcher<_StandingPreview>(
            value: _preview,
            options: const {
              _StandingPreview.allowed: S.previewAllowed,
              _StandingPreview.restricted: S.previewRestricted,
              _StandingPreview.clean: S.previewClean,
            },
            onChanged: _setPreview,
          ),
          const SizedBox(height: Sp.x4),
          _StandingCard(standing: standing),
          const SizedBox(height: Sp.x4),
          WireCard(
            title: S.violationHistory,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<HistoryGrouping>(
                  segments: const [
                    ButtonSegment(
                        value: HistoryGrouping.month,
                        label: Text(S.groupMonth)),
                    ButtonSegment(
                        value: HistoryGrouping.week, label: Text(S.groupWeek)),
                    ButtonSegment(
                        value: HistoryGrouping.day, label: Text(S.groupDay)),
                  ],
                  selected: {_grouping},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) =>
                      setState(() => _grouping = s.first),
                ),
                const SizedBox(height: Sp.x3),
                if (standing.records.isEmpty)
                  const WirePlaceholder(
                    label: S.noViolations,
                    icon: Icons.verified_outlined,
                    height: 100,
                  )
                else
                  ..._groups(standing.records),
              ],
            ),
          ),
        ],
    );
  }

  List<Widget> _groups(List<ViolationRecord> records) {
    final sorted = [...records]..sort((a, b) => b.at.compareTo(a.at));
    final groups = <String, List<ViolationRecord>>{};
    for (final r in sorted) {
      groups.putIfAbsent(_groupLabel(r.at), () => []).add(r);
    }
    return [
      for (final e in groups.entries)
        _ViolationGroup(label: e.key, records: e.value),
    ];
  }

  String _groupLabel(DateTime d) => switch (_grouping) {
        HistoryGrouping.month => fmtMonth(d),
        HistoryGrouping.week => S.weekOf(fmtDate(startOfWeek(d))),
        HistoryGrouping.day => fmtDate(d),
      };
}

class _StandingCard extends StatelessWidget {
  const _StandingCard({required this.standing});

  final ViolationStanding standing;

  @override
  Widget build(BuildContext context) {
    final until = standing.restrictedUntil;
    return WireCard(
      title: S.currentStanding,
      trailing: standing.allowed
          ? const StatusBadge(S.badgeAllowed,
              color: Wf.ok, icon: Icons.check_circle_outline)
          : const StatusBadge(S.badgeRestricted,
              color: Wf.bad, icon: Icons.block),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValue(
            S.activeViolations,
            standing.hasActiveViolations ? S.yes : S.no,
          ),
          const KeyValue(S.rules, S.rulesNightStudy),
          const Divider(height: Sp.x6),
          if (standing.allowed) ...[
            BigStat(
              label: S.accumulatedPoints,
              value: S.points(standing.points),
              icon: Icons.flag_outlined,
            ),
            const SizedBox(height: Sp.x1),
            const Text(S.suspensionThresholdTbd, style: Tx.small),
          ] else if (until != null) ...[
            BigStat(
              label: S.resumeFrom,
              value: fmtDateTime(until),
              icon: Icons.event_available,
              color: Wf.bad,
            ),
            const SizedBox(height: Sp.x1),
            LiveTick(
              builder: (context, now) => Text(
                S.timeRemaining(fmtHm(until.difference(now))),
                style: Tx.small,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ViolationGroup extends StatelessWidget {
  const _ViolationGroup({required this.label, required this.records});

  final String label;
  final List<ViolationRecord> records;

  @override
  Widget build(BuildContext context) {
    final total = records.fold<int>(0, (sum, r) => sum + r.points);
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Sp.x2, vertical: Sp.x1),
            color: Wf.bg,
            child: Row(
              children: [
                Expanded(child: Text(label, style: Tx.bold)),
                Text(S.groupSummary(records.length, total), style: Tx.small),
              ],
            ),
          ),
          for (final r in records)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sp.x2, vertical: Sp.x2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.report_outlined, size: 18, color: Wf.muted),
                  const SizedBox(width: Sp.x2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.reason, style: Tx.body),
                        Text('${fmtDateTime(r.at)} · ${r.location}',
                            style: Tx.small),
                      ],
                    ),
                  ),
                  const SizedBox(width: Sp.x2),
                  Text('+${r.points}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: Wf.bad)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
