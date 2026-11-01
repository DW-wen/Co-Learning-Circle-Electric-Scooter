// Mock data for layout review. All times are relative to app start so the
// live timers always show plausible values. Replace with API calls later.

import '../models/charging.dart';
import '../models/station.dart';
import '../models/violation.dart';

class MockData {
  MockData._();

  static final DateTime _t0 = DateTime.now();

  static const String studentId = 'S11203045';
  static const String studentName = '學生 A';

  static const String _nsa = '夜讀區充電站';
  static const String _lib = '圖書館充電站';
  static const String _dorm = 'B 棟宿舍充電站';
  static const String _eng = '工程館充電站';

  // ---------------------------------------------------------------- stations

  /// Status of every spot EXCEPT the student's own session, which the
  /// controller marks charging / occupied itself.
  static List<ChargingStation> stations() {
    List<ChargingSpot> spots(String prefix, List<SpotStatus> statuses) => [
          for (var i = 0; i < statuses.length; i++)
            ChargingSpot(
              id: '$prefix-${(i + 1).toString().padLeft(2, '0')}',
              label: (i + 1).toString().padLeft(2, '0'),
              status: statuses[i],
            ),
        ];

    const a = SpotStatus.available;
    const c = SpotStatus.charging;
    const o = SpotStatus.occupied;
    const x = SpotStatus.offline;

    return [
      ChargingStation(
        id: 'NSA',
        name: _nsa,
        distanceM: 80,
        mapX: 0.55,
        mapY: 0.30,
        spots: spots('NSA', const [c, a, o, a, o, c]),
      ),
      ChargingStation(
        id: 'LIB',
        name: _lib,
        distanceM: 260,
        mapX: 0.28,
        mapY: 0.40,
        spots: spots('LIB', const [c, a, x]),
      ),
      ChargingStation(
        id: 'DB',
        name: _dorm,
        distanceM: 450,
        mapX: 0.18,
        mapY: 0.75,
        spots: spots('DB', const [c, o, a, c]),
      ),
      ChargingStation(
        id: 'ENG',
        name: _eng,
        distanceM: 620,
        mapX: 0.78,
        mapY: 0.62,
        spots: spots('ENG', const [c, c, o, x]),
      ),
    ];
  }

  // ---------------------------------------------------------------- charging

  /// State A - currently charging (initial state of the app).
  static ChargingSession chargingNow() => ChargingSession(
        spotId: 'NSA-02',
        stationName: _nsa,
        spotLabel: '02',
        startedAt: _t0.subtract(const Duration(hours: 1, minutes: 12)),
        estimatedTotal: const Duration(hours: 2, minutes: 30),
      );

  /// State B - finished charging a while ago (vehicle still parked).
  static ChargingSession finishedRecently() => ChargingSession(
        spotId: 'NSA-02',
        stationName: _nsa,
        spotLabel: '02',
        startedAt: _t0.subtract(const Duration(hours: 3, minutes: 5)),
        finishedAt: _t0.subtract(const Duration(minutes: 25)),
        estimatedTotal: const Duration(hours: 2, minutes: 30),
      );

  /// Past sessions, newest first: a few hand-written recent ones plus a
  /// generated tail reaching ~4 months back, so the 3-month history limit
  /// visibly cuts off the oldest records.
  static List<ChargingSession> sessionHistory() => [
        ..._recentHistory(),
        ..._olderHistory(),
      ];

  static List<ChargingSession> _olderHistory() =>
      [for (var i = 0; i < 32; i++) _olderSession(i)];

  static const List<(String, String, String)> _olderSpots = [
    ('NSA-03', _nsa, '03'),
    ('LIB-02', _lib, '02'),
    ('DB-01', _dorm, '01'),
    ('NSA-06', _nsa, '06'),
    ('ENG-02', _eng, '02'),
  ];

  static ChargingSession _olderSession(int i) {
    final spot = _olderSpots[i % _olderSpots.length];
    final start = _t0.subtract(Duration(
      days: 15 + (i * 7) ~/ 2, // every ~3.5 days, up to ~123 days ago
      hours: 2 + (i * 5) % 9,
    ));
    final finished = start.add(Duration(minutes: 90 + (i * 37) % 100));
    return ChargingSession(
      spotId: spot.$1,
      stationName: spot.$2,
      spotLabel: spot.$3,
      startedAt: start,
      finishedAt: finished,
      // every 6th session overstays the move-out limit
      releasedAt:
          finished.add(Duration(minutes: i % 6 == 0 ? 52 : 6 + i % 15)),
    );
  }

