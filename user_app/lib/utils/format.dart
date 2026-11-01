// Date / duration formatting — Taiwan conventions (zh-TW), 24-hour clock.
// No intl dependency needed at this stage.

String two(int n) => n.toString().padLeft(2, '0');

/// 2026/11/01
String fmtDate(DateTime d) => '${d.year}/${two(d.month)}/${two(d.day)}';

/// 21:45
String fmtTime(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

/// 2026/11/01 21:45
String fmtDateTime(DateTime d) => '${fmtDate(d)} ${fmtTime(d)}';

/// 2026 年 11 月
String fmtMonth(DateTime d) => '${d.year} 年 ${d.month} 月';

/// 2 小時 05 分 (negative durations get a leading minus).
String fmtHm(Duration d) {
  final a = d.abs();
  final s = '${a.inHours} 小時 ${two(a.inMinutes.remainder(60))} 分';
  return d.isNegative ? '-$s' : s;
}

/// 01:23:45 (clamped at zero) - for live timers.
String fmtHms(Duration d) {
  final a = d.isNegative ? Duration.zero : d;
  return '${two(a.inHours)}:${two(a.inMinutes.remainder(60))}:'
      '${two(a.inSeconds.remainder(60))}';
}

/// Short duration: "12 分 05 秒" under an hour, "1 小時 05 分" otherwise.
String fmtShort(Duration d) {
  final a = d.abs();
  if (a.inHours == 0) {
    return '${a.inMinutes} 分 ${two(a.inSeconds.remainder(60))} 秒';
  }
  return fmtHm(a);
}

/// Monday 00:00 of the week containing [d] (Taiwan weeks start on Monday
/// in most campus calendars; change here if Sunday is preferred).
DateTime startOfWeek(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return DateTime(day.year, day.month, day.day - (day.weekday - 1));
}

// ------------------------------------------------------------ calendar math

/// Midnight of [d] (drops the time part).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Number of days in [month] of [year] (Gregorian, leap years included).
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Same day [months] calendar months earlier, clamped to the end of a
/// shorter month (e.g. 05-31 minus 3 months -> 02-28 / 02-29).
DateTime monthsBefore(DateTime d, int months) {
  final m = DateTime(d.year, d.month - months, 1);
  final dim = daysInMonth(m.year, m.month);
  return DateTime(m.year, m.month, d.day > dim ? dim : d.day);
}

DateTime clampDate(DateTime d, DateTime first, DateTime last) =>
    d.isBefore(first) ? first : (d.isAfter(last) ? last : d);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// 2026-11-01 (matches the 年 - 月 - 日 selector).
String fmtYmd(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';
