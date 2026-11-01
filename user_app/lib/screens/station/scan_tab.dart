import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/charging.dart';
import '../../models/rules.dart';
import '../../models/violation.dart';
import '../../utils/format.dart';
import '../../wireframe/wire.dart';

/// QR scan viewfinder (placeholder) + manual spot-ID entry + usage rules.
/// Real scanning needs a camera package (e.g. mobile_scanner) - later stage.
class ScanTab extends StatefulWidget {
  const ScanTab({
    super.key,
    required this.current,
    required this.standing,
    required this.onUnlock,
    required this.onScan,
    required this.onShowSession,
  });

  final ChargingSession? current;
  final ViolationStanding standing;
  final ValueChanged<String> onUnlock;
  final VoidCallback onScan;
  final VoidCallback onShowSession;

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onUnlock(_ctrl.text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.current;
    final until = widget.standing.restrictedUntil;
    final restricted = !widget.standing.allowed;
    final blocked = current != null || restricted;

    return ListView(
      padding: const EdgeInsets.all(Sp.x4),
      children: [
        if (current != null) ...[
          _Banner(
            color: Wf.info,
            icon: Icons.bolt,
            text: S.inSession(S.spotName(current.stationName, current.spotLabel)),
            action: TextButton(
              onPressed: widget.onShowSession,
              child: const Text(S.viewSession),
            ),
          ),
          const SizedBox(height: Sp.x3),
        ] else if (restricted) ...[
          _Banner(
            color: Wf.bad,
            icon: Icons.block,
            text: until == null
                ? S.restrictedCannotUse
                : S.restrictedBanner(fmtDateTime(until)),
          ),
          const SizedBox(height: Sp.x3),
        ],
        const WirePlaceholder(
          label: S.cameraPlaceholder,
          icon: Icons.qr_code_scanner,
          height: 220,
        ),
        const SizedBox(height: Sp.x3),
        FilledButton.icon(
          onPressed: blocked ? null : widget.onScan,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text(S.scanQr),
        ),
        const SizedBox(height: Sp.x6),
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Sp.x3),
              child: Text(S.orEnterId, style: Tx.small),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: Sp.x4),
        TextField(
          controller: _ctrl,
          enabled: !blocked,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: S.spotIdLabel,
            hintText: S.spotIdHint,
            prefixIcon: Icon(Icons.tag),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: Sp.x3),
        OutlinedButton.icon(
          onPressed: blocked ? null : _submit,
          icon: const Icon(Icons.lock_open),
          label: const Text(S.unlockSpot),
        ),
        const SizedBox(height: Sp.x4),
        WireCard(
          title: S.rulesTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _rule(S.ruleChargingLimit(ServiceRules.chargingLimit.inHours)),
              _rule(S.ruleMoveAfter(ServiceRules.occupiedLimit.inMinutes)),
              _rule(S.ruleScanFirst),
              _rule(S.rulePoints),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rule(String text) => Padding(
        padding: const EdgeInsets.only(bottom: Sp.x1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ', style: Tx.body),
            Expanded(child: Text(text, style: Tx.body)),
          ],
        ),
      );
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.icon,
    required this.text,
    this.action,
  });

  final Color color;
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x2),
      decoration: BoxDecoration(
        color: Wf.tint(color),
        border: Border.all(color: color.withAlpha(100)),
        borderRadius: BorderRadius.circular(Rd.lg),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: Sp.x2),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13, color: color, fontWeight: FontWeight.w600)),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
