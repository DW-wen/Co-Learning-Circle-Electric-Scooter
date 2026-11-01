import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../l10n/strings.dart';
import '../../models/charging.dart';
import '../../models/rules.dart';
import '../../state/charging_controller.dart';
import '../../utils/format.dart';
import '../../wireframe/wire.dart';
import '../common/report_issue_sheet.dart';

enum _ChargePreview { charging, finished, none }

/// Part 1 · sections 1 & 2: live charging status + last successful charge,
/// plus session controls (end / unlock, report, reminders).
class ChargingScreen extends StatefulWidget {
  const ChargingScreen({
    super.key,
    required this.controller,
    required this.onFindSpot,
  });

  final ChargingController controller;

  /// Jump to the 充電站 tab (shown when no session is active).
  final VoidCallback onFindSpot;

  @override
  State<ChargingScreen> createState() => _ChargingScreenState();
}

class _ChargingScreenState extends State<ChargingScreen> {
  // Reminder toggles (UI only until push notifications exist).
  bool _notifyDone = true;
  bool _notifyMove = true;

  ChargingController get _c => widget.controller;

  void _preview(_ChargePreview p) => _c.previewState(
        switch (p) {
          _ChargePreview.charging => ChargeState.charging,
          _ChargePreview.finished => ChargeState.finished,
          _ChargePreview.none => null,
        },
        cannedCharging: MockData.chargingNow(),
        cannedFinished: MockData.finishedRecently(),
      );

