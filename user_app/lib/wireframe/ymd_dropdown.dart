import 'package:flutter/material.dart';

import '../utils/format.dart';
import 'wire.dart';

/// Gregorian date selector made of three dropdowns:  [年] - [月] - [日].
///
/// Only dates between [first] and [last] (inclusive, date-only) can be
/// picked: the year list covers that span, the month list is limited at the
/// first / last year, and the day list follows the month length (leap years
/// included) and the range ends. Changing the year or month clamps the
/// other parts back into range. Days in [marked] get a dot (= has records).
class YmdDropdown extends StatelessWidget {
  const YmdDropdown({
    super.key,
    required this.value,
    required this.first,
    required this.last,
    required this.onChanged,
    this.marked = const {},
  });

  final DateTime value;
  final DateTime first;
  final DateTime last;
  final ValueChanged<DateTime> onChanged;

  /// Date-only values of days that have records.
  final Set<DateTime> marked;

  void _emit(int y, int m, int d) {
    final dim = daysInMonth(y, m);
    onChanged(clampDate(DateTime(y, m, d > dim ? dim : d), first, last));
  }

  @override
  Widget build(BuildContext context) {
    final v = clampDate(dateOnly(value), first, last);
    final mFrom = v.year == first.year ? first.month : 1;
    final mTo = v.year == last.year ? last.month : 12;
    final dFrom =
        (v.year == first.year && v.month == first.month) ? first.day : 1;
    final dTo = (v.year == last.year && v.month == last.month)
        ? last.day
        : daysInMonth(v.year, v.month);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _box(
          value: v.year,
          items: [for (var y = first.year; y <= last.year; y++) y],
          label: (y) => '$y',
          onChanged: (y) => _emit(y, v.month, v.day),
        ),
        const _Dash(),
        _box(
          value: v.month,
          items: [for (var m = mFrom; m <= mTo; m++) m],
          label: two,
          onChanged: (m) => _emit(v.year, m, v.day),
        ),
        const _Dash(),
        _box(
          value: v.day,
          items: [for (var d = dFrom; d <= dTo; d++) d],
          label: two,
          isMarked: (d) => marked.contains(DateTime(v.year, v.month, d)),
          onChanged: (d) => _emit(v.year, v.month, d),
        ),
      ],
    );
  }

  Widget _box({
    required int value,
    required List<int> items,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
    bool Function(int)? isMarked,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x2, vertical: Sp.x1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Wf.border),
        borderRadius: BorderRadius.circular(Rd.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isDense: true,
          menuMaxHeight: 320,
          items: [
            for (final i in items)
              DropdownMenuItem<int>(
                value: i,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label(i), style: Tx.bold),
                    if (isMarked != null && isMarked(i))
                      Padding(
                        padding: EdgeInsets.only(left: Sp.x1),
                        child: Icon(Icons.circle, size: 6, color: Wf.info),
                      ),
                  ],
                ),
              ),
          ],
          onChanged: (i) {
            if (i != null) onChanged(i);
          },
        ),
      ),
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash();

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: Sp.x2),
        child: Text('-', style: Tx.bold),
      );
}
