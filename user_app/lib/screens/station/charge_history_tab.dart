import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/charging.dart';
import '../../models/rules.dart';
import '../../state/charging_controller.dart';
import '../../utils/format.dart';
import '../../wireframe/wire.dart';
import '../../wireframe/ymd_dropdown.dart';

enum _Mode { recent, date }

/// Past charging sessions within the last [ServiceRules.historyMonths]
/// months — all of them, or one day picked with the 年 - 月 - 日 dropdowns.
/// Each card: spot, date, charging / parked time, fee, and flags for
/// "ended early" and "stayed past the move-out limit".
class ChargeHistoryTab extends StatefulWidget {
  const ChargeHistoryTab({super.key, required this.controller});

  final ChargingController controller;

  @override
  State<ChargeHistoryTab> createState() => _ChargeHistoryTabState();
}

class _ChargeHistoryTabState extends State<ChargeHistoryTab> {
  _Mode _mode = _Mode.recent;
  DateTime? _day; // null until the user picks one

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final now = DateTime.now();
    final today = dateOnly(now);
    final first = c.historyStart(now);

    final inWindow = c.historyQuery(now);
    final marked = {for (final s in inWindow) dateOnly(s.startedAt)};
    // Default day: the most recent day that has records (else today).
    final day = clampDate(
      _day ??
          (inWindow.isEmpty ? today : dateOnly(inWindow.first.startedAt)),
      first,
      today,
    );
    final sessions =
        _mode == _Mode.recent ? inWindow : c.historyQuery(now, day: day);
    final total = sessions.fold<Duration>(
        Duration.zero, (sum, s) => sum + (s.duration ?? Duration.zero));

    return ListView(
      padding: const EdgeInsets.all(Sp.x4),
      children: [
        WireCard(
          title: S.queryTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<_Mode>(
                segments: [
                  ButtonSegment(
                    value: _Mode.recent,
                    label: Text(S.modeRecent(ServiceRules.historyMonths)),
                  ),
                  const ButtonSegment(
                      value: _Mode.date, label: Text(S.modeDate)),
                ],
                selected: {_mode},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              if (_mode == _Mode.date) ...[
                const SizedBox(height: Sp.x3),
                const Text(S.dateLabel, style: Tx.small),
                const SizedBox(height: Sp.x1),
                Align(
                  alignment: Alignment.centerLeft,
                  child: YmdDropdown(
                    value: day,
                    first: first,
                    last: today,
                    marked: marked,
                    onChanged: (d) => setState(() => _day = d),
                  ),
                ),
              ],
              const SizedBox(height: Sp.x2),
              Text(
                S.retentionNote(ServiceRules.historyMonths, fmtYmd(first)),
                style: Tx.small,
              ),
            ],
          ),
        ),
        const SizedBox(height: Sp.x4),
        Text(
          _mode == _Mode.recent
              ? S.historySummary(sessions.length, fmtHm(total))
              : S.daySummary(fmtYmd(day), sessions.length, fmtHm(total)),
          style: Tx.label,
        ),
        const SizedBox(height: Sp.x2),
        if (sessions.isEmpty)
          WirePlaceholder(
            label: _mode == _Mode.date ? S.noRecordsOnDate : S.noHistory,
            icon: Icons.history,
            height: 120,
          ),
        for (final s in sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.x2),
            child: _SessionCard(session: s),
          ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final ChargingSession session;

  @override
  Widget build(BuildContext context) {
    final charged = session.duration ?? Duration.zero;
    final parked = session.parkedDuration ?? charged;
    final after = session.occupiedAfterFinish ?? Duration.zero;
    final overstay = !session.stoppedEarly && after > ServiceRules.occupiedLimit;

    return WireCard(
      padding: const EdgeInsets.all(Sp.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.ev_station, size: 18, color: Wf.muted),
              const SizedBox(width: Sp.x2),
              Expanded(
                child: Text(
                    S.spotName(session.stationName, session.spotLabel),
                    style: Tx.bold),
              ),
              Text(S.fee(ServiceRules.feeFor(charged)), style: Tx.bold),
            ],
          ),
          const SizedBox(height: Sp.x2),
          Wrap(
            spacing: Sp.x4,
            runSpacing: Sp.x1,
            children: [
              _Meta(Icons.event, fmtDateTime(session.startedAt)),
              _Meta(Icons.bolt, S.charged(fmtHm(charged))),
              _Meta(Icons.local_parking, S.parked(fmtHm(parked))),
            ],
          ),
          if (session.stoppedEarly || overstay) ...[
            const SizedBox(height: Sp.x2),
            Wrap(
              spacing: Sp.x2,
              children: [
                if (session.stoppedEarly) const StatusBadge(S.stoppedEarly),
                if (overstay)
                  StatusBadge(S.overstay(fmtHm(after)),
                      color: Wf.bad, icon: Icons.warning_amber_rounded),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Wf.muted),
        const SizedBox(width: Sp.x1),
        Text(text, style: Tx.small),
      ],
    );
  }
}