  Future<void> _confirmEnd(ChargingSession s) async {
    final early = s.state == ChargeState.charging;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(early ? S.endEarlyTitle : S.unlockTitle),
        content: Text(early ? S.endEarlyBody : S.unlockBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(S.confirmUnlock),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _c.endSession();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(S.unlockedThanks)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.chargingTitle),
        actions: const [ThemeToggleButton()],
      ),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) {
          final current = _c.current;
          final preview = current == null
              ? _ChargePreview.none
              : (current.state == ChargeState.charging
                  ? _ChargePreview.charging
                  : _ChargePreview.finished);

          return ListView(
            padding: const EdgeInsets.all(Sp.x4),
            children: [
              PreviewSwitcher<_ChargePreview>(
                value: preview,
                options: const {
                  _ChargePreview.charging: S.previewCharging,
                  _ChargePreview.finished: S.previewFinished,
                  _ChargePreview.none: S.previewNotCharging,
                },
                onChanged: _preview,
              ),
              const SizedBox(height: Sp.x4),
              _StatusCard(session: current),
              const SizedBox(height: Sp.x3),
              if (current != null) ...[
                _SessionActions(
                  session: current,
                  onEnd: () => _confirmEnd(current),
                  onReport: () =>
                      showReportIssueSheet(context, spotId: current.spotId),
                ),
                const SizedBox(height: Sp.x4),
                _reminders(),
              ] else
                FilledButton.tonalIcon(
                  onPressed: widget.onFindSpot,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text(S.findSpot),
                ),
              const SizedBox(height: Sp.x4),
              _LastChargeCard(session: _c.lastSuccessful),
            ],
          );
        },
      ),
    );
  }

  Widget _reminders() {
    return WireCard(
      title: S.reminders,
      padding: const EdgeInsets.fromLTRB(Sp.x4, Sp.x4, Sp.x4, Sp.x2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(S.notifyDone),
            value: _notifyDone,
            onChanged: (v) => setState(() => _notifyDone = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
                S.notifyMove(ServiceRules.moveReminderAfter.inMinutes)),
            value: _notifyMove,
            onChanged: (v) => setState(() => _notifyMove = v),
          ),
          Text(S.pushTbd, style: Tx.small),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.session});

  final ChargingSession? session;

  @override
  Widget build(BuildContext context) {
    final s = session;
    if (s == null) {
      return const WireCard(
        title: S.currentStatus,
        trailing:
            StatusBadge(S.badgeNotCharging, icon: Icons.power_off_outlined),
        child: WirePlaceholder(
          label: S.noActiveSession,
          icon: Icons.ev_station_outlined,
          height: 120,
        ),
      );
    }

    final charging = s.state == ChargeState.charging;
    return WireCard(
      title: S.currentStatus,
      trailing: charging
          ? StatusBadge(S.badgeCharging, color: Wf.info, icon: Icons.bolt)
          : StatusBadge(S.badgeFinished,
              color: Wf.ok, icon: Icons.check_circle_outline),
      child: LiveTick(
        builder: (context, now) =>
            charging ? _charging(s, now) : _finished(s, now),
      ),
    );
  }

  /// State A - elapsed + estimated remaining.
  Widget _charging(ChargingSession s, DateTime now) {
    final elapsed = now.difference(s.startedAt);
    final total = s.estimatedTotal ?? Duration.zero;
    final remaining = total - elapsed;
    final progress = total.inSeconds == 0
        ? 0.0
        : (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.spotName(s.stationName, s.spotLabel), style: Tx.muted),
        const SizedBox(height: Sp.x3),
        Row(
          children: [
            Expanded(
              child: BigStat(
                label: S.elapsed,
                value: fmtHms(elapsed),
                icon: Icons.timer_outlined,
                color: Wf.primary,
              ),
            ),
            Expanded(
              child: BigStat(
                label: S.estRemaining,
                value: remaining.isNegative ? S.anyMoment : fmtHms(remaining),
                icon: Icons.hourglass_bottom,
              ),
            ),
          ],
        ),
        const SizedBox(height: Sp.x3),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(Rd.md),
        ),
        const SizedBox(height: Sp.x2),
        Text(
          S.startedEstDone(
              fmtTime(s.startedAt), fmtTime(s.startedAt.add(total))),
          style: Tx.small,
        ),
        Text(S.chargingLimitNote(ServiceRules.chargingLimit.inHours),
            style: Tx.small),
      ],
    );
  }

  /// State B - elapsed since completion + move-vehicle deadline.
  Widget _finished(ChargingSession s, DateTime now) {
    final finished = s.finishedAt!;
    final since = now.difference(finished);
    final deadline = finished.add(ServiceRules.occupiedLimit);
    final left = deadline.difference(now);
    final overdue = left.isNegative;
    final color = overdue ? Wf.bad : Wf.warn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.spotName(s.stationName, s.spotLabel), style: Tx.muted),
        const SizedBox(height: Sp.x3),
        BigStat(
          label: S.elapsedSinceFinished,
          value: fmtHms(since),
          icon: Icons.timer_outlined,
          color: overdue ? Wf.bad : Wf.primary,
        ),
        const SizedBox(height: Sp.x3),
        Text(S.finishedAt(fmtDateTime(finished)), style: Tx.small),
        const SizedBox(height: Sp.x2),
        Container(
          padding: const EdgeInsets.all(Sp.x2),
          decoration: BoxDecoration(
            color: Wf.tint(color),
            borderRadius: BorderRadius.circular(Rd.md),
          ),
          child: Row(
            children: [
              Icon(overdue ? Icons.warning_amber_rounded : Icons.info_outline,
                  size: 16, color: color),
              const SizedBox(width: Sp.x2),
              Expanded(
                child: Text(
                  overdue
                      ? S.moveOverdue(fmtHm(-left))
                      : S.moveBy(fmtTime(deadline), fmtHm(left)),
                  style: TextStyle(fontSize: 12, color: color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionActions extends StatelessWidget {
  const _SessionActions({
    required this.session,
    required this.onEnd,
    required this.onReport,
  });

  final ChargingSession session;
  final VoidCallback onEnd;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final charging = session.state == ChargeState.charging;
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: charging
                ? null
                : FilledButton.styleFrom(backgroundColor: Wf.ok),
            onPressed: onEnd,
            icon: Icon(charging ? Icons.stop_circle_outlined : Icons.lock_open),
            label: Text(charging ? S.stopAndUnlock : S.unlockAndLeave),
          ),
        ),
        const SizedBox(width: Sp.x2),
        OutlinedButton.icon(
          onPressed: onReport,
          icon: const Icon(Icons.report_problem_outlined),
          label: const Text(S.report),
        ),
      ],
    );
  }
}

class _LastChargeCard extends StatelessWidget {
  const _LastChargeCard({required this.session});

  final ChargingSession? session;

  @override
  Widget build(BuildContext context) {
    final s = session;
    return WireCard(
      title: S.lastSuccessfulCharge,
      trailing: Icon(Icons.history, size: 18, color: Wf.muted),
      child: s == null
          ? Text(S.noChargeYet, style: Tx.muted)
          : Column(
              children: [
                KeyValue(S.completedAt, fmtDateTime(s.finishedAt!)),
                KeyValue(S.chargeDuration, fmtHm(s.duration!)),
                KeyValue(S.spot, S.spotName(s.stationName, s.spotLabel)),
              ],
            ),
    );
  }
}
