import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../state/manager_controller.dart';
import '../../wireframe/wire.dart';

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Yes / no confirmation.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(S.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: Wf.bad)
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok == true;
}

/// 記點: pick reason + points, then record via [controller].
Future<void> recordPointsFlow(
  BuildContext context,
  ManagerController controller, {
  required Student student,
  required String location,
  String? reason,
}) async {
  final result = await showDialog<({int points, String reason})>(
    context: context,
    builder: (_) => _RecordPointsDialog(
      student: student,
      location: location,
      initialReason: reason,
    ),
  );
  if (result == null || !context.mounted) return;
  controller.recordPoints(
    student: student,
    points: result.points,
    reason: result.reason,
    location: location,
  );
  showSnack(context, S.pointsRecorded(student.name, result.points));
}

class _RecordPointsDialog extends StatefulWidget {
  const _RecordPointsDialog({
    required this.student,
    required this.location,
    this.initialReason,
  });

  final Student student;
  final String location;
  final String? initialReason;

  @override
  State<_RecordPointsDialog> createState() => _RecordPointsDialogState();
}

class _RecordPointsDialogState extends State<_RecordPointsDialog> {
  late String _reason = widget.initialReason ?? S.violationReasons.first;
  int _points = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.recordPointsTitle(widget.student.name)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KeyValue(S.colStudentId, widget.student.id),
            KeyValue(S.location, widget.location),
            const SizedBox(height: Sp.x3),
            Text(S.reason, style: Tx.label),
            const SizedBox(height: Sp.x2),
            Wrap(
              spacing: Sp.x2,
              runSpacing: Sp.x2,
              children: [
                for (final r in S.violationReasons)
                  ChoiceChip(
                    label: Text(r),
                    selected: _reason == r,
                    onSelected: (_) => setState(() => _reason = r),
                  ),
              ],
            ),
            const SizedBox(height: Sp.x4),
            Row(
              children: [
                Text(S.points, style: Tx.label),
                const Spacer(),
                IconButton.outlined(
                  onPressed:
                      _points > 1 ? () => setState(() => _points--) : null,
                  icon: const Icon(Icons.remove, size: 18),
                  tooltip: S.decrease,
                ),
                SizedBox(
                  width: 64,
                  child: Text(S.pts(_points),
                      textAlign: TextAlign.center, style: Tx.bold),
                ),
                IconButton.outlined(
                  onPressed:
                      _points < 10 ? () => setState(() => _points++) : null,
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: S.increase,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(S.cancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, (points: _points, reason: _reason)),
          child: const Text(S.confirmRecord),
        ),
      ],
    );
  }
}

/// 停權: pick a duration, then issue via [controller].
Future<void> issueBanFlow(
  BuildContext context,
  ManagerController controller, {
  required Student student,
}) async {
  final days = await showDialog<int>(
    context: context,
    builder: (_) => _BanDialog(student: student),
  );
  if (days == null || !context.mounted) return;
  controller.issueBan(
    student: student,
    days: days,
    reason: S.banReasonDefault,
  );
  showSnack(context, S.banIssued(student.name, days));
}

class _BanDialog extends StatefulWidget {
  const _BanDialog({required this.student});

  final Student student;

  @override
  State<_BanDialog> createState() => _BanDialogState();
}

class _BanDialogState extends State<_BanDialog> {
  int _days = S.banDayOptions[1];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.banTitle(widget.student.name)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KeyValue(S.colStudentId, widget.student.id),
            const KeyValue(S.banReason, S.banReasonDefault),
            const SizedBox(height: Sp.x3),
            Text(S.banLength, style: Tx.label),
            const SizedBox(height: Sp.x2),
            Wrap(
              spacing: Sp.x2,
              children: [
                for (final d in S.banDayOptions)
                  ChoiceChip(
                    label: Text(S.days(d)),
                    selected: _days == d,
                    onSelected: (_) => setState(() => _days = d),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(S.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Wf.bad),
          onPressed: () => Navigator.pop(context, _days),
          child: const Text(S.confirmBan),
        ),
      ],
    );
  }
}

/// 標記已解決: asks for a resolution note. Returns null if cancelled.
Future<String?> resolutionDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _ResolutionDialog(),
  );
}

class _ResolutionDialog extends StatefulWidget {
  const _ResolutionDialog();

  @override
  State<_ResolutionDialog> createState() => _ResolutionDialogState();
}

class _ResolutionDialogState extends State<_ResolutionDialog> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(S.resolveTitle),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: S.resolutionLabel,
            hintText: S.resolutionHint,
            alignLabelWithHint: true,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(S.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _ctrl.text.trim().isEmpty ? S.statusResolved : _ctrl.text.trim(),
          ),
          child: const Text(S.confirmResolve),
        ),
      ],
    );
  }
}
