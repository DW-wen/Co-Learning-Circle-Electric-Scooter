/// State of a single charging spot (one parking space with a charger).
enum SpotStatus {
  /// Free - can be unlocked by scanning its QR code.
  available,

  /// A vehicle is parked and drawing current.
  charging,

  /// A vehicle is parked but not charging (e.g. finished, not yet moved).
  occupied,

  /// Out of service / under maintenance.
  offline,
}

class ChargingSpot {
  const ChargingSpot({
    required this.id,
    required this.label,
    required this.status,
  });

  /// Globally unique, printed on the spot's QR code, e.g. NSA-04.
  final String id;

  /// Short label shown on the spot, e.g. 04.
  final String label;
  final SpotStatus status;

  ChargingSpot withStatus(SpotStatus s) =>
      ChargingSpot(id: id, label: label, status: s);
}

/// A group of charging spots at one location.
class ChargingStation {
  const ChargingStation({
    required this.id,
    required this.name,
    required this.distanceM,
    required this.mapX,
    required this.mapY,
    required this.spots,
  });

  final String id;
  final String name;

  /// Walking distance from the student, metres.
  final int distanceM;

  /// Normalised position (0..1) on the placeholder map.
  final double mapX;
  final double mapY;

  final List<ChargingSpot> spots;

  int get availableCount =>
      spots.where((s) => s.status == SpotStatus.available).length;

  ChargingStation withSpots(List<ChargingSpot> next) => ChargingStation(
        id: id,
        name: name,
        distanceM: distanceM,
        mapX: mapX,
        mapY: mapY,
        spots: next,
      );
}
