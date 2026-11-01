enum ChargeState { charging, finished }

/// One charging session of the signed-in student at a charging spot.
///
/// Lifecycle:  scan QR -> [startedAt] (spot unlocked, charging)
///             charge stops (full, or student ends early) -> [finishedAt]
///             student unlocks spot & leaves -> [releasedAt]
class ChargingSession {
  const ChargingSession({
    required this.spotId,
    required this.stationName,
    required this.spotLabel,
    required this.startedAt,
    this.finishedAt,
    this.releasedAt,
    this.estimatedTotal,
    this.stoppedEarly = false,
  });

  /// e.g. NSA-02
  final String spotId;

  /// e.g. 夜讀區充電站
  final String stationName;

  /// e.g. 02
  final String spotLabel;

  final DateTime startedAt;

  /// When power delivery stopped. Null while still charging.
  final DateTime? finishedAt;

  /// When the spot was unlocked and freed. Null while the session is active.
  final DateTime? releasedAt;

  /// Estimated full-charge duration. Source TBD (charger power x battery
  /// capacity, or historical average) - see README open questions.
  final Duration? estimatedTotal;

  /// True if the student ended the session before the charge completed.
  final bool stoppedEarly;

  ChargeState get state =>
      finishedAt == null ? ChargeState.charging : ChargeState.finished;

  /// Charging duration (start -> power stop).
  Duration? get duration => finishedAt?.difference(startedAt);

  /// Total time parked at the spot (start -> release).
  Duration? get parkedDuration => releasedAt?.difference(startedAt);

  /// Time the spot stayed occupied after charging stopped.
  Duration? get occupiedAfterFinish {
    final f = finishedAt;
    final r = releasedAt;
    return (f == null || r == null) ? null : r.difference(f);
  }

  /// A "successful charge" = charging completed (not ended early).
  bool get successful => finishedAt != null && !stoppedEarly;

  ChargingSession copyWith({
    DateTime? finishedAt,
    bool clearFinishedAt = false,
    DateTime? releasedAt,
    bool? stoppedEarly,
  }) =>
      ChargingSession(
        spotId: spotId,
        stationName: stationName,
        spotLabel: spotLabel,
        startedAt: startedAt,
        finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
        releasedAt: releasedAt ?? this.releasedAt,
        estimatedTotal: estimatedTotal,
        stoppedEarly: stoppedEarly ?? this.stoppedEarly,
      );
}
