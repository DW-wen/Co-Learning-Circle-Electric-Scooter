/// A single recorded violation (rules reference: Night Study Area).
class ViolationRecord {
  const ViolationRecord({
    required this.id,
    required this.at,
    required this.reason,
    required this.location,
    required this.points,
  });

  final String id;
  final DateTime at;
  final String reason;
  final String location;
  final int points;
}

/// The student's current standing.
class ViolationStanding {
  const ViolationStanding({
    required this.allowed,
    required this.points,
    this.restrictedUntil,
    required this.records,
  });

  /// Whether the student may currently use the service.
  final bool allowed;

  /// Currently accumulated (non-expired) points.
  final int points;

  /// When service access resumes. Only set when [allowed] is false.
  final DateTime? restrictedUntil;

  final List<ViolationRecord> records;

  /// ASSUMPTION: "active violation" = any accumulated points or a current
  /// restriction. The real rule (do points expire? after how long?) is TBD.
  bool get hasActiveViolations => points > 0 || !allowed;
}
