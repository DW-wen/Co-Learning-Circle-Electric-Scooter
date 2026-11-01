import '../models/models.dart';

enum AlertLevel { none, nearing, over }

/// Alert thresholds for charging spots. Adjustable from the dashboard.
///
/// - Charging: flag sessions nearing / exceeding ~4 h.
/// - Occupied (parked, not charging): limit is still "? min" in the spec,
///   so [occupiedLimit] defaults to a PLACEHOLDER 30 min.
class Thresholds {
  const Thresholds({
    this.chargingLimit = const Duration(hours: 4),
    this.chargingNearing = const Duration(minutes: 30),
    this.occupiedLimit = const Duration(minutes: 30),
    this.occupiedNearing = const Duration(minutes: 10),
  });

  final Duration chargingLimit;
  final Duration chargingNearing;
  final Duration occupiedLimit;
  final Duration occupiedNearing;

  Thresholds copyWith({Duration? chargingLimit, Duration? occupiedLimit}) =>
      Thresholds(
        chargingLimit: chargingLimit ?? this.chargingLimit,
        chargingNearing: chargingNearing,
        occupiedLimit: occupiedLimit ?? this.occupiedLimit,
        occupiedNearing: occupiedNearing,
      );

  Duration? limitFor(StationStatus s) => switch (s) {
        StationStatus.charging => chargingLimit,
        StationStatus.occupied => occupiedLimit,
        StationStatus.notCharging || StationStatus.offline => null,
      };

  Duration? _nearingFor(StationStatus s) => switch (s) {
        StationStatus.charging => chargingNearing,
        StationStatus.occupied => occupiedNearing,
        StationStatus.notCharging || StationStatus.offline => null,
      };

  AlertLevel evaluate(Station station, DateTime now) {
    final since = station.since;
    final limit = limitFor(station.status);
    final nearing = _nearingFor(station.status);
    if (since == null || limit == null || nearing == null) {
      return AlertLevel.none;
    }
    final elapsed = now.difference(since);
    if (elapsed >= limit) return AlertLevel.over;
    if (elapsed >= limit - nearing) return AlertLevel.nearing;
    return AlertLevel.none;
  }
}
