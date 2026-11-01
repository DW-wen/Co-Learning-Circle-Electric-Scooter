import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../state/manager_controller.dart';
import '../../utils/format.dart';
import '../../wireframe/wire.dart';
import '../common/dialogs.dart';

/// Part 2 · section 3a: search students -> accumulated points and when each
/// point record was made; officers can 記點 / 停權 from here.
class PointsLookupScreen extends StatefulWidget {
  const PointsLookupScreen({super.key, required this.controller});

  final ManagerController controller;

  @override
  State<PointsLookupScreen> createState() => _PointsLookupScreenState();
}

class _PointsLookupScreenState extends State<PointsLookupScreen> {
  String _query = '';
  String? _selectedId;

  ManagerController get _c => widget.controller;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: S.pointsTitle,
      subtitle: S.pointsSubtitle,
      child: ListenableBuilder(
        listenable: _c,
        builder: (context, _) => _body(),
      ),
    );
  }

  Widget _body() {
    final now = DateTime.now();
    final students = _c.students.where((s) {
      if (_query.isEmpty) return true;
      return '${s.id} ${s.name}'.toLowerCase().contains(_query);
    }).toList()
      ..sort((a, b) => _c.pointsOf(b.id).compareTo(_c.pointsOf(a.id)));

    Student? selected;
    for (final s in _c.students) {
      if (s.id == _selectedId) selected = s;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ------------------------------------------------------------ master
        // Material (not a coloured Container) so ListTile selection shows.
        Material(
          color: Wf.surface,
          child: SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(Sp.x4),
                child: SearchField(
                  hint: S.searchStudent,
                  width: double.infinity,
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: students.isEmpty
                    ? Center(
                        child: Text(S.noStudents, style: Tx.muted))
                    : ListView(
                        children: [
                          for (final s in students)
                            ListTile(
                              selected: s.id == _selectedId,
                              selectedTileColor: Wf.tint(Wf.primary),
                              leading: _c.activeBan(s.id, now) != null
                                  ? Icon(Icons.block, color: Wf.bad)
                                  : const Icon(Icons.person_outline),
                              title: Text(s.name),
                              subtitle: Text(s.id),
                              trailing:
                                  Text(S.pts(_c.pointsOf(s.id)), style: Tx.bold),
                              onTap: () => setState(() => _selectedId = s.id),
                            ),
                        ],
                      ),
              ),
            ],
          ),
          ),
        ),
        const VerticalDivider(width: 1),
        // ------------------------------------------------------------ detail
        Expanded(
          child: selected == null
              ? const Padding(
                  padding: EdgeInsets.all(Sp.x6),
                  child: WirePlaceholder(
                    label: S.selectStudent,
                    icon: Icons.person_search,
                    height: 200,
                  ),
                )
              : _detail(selected, now),
        ),
      ],
    );
  }

  Widget _detail(Student s, DateTime now) {
    final records = _c.pointRecords.where((r) => r.student.id == s.id).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    final ban = _c.activeBan(s.id, now);

    return ListView(
      padding: const EdgeInsets.all(Sp.x6),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(s.id, style: Tx.muted),
                ],
              ),
            ),
            ban == null
                ? StatusBadge(S.serviceAllowed,
                    color: Wf.ok, icon: Icons.check_circle_outline)
                : StatusBadge(S.bannedUntil(fmtDateTime(ban.until)),
                    color: Wf.bad, icon: Icons.block),
            const SizedBox(width: Sp.x3),
            FilledButton.icon(
              onPressed: () => recordPointsFlow(
                context,
                _c,
                student: s,
                location: S.none,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(S.recordPoints),
            ),
            const SizedBox(width: Sp.x2),
            OutlinedButton.icon(
              onPressed:
                  ban == null ? () => issueBanFlow(context, _c, student: s) : null,
              icon: const Icon(Icons.block, size: 18),
              label: const Text(S.issueBan),
            ),
          ],
        ),
        const SizedBox(height: Sp.x4),
        Row(
          children: [
            Expanded(
                child: StatTile(
                    label: S.kpiTotalPoints,
                    value: '${_c.pointsOf(s.id)}',
                    color: Wf.bad)),
            const SizedBox(width: Sp.x3),
            Expanded(
                child: StatTile(
                    label: S.kpiRecordCount, value: '${records.length}')),
            const SizedBox(width: Sp.x3),
            Expanded(
                child: StatTile(
                    label: S.kpiLastRecorded,
                    value:
                        records.isEmpty ? S.none : fmtDate(records.first.at))),
          ],
        ),
        const SizedBox(height: Sp.x2),
        Text(S.rulesTbd, style: Tx.small),
        const SizedBox(height: Sp.x4),
        if (records.isEmpty)
          const WirePlaceholder(
              label: S.noPointRecords, icon: Icons.verified, height: 120)
        else
          TableCard(
            table: DataTable(
              headingRowColor: WidgetStatePropertyAll(Wf.bg),
              columns: const [
                DataColumn(label: Text(S.colRecordedAt)),
                DataColumn(label: Text(S.colPoints), numeric: true),
                DataColumn(label: Text(S.colReason)),
                DataColumn(label: Text(S.colLocation)),
                DataColumn(label: Text(S.colRecordedBy)),
              ],
              rows: [
                for (final r in records)
                  DataRow(cells: [
                    DataCell(Text(fmtDateTime(r.at))),
                    DataCell(Text('+${r.points}')),
                    DataCell(Text(r.reason)),
                    DataCell(Text(r.location)),
                    DataCell(Text(r.recordedBy)),
                  ]),
              ],
            ),
          ),
      ],
    );
  }
}
