/// Service rules shown to students. Values marked PLACEHOLDER are not
/// defined in the spec yet and must be confirmed (see README).
class ServiceRules {
  ServiceRules._();

  /// Max single charging session (~4 h per spec).
  static const Duration chargingLimit = Duration(hours: 4);

  /// PLACEHOLDER ("? min" in spec): how long a vehicle may stay at the spot
  /// after charging has finished.
  static const Duration occupiedLimit = Duration(minutes: 30);

  /// Default "move your vehicle" reminder after charging finishes.
  static const Duration moveReminderAfter = Duration(minutes: 10);

  /// How far back history can be queried (calendar months).
  static const int historyMonths = 3;

  /// PLACEHOLDER tariff (could also be free, or credit-based).
  static const int ntdPerHour = 5;

  static int feeFor(Duration charged) =>
      (charged.inMinutes / 60 * ntdPerHour).ceil();
}
