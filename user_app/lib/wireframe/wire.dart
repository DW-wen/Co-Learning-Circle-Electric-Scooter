// Wireframe kit for the Student app.
//
// Layout-review stage: everything here is intentionally plain (greys + one
// accent per semantic state). The token classes (Sp / Rd / Wf / Tx) are the
// single place to change when we move on to visual refinement.

import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';

/// Tailwind-like spacing scale (1 unit = 4 logical px): p-1, p-2, p-3 ...
class Sp {
  Sp._();
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x6 = 24;
  static const double x8 = 32;
}

/// Border radius scale: rounded-md / rounded-lg / rounded-xl.
class Rd {
  Rd._();
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
}

/// Wireframe palette (Tailwind gray-* plus semantic accents).
class Wf {
  Wf._();
  static const Color bg = Color(0xFFF3F4F6); // gray-100
  static const Color fill = Color(0xFFE5E7EB); // gray-200
  static const Color border = Color(0xFFD1D5DB); // gray-300
  static const Color muted = Color(0xFF6B7280); // gray-500
  static const Color text = Color(0xFF111827); // gray-900
  static const Color ok = Color(0xFF16A34A); // green-600
  static const Color warn = Color(0xFFD97706); // amber-600
  static const Color bad = Color(0xFFDC2626); // red-600
  static const Color info = Color(0xFF2563EB); // blue-600
}

/// Text styles.
class Tx {
  Tx._();
  static const TextStyle label = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Wf.muted,
      letterSpacing: 0.4);
  static const TextStyle muted = TextStyle(fontSize: 13, color: Wf.muted);
  static const TextStyle small = TextStyle(fontSize: 12, color: Wf.muted);
  static const TextStyle body = TextStyle(fontSize: 14, color: Wf.text);
  static const TextStyle bold =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Wf.text);
}

/// Bordered white card with an optional uppercase title and trailing widget.
class WireCard extends StatelessWidget {
  const WireCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.x4),
  });

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || trailing != null;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Wf.border),
        borderRadius: BorderRadius.circular(Rd.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader) ...[
            Row(
              children: [
                Expanded(child: Text(title ?? '', style: Tx.label)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: Sp.x3),
          ],
          child,
        ],
      ),
    );
  }
}

/// Grey box standing in for content that is not built yet (map, camera...).
/// Pass [height] = null to fill the parent's constraints.
class WirePlaceholder extends StatelessWidget {
  const WirePlaceholder({
    super.key,
    required this.label,
    this.icon = Icons.image_outlined,
    this.height = 160,
    this.child,
  });

  final String label;
  final IconData icon;
  final double? height;

  /// Optional overlay drawn on top of the placeholder (e.g. map pins).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Wf.fill,
        border: Border.all(color: Wf.border),
        borderRadius: BorderRadius.circular(Rd.lg),
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(Sp.x3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Wf.muted, size: 28),
                  const SizedBox(height: Sp.x2),
                  Text(label, style: Tx.small, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          if (child != null) Positioned.fill(child: child!),
        ],
      ),
    );
  }
}

/// Pill-shaped status badge.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.color = Wf.muted, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x2, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: Sp.x1),
          ],
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// "Label ........ value" row.
class KeyValue extends StatelessWidget {
  const KeyValue(this.label, this.value, {super.key, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.x1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Tx.muted),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end, style: valueStyle ?? Tx.bold),
          ),
        ],
      ),
    );
  }
}

/// Small label above a large value.
class BigStat extends StatelessWidget {
  const BigStat({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color = Wf.text,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Wf.muted),
              const SizedBox(width: Sp.x1),
            ],
            Flexible(child: Text(label, style: Tx.small)),
          ],
        ),
        const SizedBox(height: Sp.x1),
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

/// DEV-ONLY strip that lets a reviewer flip a screen between its states
/// (e.g. Charging / Finished / Not charging) without a backend.
/// Remove once real data is wired in.
class PreviewSwitcher<T> extends StatelessWidget {
  const PreviewSwitcher({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.x2),
      decoration: BoxDecoration(
        color: Wf.warn.withAlpha(18),
        border: Border.all(color: Wf.warn.withAlpha(110)),
        borderRadius: BorderRadius.circular(Rd.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.science_outlined, size: 16, color: Wf.warn),
          ),
          const SizedBox(width: Sp.x2),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(S.previewState,
                    style: TextStyle(fontSize: 12, color: Wf.warn)),
                for (final e in options.entries)
                  ChoiceChip(
                    label: Text(e.value),
                    selected: e.key == value,
                    onSelected: (_) => onChanged(e.key),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rebuilds [builder] every [interval] with the current time.
/// Used for live timers (elapsed / remaining / countdowns).
class LiveTick extends StatefulWidget {
  const LiveTick({
    super.key,
    required this.builder,
    this.interval = const Duration(seconds: 1),
  });

  final Widget Function(BuildContext context, DateTime now) builder;
  final Duration interval;

  @override
  State<LiveTick> createState() => _LiveTickState();
}

class _LiveTickState extends State<LiveTick> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now);
}

/// A pin on a placeholder map. [x] and [y] are normalised (0..1).
class MapPin {
  const MapPin({
    required this.x,
    required this.y,
    this.color = Wf.info,
    this.label,
  });

  final double x;
  final double y;
  final Color color;
  final String? label;
}

/// Overlay that draws [pins] (and optional normalised [zones]) on top of a
/// [WirePlaceholder]. Replaced by a real map widget later.
class MapPins extends StatelessWidget {
  const MapPins({super.key, required this.pins, this.zones = const []});

  final List<MapPin> pins;
  final List<Rect> zones;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        return Stack(
          children: [
            for (final z in zones)
              Positioned(
                left: z.left * w,
                top: z.top * h,
                width: z.width * w,
                height: z.height * h,
                child: Container(
                  decoration: BoxDecoration(
                    color: Wf.ok.withAlpha(25),
                    border: Border.all(color: Wf.ok.withAlpha(140)),
                    borderRadius: BorderRadius.circular(Rd.md),
                  ),
                ),
              ),
            for (final p in pins)
              Positioned(
                left: p.x * w - 11,
                top: p.y * h - 22,
                child: _pinIcon(p),
              ),
          ],
        );
      },
    );
  }

  Widget _pinIcon(MapPin p) {
    final icon = Icon(Icons.location_on, color: p.color, size: 22);
    final label = p.label;
    return label == null ? icon : Tooltip(message: label, child: icon);
  }
}
