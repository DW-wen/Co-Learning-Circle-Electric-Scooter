import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../state/manager_controller.dart';
import '../../utils/format.dart';
import '../../wireframe/wire.dart';
import '../common/dialogs.dart';

/// Part 2 · section 3b: students currently suspended, ban durations, and
/// an early-lift action.
class BanListScreen extends StatefulWidget {
  const BanListScreen({super.key, required this.controller});

  final ManagerController controller;

  @override
  State<BanListScreen> createState() => _BanListScreenState();
}

class _BanListScreenState extends State<BanListScreen> {
  String _query = '';

  ManagerController get _c => widget.controller;

  Future<void> _lift(Ban b) async {
    final ok = await confirmDialog(
      context,
      title: S.liftBanTitle(b.student.name),
      body: S.liftBanBody,
      confirmLabel: S.liftBan,
    );
    if (!ok || !mounted) return;
    _c.liftBan(b);
    showSnack(context, S.banLifted(b.student.name));
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: S.bansTitle,
      subtitle: S.bansSubtitle,
      actions: [
        SearchField(
          hint: S.searchStudent,
          width: 280,
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
        ),
      ],
      // Ticks every 30 s so "剩餘" stays current.
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
    final active = _c.bans.where((b) {
      if (!b.isActive(now)) return false;
      if (_query.isEmpty) return true;
      return '${b.student.id} ${b.student.name}'
          .toLowerCase()
          .contains(_query);
    }).toList()
      ..sort((a, b) => a.until.compareTo(b.until));

    return ListView(
      padding: const EdgeInsets.all(Sp.x6),
      children: [
        Text(S.suspendedCount(active.length), style: Tx.label),
        const SizedBox(height: Sp.x3),
        if (active.isEmpty)
          const WirePlaceholder(
            label: S.noBans,
            icon: Icons.verified_user_outlined,
            height: 160,
          )
        else
          TableCard(
            table: DataTable(
              headingRowColor: const WidgetStatePropertyAll(Wf.bg),
              columns: const [
                DataColumn(label: Text(S.colStudentId)),
                DataColumn(label: Text(S.colName)),
                DataColumn(label: Text(S.colReason)),
                DataColumn(label: Text(S.colFrom)),
                DataColumn(label: Text(S.colUntil)),
                DataColumn(label: Text(S.colLength)),
                DataColumn(label: Text(S.colRemaining)),
                DataColumn(label: Text(S.colActions)),
              ],
              rows: [
                for (final b in active)
                  DataRow(cells: [
                    DataCell(Text(b.student.id)),
                    DataCell(Text(b.student.name)),
                    DataCell(Text(b.reason)),
                    DataCell(Text(fmtDateTime(b.from))),
                    DataCell(Text(fmtDateTime(b.until))),
                    DataCell(Text(_dh(b.until.difference(b.from)))),
                    DataCell(StatusBadge(_dh(b.until.difference(now)),
                        color: Wf.bad)),
                    DataCell(TextButton(
                      onPressed: () => _lift(b),
                      child: const Text(S.liftBan),
                    )),
                  ]),
              ],
            ),
          ),
      ],
    );
  }

  String _dh(Duration d) => S.daysHours(d.inDays, d.inHours.remainder(24));
}
