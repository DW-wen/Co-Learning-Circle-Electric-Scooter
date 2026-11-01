// Wireframe kit for the Campus Security dashboard (same tokens as user_app).
//
// Layout-review stage: everything here is intentionally plain (greys + one
// accent per semantic state). The token classes (Sp / Rd / Wf / Tx) are the
// single place to change when we move on to visual refinement.

import 'dart:async';

import 'package:flutter/material.dart';

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

// ---------------------------------------------------------------------------
// Desktop-specific pieces
// ---------------------------------------------------------------------------

/// Page header (title, subtitle, actions) above a full-height body.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.child,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(Sp.x6, Sp.x4, Sp.x6, Sp.x4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Wf.text)),
                    if (subtitle != null) Text(subtitle!, style: Tx.muted),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: child),
      ],
    );
  }
}

/// KPI tile: small label + big number.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.color = Wf.text,
    this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.x3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Wf.border),
        borderRadius: BorderRadius.circular(Rd.lg),
      ),
      child: BigStat(label: label, value: value, color: color, icon: icon),
    );
  }
}

/// Outlined dropdown with a floating label. [items] maps value -> text.
class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 200,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x2),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isDense: true,
            isExpanded: true,
            items: [
              for (final e in items.entries)
                DropdownMenuItem<T>(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => onChanged(v as T),
          ),
        ),
      ),
    );
  }
}

/// Dense search field used in toolbars.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.width = 320,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 20),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// White bordered box that hosts a DataTable, scrolling horizontally
/// if the window is narrower than the table.
class TableCard extends StatelessWidget {
  const TableCard({super.key, required this.table});

  final DataTable table;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Wf.border),
        borderRadius: BorderRadius.circular(Rd.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: c.maxWidth),
            child: table,
          ),
        ),
      ),
    );
  }
}