  static List<ChargingSession> _recentHistory() => [
        ChargingSession(
          spotId: 'LIB-01',
          stationName: _lib,
          spotLabel: '01',
          startedAt:
              _t0.subtract(const Duration(days: 2, hours: 3, minutes: 5)),
          finishedAt: _t0.subtract(const Duration(days: 2, minutes: 50)),
          releasedAt: _t0.subtract(const Duration(days: 2, minutes: 41)),
        ),
        ChargingSession(
          spotId: 'NSA-04',
          stationName: _nsa,
          spotLabel: '04',
          startedAt: _t0.subtract(const Duration(days: 5, hours: 4)),
          finishedAt:
              _t0.subtract(const Duration(days: 5, hours: 1, minutes: 20)),
          releasedAt: _t0.subtract(const Duration(days: 5, minutes: 35)),
        ),
        ChargingSession(
          spotId: 'DB-03',
          stationName: _dorm,
          spotLabel: '03',
          startedAt: _t0.subtract(const Duration(days: 9, hours: 2)),
          finishedAt:
              _t0.subtract(const Duration(days: 9, minutes: 50)),
          releasedAt: _t0.subtract(const Duration(days: 9, minutes: 50)),
          stoppedEarly: true,
        ),
        ChargingSession(
          spotId: 'NSA-01',
          stationName: _nsa,
          spotLabel: '01',
          startedAt: _t0.subtract(const Duration(days: 12, hours: 5)),
          finishedAt: _t0.subtract(const Duration(days: 12, hours: 2)),
          releasedAt:
              _t0.subtract(const Duration(days: 12, hours: 1, minutes: 48)),
        ),
      ];

  // -------------------------------------------------------------- violations

  static List<ViolationRecord> violations() => [
        ViolationRecord(
          id: 'V-108',
          at: _t0.subtract(const Duration(days: 1, hours: 2)),
          reason: '充電完成後未移車',
          location: '$_nsa · 02 號充電位',
          points: 1,
        ),
        ViolationRecord(
          id: 'V-107',
          at: _t0.subtract(const Duration(days: 1, hours: 5)),
          reason: '充電超過 4 小時上限',
          location: '$_nsa · 04 號充電位',
          points: 2,
        ),
        ViolationRecord(
          id: 'V-101',
          at: _t0.subtract(const Duration(days: 5, hours: 1)),
          reason: '未掃碼即佔用充電位',
          location: '$_eng · 03 號充電位',
          points: 1,
        ),
        ViolationRecord(
          id: 'V-094',
          at: _t0.subtract(const Duration(days: 12)),
          reason: '充電超過 4 小時上限',
          location: '$_dorm · 01 號充電位',
          points: 2,
        ),
        ViolationRecord(
          id: 'V-090',
          at: _t0.subtract(const Duration(days: 13, hours: 3)),
          reason: '未登記車輛佔用充電位',
          location: '$_dorm · 03 號充電位',
          points: 3,
        ),
        ViolationRecord(
          id: 'V-071',
          at: _t0.subtract(const Duration(days: 34)),
          reason: '充電完成後未移車',
          location: '$_lib · 02 號充電位',
          points: 1,
        ),
        ViolationRecord(
          id: 'V-066',
          at: _t0.subtract(const Duration(days: 41, hours: 6)),
          reason: '充電超過 4 小時上限',
          location: '$_nsa · 01 號充電位',
          points: 2,
        ),
      ];

  static ViolationStanding standingAllowed() => ViolationStanding(
        allowed: true,
        points: 3,
        records: violations(),
      );

  static ViolationStanding standingRestricted() => ViolationStanding(
        allowed: false,
        points: 12,
        restrictedUntil: DateTime(_t0.year, _t0.month, _t0.day + 6, 8),
        records: violations(),
      );

  static ViolationStanding standingClean() => const ViolationStanding(
        allowed: true,
        points: 0,
        records: [],
      );
}
