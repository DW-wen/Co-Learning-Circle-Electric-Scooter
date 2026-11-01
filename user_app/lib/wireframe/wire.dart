// Shared UI kit for the Student app: spacing / radius scales and the small
// set of building blocks every screen uses. Colours and text styles come
// from theme.dart (light / dark palettes) and are re-exported here.

import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import 'theme.dart';

export 'theme.dart';

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
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 18;
}

/// Card surface used across the app: paper with a soft shadow (light) or a
/// hairline border (dark).
BoxDecoration cardDecoration({double radius = Rd.xl, Color? color}) =>
    BoxDecoration(
      color: color ?? Wf.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
          color: Wf.isDark ? Wf.border : Wf.border.withAlpha(150)),
      boxShadow: Wf.isDark
          ? null
          : [
              BoxShadow(
                  color: Wf.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 6)),
            ],
    );

/// Card with an optional small title and trailing widget.
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
      decoration: cardDecoration(),
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

/// Inset area standing in for content that is not built yet (map, camera…).
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
        color: Wf.fill.withAlpha(Wf.isDark ? 150 : 170),
        borderRadius: BorderRadius.circular(Rd.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter(Wf.border)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(Sp.x3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(Sp.x2),
                    decoration: BoxDecoration(
                      color: Wf.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Wf.muted, size: 22),
                  ),
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

/// Faint dot grid for placeholders (reads as "map / canvas").
class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 18.0;
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}

/// Pill-shaped status badge on a soft tint.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.color, this.icon});

  final String label;

  /// Defaults to the muted text colour.
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Wf.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Wf.tint(c),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: c),
            const SizedBox(width: Sp.x1),
          ],
          Text(label,
              style: TextStyle(
                  color: c, fontSize: 12, fontWeight: FontWeight.w700)),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
    this.color,
  });

  final String label;
  final String value;
  final IconData? icon;

  /// Defaults to the main text colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: Wf.muted),
              const SizedBox(width: Sp.x1),
            ],
            Flexible(child: Text(label, style: Tx.small)),
          ],
        ),
        const SizedBox(height: Sp.x1),
        Text(value, style: Tx.number(26, color ?? Wf.text)),
      ],
    );
  }
}

/// DEV-ONLY strip that lets a reviewer flip a screen between its states
/// (e.g. 充電中 / 充電完成 / 未充電) without a backend.
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
      padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Rd.lg),
        border: Border.all(color: Wf.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Icon(Icons.science_outlined, size: 16, color: Wf.muted),
          ),
          const SizedBox(width: Sp.x2),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(S.previewState, style: Tx.small),
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
    this.color,
    this.label,
  });

  final double x;
  final double y;

  /// Defaults to the accent colour.
  final Color? color;
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
                    color: Wf.tint(Wf.ok),
                    border: Border.all(color: Wf.ok.withAlpha(140)),
                    borderRadius: BorderRadius.circular(Rd.md),
                  ),
                ),
              ),
            for (final p in pins)
              Positioned(
                left: p.x * w - 9,
                top: p.y * h - 9,
                child: _pin(p),
              ),
          ],
        );
      },
    );
  }

  Widget _pin(MapPin p) {
    final c = p.color ?? Wf.primary;
    final dot = Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: Wf.surface, width: 3),
        boxShadow: [
          BoxShadow(color: c.withAlpha(90), blurRadius: 8),
        ],
      ),
    );
    final label = p.label;
    return label == null ? dot : Tooltip(message: label, child: dot);
  }
}
