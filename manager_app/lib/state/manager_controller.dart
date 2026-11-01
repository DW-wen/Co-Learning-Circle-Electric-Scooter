import 'package:flutter/foundation.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../utils/format.dart';

/// Single source of truth for the dashboard pages, so an action on one page
/// (e.g. 記點 from a station tile or an incident) shows up on the others
/// (記點查詢, 停權名單, 充電站總覽).
///
/// Backed by mock data now; swap the method bodies for API calls later.
class ManagerController extends ChangeNotifier {
  ManagerController({
    required List<Student> students,
    required List<Station> stations,
    required List<UsageLog> logs,
    required List<PointRecord> pointRecords,
    required List<Ban> bans,
    required List<Incident> incidents,
  })  : _students = [...students],
        _stations = [...stations],
        _logs = [...logs],
        _points = [...pointRecords],
        _bans = [...bans],
        _incidents = [...incidents];

  final List<Student> _students;
  final List<Station> _stations;
  final List<UsageLog> _logs;
  final List<PointRecord> _points;
  final List<Ban> _bans;
  final List<Incident> _incidents;

  List<Student> get students => List.unmodifiable(_students);
  List<Station> get stations => List.unmodifiable(_stations);
  List<UsageLog> get logs => List.unmodifiable(_logs);
  List<PointRecord> get pointRecords => List.unmodifiable(_points);
  List<Ban> get bans => List.unmodifiable(_bans);
  List<Incident> get incidents => List.unmodifiable(_incidents);

  /// How far back usage history can be queried (calendar months).
  static const int historyMonths = 3;

  /// Oldest day that usage history can be queried for (inclusive).
  DateTime historyStart(DateTime now) =>
      monthsBefore(dateOnly(now), historyMonths);

  /// Usage-log query (simulates the API): only sessions that started within
  /// the last [historyMonths] months, optionally on one [day].
  List<UsageLog> logsQuery(DateTime now, {DateTime? day}) {
    final start = historyStart(now);
    return _logs.where((l) {
      if (l.start.isBefore(start)) return false;
      return day == null || sameDay(l.start, day);
    }).toList();
  }

  List<String> get zones {
    final out = <String>[];
    for (final s in _stations) {
      if (!out.contains(s.zone)) out.add(s.zone);
    }
    return out;
  }

  Station? stationById(String id) {
    for (final s in _stations) {
      if (s.id == id) return s;
    }
    return null;
  }

  int pointsOf(String studentId) => _points
      .where((r) => r.student.id == studentId)
      .fold<int>(0, (sum, r) => sum + r.points);

  Ban? activeBan(String studentId, DateTime now) {
    for (final b in _bans) {
      if (b.student.id == studentId && b.isActive(now)) return b;
    }
    return null;
  }

  int get openIncidentCount =>
      _incidents.where((i) => i.status == IncidentStatus.open).length;

  // ----------------------------------------------------------------- spots

  /// Maintenance toggle. Only free spots can go offline; offline spots come
  /// back as free.
  bool setSpotOffline(String spotId, bool offline) {
    final i = _stations.indexWhere((s) => s.id == spotId);
    if (i < 0) return false;
    final s = _stations[i];
    final allowed = offline
        ? s.status == StationStatus.notCharging
        : s.status == StationStatus.offline;
    if (!allowed) return false;
    _stations[i] = s.withStatus(
      offline ? StationStatus.offline : StationStatus.notCharging,
      since: offline ? DateTime.now() : null,
    );
    notifyListeners();
    return true;
  }

  // ------------------------------------------------------------ violations

  void recordPoints({
    required Student student,
    required int points,
    required String reason,
    required String location,
  }) {
    _points.insert(
      0,
      PointRecord(
        student: student,
        at: DateTime.now(),
        points: points,
        reason: reason,
        location: location,
        recordedBy: S.currentOfficer,
      ),
    );
    notifyListeners();
  }

  void issueBan({
    required Student student,
    required int days,
    required String reason,
  }) {
    final now = DateTime.now();
    _bans.insert(
      0,
      Ban(
        student: student,
        from: now,
        until: now.add(Duration(days: days)),
        reason: reason,
      ),
    );
    notifyListeners();
  }

  /// Ends a ban now (kept in the list for audit, but no longer active).
  void liftBan(Ban ban) {
    final i = _bans.indexOf(ban);
    if (i < 0) return;
    _bans[i] = Ban(
      student: ban.student,
      from: ban.from,
      until: DateTime.now(),
      reason: ban.reason,
    );
    notifyListeners();
  }

  // ------------------------------------------------------------- incidents

  void startIncident(String id) => _updateIncident(
        id,
        (i) => i.copyWith(
          status: IncidentStatus.inProgress,
          handledBy: S.currentOfficer,
        ),
      );

  void resolveIncident(String id, String resolution) => _updateIncident(
        id,
        (i) => i.copyWith(
          status: IncidentStatus.resolved,
          handledBy: i.handledBy ?? S.currentOfficer,
          resolvedAt: DateTime.now(),
          resolution: resolution,
        ),
      );

  void _updateIncident(String id, Incident Function(Incident) change) {
    final i = _incidents.indexWhere((x) => x.id == id);
    if (i < 0) return;
    _incidents[i] = change(_incidents[i]);
    notifyListeners();
  }
}
