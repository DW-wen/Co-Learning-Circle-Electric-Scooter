// Domain models for the Campus Security (駐警隊) dashboard.
// UI labels for the enums live in lib/l10n/labels.dart.

class Student {
  const Student({required this.id, required this.name});

  final String id;
  final String name;
}

// ------------------------------------------------------------------ stations

///   notCharging = spot free / nothing plugged in
///   charging    = vehicle plugged in and drawing current
///   occupied    = vehicle parked at the spot but NOT drawing current
///                 (finished and not moved, or parked without scanning)
///   offline     = out of service / under maintenance
enum StationStatus { notCharging, charging, occupied, offline }

/// One charging spot. [zone] is the station / area it belongs to.
class Station {
  const Station({
    required this.id,
    required this.zone,
    required this.label,
    required this.status,
    this.user,
    this.since,
  });

  /// e.g. NSA-03 (printed on the spot's QR code)
  final String id;

  /// e.g. 夜讀區充電站
  final String zone;

  /// e.g. 03
  final String label;
  final StationStatus status;

  /// Student whose session is on this spot. Null when free, offline, or when
  /// a vehicle is parked without a scanned session.
  final Student? user;

  /// When the current [status] began.
  final DateTime? since;

  /// Occupied but nobody scanned in -> parked without a session.
  bool get unscannedOccupancy => status == StationStatus.occupied && user == null;

  Station withStatus(StationStatus s, {Student? user, DateTime? since}) =>
      Station(
        id: id,
        zone: zone,
        label: label,
        status: s,
        user: user,
        since: since,
      );
}

class UsageLog {
  const UsageLog({
    required this.stationId,
    required this.zone,
    required this.student,
    required this.start,
    this.end,
  });

  final String stationId;
  final String zone;
  final Student student;
  final DateTime start;

  /// Null = session still in progress.
  final DateTime? end;
}

// ---------------------------------------------------------------- violations

class PointRecord {
  const PointRecord({
    required this.student,
    required this.at,
    required this.points,
    required this.reason,
    required this.location,
    required this.recordedBy,
  });

  final Student student;
  final DateTime at;
  final int points;
  final String reason;
  final String location;

  /// "系統" for automatic threshold detection, or an officer ID.
  final String recordedBy;
}

class Ban {
  const Ban({
    required this.student,
    required this.from,
    required this.until,
    required this.reason,
  });

  final Student student;
  final DateTime from;
  final DateTime until;
  final String reason;

  bool isActive(DateTime now) => now.isBefore(until) && !now.isBefore(from);
}

// ----------------------------------------------------------------- incidents

/// Where an incident came from.
enum IncidentSource { student, system, patrol }

enum IncidentType {
  noPower,
  occupiedByOther,
  cableDamaged,
  qrUnreadable,
  unscannedOccupancy,
  unregisteredVehicle,
  deviceOffline,
  other,
}

enum IncidentStatus { open, inProgress, resolved }

/// A problem at a charging spot: a student's 回報問題, a sensor/system
/// detection, or a patrol officer's report.
class Incident {
  const Incident({
    required this.id,
    required this.type,
    required this.source,
    required this.spotId,
    required this.reportedAt,
    this.status = IncidentStatus.open,
    this.reporter,
    this.involved,
    this.note,
    this.handledBy,
    this.resolvedAt,
    this.resolution,
  });

  final String id;
  final IncidentType type;
  final IncidentSource source;
  final String spotId;
  final DateTime reportedAt;
  final IncidentStatus status;

  /// Student who reported it (student reports only).
  final Student? reporter;

  /// Student involved, if known (e.g. the vehicle owner occupying the spot).
  final Student? involved;
  final String? note;
  final String? handledBy;
  final DateTime? resolvedAt;
  final String? resolution;

  Incident copyWith({
    IncidentStatus? status,
    String? handledBy,
    DateTime? resolvedAt,
    String? resolution,
  }) =>
      Incident(
        id: id,
        type: type,
        source: source,
        spotId: spotId,
        reportedAt: reportedAt,
        status: status ?? this.status,
        reporter: reporter,
        involved: involved,
        note: note,
        handledBy: handledBy ?? this.handledBy,
        resolvedAt: resolvedAt ?? this.resolvedAt,
        resolution: resolution ?? this.resolution,
      );
}
