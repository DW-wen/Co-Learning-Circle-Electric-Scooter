import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../wireframe/wire.dart';

/// Bottom sheet to report a problem with a charging spot (broken charger,
/// spot taken by someone else, damaged cable, unreadable QR code ...).
/// Submitting only shows a confirmation for now (no backend yet).
Future<void> showReportIssueSheet(BuildContext context, {String? spotId}) async {
  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ReportSheet(spotId: spotId),
  );
  if (sent == true && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(S.reportSent)));
  }
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({this.spotId});

  final String? spotId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _type;
  late final TextEditingController _spot =
      TextEditingController(text: widget.spotId ?? '');
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _spot.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Sp.x4,
        0,
        Sp.x4,
        Sp.x4 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(S.reportTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: Sp.x3),
            Text(S.issueType, style: Tx.label),
            const SizedBox(height: Sp.x2),
            Wrap(
              spacing: Sp.x2,
              runSpacing: Sp.x2,
              children: [
                for (final t in S.issueTypes)
                  ChoiceChip(
                    label: Text(t),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: Sp.x4),
            TextField(
              controller: _spot,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: S.spotIdOptional,
                hintText: S.spotIdHint,
                isDense: true,
              ),
            ),
            const SizedBox(height: Sp.x3),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: S.noteOptional,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: Sp.x2),
            const WirePlaceholder(
              label: S.photoPlaceholder,
              icon: Icons.add_a_photo_outlined,
              height: 72,
            ),
            const SizedBox(height: Sp.x4),
            FilledButton(
              onPressed:
                  _type == null ? null : () => Navigator.pop(context, true),
              child: const Text(S.submitReport),
            ),
          ],
        ),
      ),
    );
  }
}
