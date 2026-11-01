import 'package:flutter/foundation.dart';

import '../models/charging.dart';
import '../models/rules.dart';
import '../models/station.dart';
import '../models/violation.dart';
import '../utils/format.dart';

enum UnlockResult { ok, alreadyInSession, restricted, notFound, unavailable }

/// Single source of truth shared by all three tabs:
/// - 充電 tab shows [current] / [lastSuccessful] and ends sessions,
/// - 違規 tab shows [standing],
/// - 充電站 tab lists [stations], unlocks spots and shows [history].
///
/// Backed by mock data now; swap the method bodies for API calls later.
class ChargingController extends ChangeNotifier {
  ChargingController({
    required List<ChargingStation> stations,
    required List<ChargingSession> history,
    required ViolationStanding standing,
    ChargingSession? current,
  })  : _stations = [...stations],
        _history = [...history],
        _standing = standing {
    _replaceCurrent(current);
  }

  List<ChargingStation> _stations;
  final List<ChargingSession> _history; // newest first
  ViolationStanding _standing;
  ChargingSession? _current;

  List<ChargingStation> get stations => List.unmodifiable(_stations);
  List<ChargingSession> get history => List.unmodifiable(_history);
  ChargingSession? get current => _current;
  ViolationStanding get standing => _standing;

  /// The most recent completed charge (the current one if it just finished).
  ChargingSession? get lastSuccessful {
    final c = _current;
    if (c != null && c.successful) return c;
    for (final s in _history) {
      if (s.successful) return s;
    }
    return null;
  }

  /// Oldest day that history can be queried for (inclusive).
  DateTime historyStart(DateTime now) =>
      monthsBefore(dateOnly(now), ServiceRules.historyMonths);

  /// History query (simulates the API): only sessions that started within
  /// the last [ServiceRules.historyMonths] months, optionally on one [day].
  /// Newest first.
  List<ChargingSession> historyQuery(DateTime now, {DateTime? day}) {
    final start = historyStart(now);
    return _history.where((s) {
      if (s.startedAt.isBefore(start)) return false;
      return day == null || sameDay(s.startedAt, day);
    }).toList();
  }

  static String normalizeId(String raw) => raw.trim().toUpperCase();

  ({ChargingStation station, ChargingSpot spot})? lookup(String spotId) {
    for (final st in _stations) {
      for (final sp in st.spots) {
        if (sp.id == spotId) return (station: st, spot: sp);
      }
    }
    return null;
  }

  /// Scan / enter a spot ID -> unlock it and start charging.
  UnlockResult unlock(String rawId) {
    final id = normalizeId(rawId);
    if (_current != null) return UnlockResult.alreadyInSession;
    if (!_standing.allowed) return UnlockResult.restricted;
    final hit = lookup(id);
    if (hit == null) return UnlockResult.notFound;
    if (hit.spot.status != SpotStatus.available) {
      return UnlockResult.unavailable;
    }
    _replaceCurrent(ChargingSession(
      spotId: id,
      stationName: hit.station.name,
      spotLabel: hit.spot.label,
      startedAt: DateTime.now(),
      estimatedTotal: const Duration(hours: 2, minutes: 30),
    ));
    notifyListeners();
    return UnlockResult.ok;
  }

  /// Stop charging (if still charging), unlock the spot and archive the
  /// session in [history].
  void endSession() {
    final c = _current;
    if (c == null) return;
    final now = DateTime.now();
    final done = c.copyWith(
      finishedAt: c.finishedAt ?? now,
      releasedAt: now,
      stoppedEarly: c.finishedAt == null,
    );
    _replaceCurrent(null);
    _history.insert(0, done);
    notifyListeners();
  }

  void setStanding(ViolationStanding s) {
    _standing = s;
    notifyListeners();
  }

  // ------------------------------------------------------------ dev preview

  /// Wireframe-only: force the current session into a given state.
  /// [state] null = no active session.
  void previewState(
    ChargeState? state, {
    required ChargingSession cannedCharging,
    required ChargingSession cannedFinished,
  }) {
    final c = _current;
    if (state == null) {
      _replaceCurrent(null);
    } else if (c == null) {
      _replaceCurrent(
          state == ChargeState.charging ? cannedCharging : cannedFinished);
    } else if (c.state != state) {
      _replaceCurrent(state == ChargeState.finished
          ? c.copyWith(finishedAt: DateTime.now())
          : c.copyWith(clearFinishedAt: true));
    }
    notifyListeners();
  }

  // --------------------------------------------------------------- internal

  void _replaceCurrent(ChargingSession? next) {
    final prev = _current;
    if (prev != null) _setSpot(prev.spotId, SpotStatus.available);
    _current = next;
    if (next != null) {
      _setSpot(
        next.spotId,
        next.state == ChargeState.charging
            ? SpotStatus.charging
            : SpotStatus.occupied,
      );
    }
  }

  void _setSpot(String id, SpotStatus status) {
    _stations = [
      for (final st in _stations)
        st.withSpots([
          for (final sp in st.spots) sp.id == id ? sp.withStatus(status) : sp,
        ]),
    ];
  }
}
