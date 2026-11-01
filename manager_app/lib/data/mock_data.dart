// Mock data for layout review. Times are relative to app start so alerts
// and countdowns look realistic. Station / spot IDs match user_app.
// Replace with API calls later.

import 'dart:math';

import '../models/models.dart';

class ManagerMock {
  ManagerMock._();

  static final DateTime _t0 = DateTime.now();

  static DateTime _ago({int days = 0, int hours = 0, int minutes = 0}) =>
      _t0.subtract(Duration(days: days, hours: hours, minutes: minutes));

  // Fictional students.
  static const List<Student> students = [
    Student(id: 'S11203045', name: '陳怡婷'),
    Student(id: 'S11201178', name: '林柏翰'),
    Student(id: 'S11104452', name: '王思涵'),
    Student(id: 'S11302219', name: '黃敏'),
    Student(id: 'S11205530', name: '李俊傑'),
    Student(id: 'S11108803', name: '蔡承恩'),
    Student(id: 'S11301964', name: '吳冠宇'),
    Student(id: 'S11206671', name: '劉安琪'),
    Student(id: 'S11103397', name: '高睿'),
    Student(id: 'S11304120', name: '許庭瑋'),
  ];

  static const String nsa = '夜讀區充電站';
  static const String lib = '圖書館充電站';
  static const String dorm = 'B 棟宿舍充電站';
  static const String eng = '工程館充電站';

  // ---------------------------------------------------------------- stations

  static List<Station> stations() {
    Station st(
      String id,
      String zone,
      StationStatus status, {
      int? studentIdx,
      int? minutesAgo,
    }) =>
        Station(
          id: id,
          zone: zone,
          label: id.split('-').last,
          status: status,
          user: studentIdx == null ? null : students[studentIdx],
          since: minutesAgo == null ? null : _ago(minutes: minutesAgo),
        );

    const c = StationStatus.charging;
    const o = StationStatus.occupied;
    const f = StationStatus.notCharging;
    const x = StationStatus.offline;
    return [
      st('NSA-01', nsa, c, studentIdx: 0, minutesAgo: 262), // over 4 h
      st('NSA-02', nsa, c, studentIdx: 1, minutesAgo: 218), // nearing
      st('NSA-03', nsa, o, studentIdx: 2, minutesAgo: 48), // occupied, over
      st('NSA-04', nsa, f),
      st('NSA-05', nsa, o, studentIdx: 3, minutesAgo: 23), // nearing
      st('NSA-06', nsa, c, studentIdx: 9, minutesAgo: 41),
      st('LIB-01', lib, c, studentIdx: 7, minutesAgo: 30),
      st('LIB-02', lib, o, minutesAgo: 40), // parked without scanning
      st('LIB-03', lib, x, minutesAgo: 60 * 26),
      st('DB-01', dorm, c, studentIdx: 4, minutesAgo: 95),
      st('DB-02', dorm, o, studentIdx: 5, minutesAgo: 8),
      st('DB-03', dorm, f),
      st('DB-04', dorm, c, studentIdx: 6, minutesAgo: 236), // nearing
      st('ENG-01', eng, c, studentIdx: 8, minutesAgo: 120),
      st('ENG-02', eng, f),
      st('ENG-03', eng, f),
      st('ENG-04', eng, x, minutesAgo: 60 * 30),
    ];
  }

  // -------------------------------------------------------------- usage logs

  static List<UsageLog> usageLogs() {
    final rnd = Random(42);
    final all = stations();
    final logs = <UsageLog>[];
    // ~4 months of history, so the 3-month query limit visibly cuts off
    // the oldest records.
    for (var i = 0; i < 180; i++) {
      final s = all[rnd.nextInt(all.length)];
      final start = _ago(hours: 5 + rnd.nextInt(24 * 120));
      logs.add(UsageLog(
        stationId: s.id,
        zone: s.zone,
        student: students[rnd.nextInt(students.length)],
        start: start,
        end: start.add(Duration(minutes: 35 + rnd.nextInt(250))),
      ));
    }
    // Sessions currently in progress.
    for (final s in all) {
      final user = s.user;
      final since = s.since;
      if (user != null && since != null) {
        logs.add(UsageLog(
          stationId: s.id,
          zone: s.zone,
          student: user,
          start: since,
        ));
      }
    }
    return logs;
  }

  // -------------------------------------------------------------- violations

  static const List<String> _reasons = [
    '充電超過 4 小時上限',
    '充電完成後未移車',
    '未掃碼即佔用充電位',
    '未登記車輛佔用充電位',
  ];

  static List<PointRecord> pointRecords() {
    final rnd = Random(7);
    final all = stations();
    final records = <PointRecord>[];
    for (var i = 0; i < 36; i++) {
      final station = all[rnd.nextInt(all.length)];
      records.add(PointRecord(
        student: students[rnd.nextInt(students.length)],
        at: _ago(hours: 3 + rnd.nextInt(24 * 90)),
        points: 1 + rnd.nextInt(3),
        reason: _reasons[rnd.nextInt(_reasons.length)],
        location: '${station.zone} · ${station.label} 號充電位',
        recordedBy: rnd.nextBool() ? '系統' : '值班員 #${100 + i % 5}',
      ));
    }
    records.sort((a, b) => b.at.compareTo(a.at));
    return records;
  }

  static List<Ban> bans() => [
        Ban(
          student: students[2],
          from: _ago(days: 3, hours: 4),
          until: _t0.add(const Duration(days: 4, hours: 2)),
          reason: '累計點數達停權門檻',
        ),
        Ban(
          student: students[5],
          from: _ago(days: 12),
          until: _t0.add(const Duration(days: 2, hours: 9)),
          reason: '夜讀區重複超時佔用',
        ),
        Ban(
          student: students[9],
          from: _ago(hours: 20),
          until: _t0.add(const Duration(days: 13, hours: 4)),
          reason: '累計點數達停權門檻',
        ),
        // Expired - must NOT appear in "currently suspended".
        Ban(
          student: students[1],
          from: _ago(days: 30),
          until: _ago(days: 16),
          reason: '累計點數達停權門檻',
        ),
      ];

  // --------------------------------------------------------------- incidents

  static List<Incident> incidents() => [
        Incident(
          id: 'INC-2041',
          type: IncidentType.occupiedByOther,
          source: IncidentSource.student,
          spotId: 'NSA-05',
          reportedAt: _ago(minutes: 12),
          reporter: students[0],
          involved: students[3],
          note: '充電已完成但車一直停著，沒有空位可以充。',
        ),
        Incident(
          id: 'INC-2040',
          type: IncidentType.unscannedOccupancy,
          source: IncidentSource.system,
          spotId: 'LIB-02',
          reportedAt: _ago(minutes: 38),
          note: '感測器偵測到車輛停放，但無掃碼充電紀錄。',
        ),
        Incident(
          id: 'INC-2038',
          type: IncidentType.qrUnreadable,
          source: IncidentSource.student,
          spotId: 'DB-03',
          reportedAt: _ago(hours: 2),
          reporter: students[7],
          note: 'QR Code 貼紙破損，掃不到。',
        ),
        Incident(
          id: 'INC-2037',
          type: IncidentType.unregisteredVehicle,
          source: IncidentSource.patrol,
          spotId: 'DB-02',
          reportedAt: _ago(hours: 5),
          status: IncidentStatus.inProgress,
          involved: students[5],
          handledBy: '值班員 #102',
          note: '巡邏時發現車牌未登記。',
        ),
        Incident(
          id: 'INC-2036',
          type: IncidentType.deviceOffline,
          source: IncidentSource.system,
          spotId: 'LIB-03',
          reportedAt: _ago(hours: 26),
          status: IncidentStatus.inProgress,
          handledBy: '值班員 #103',
          note: '充電位設備連線中斷。',
        ),
        Incident(
          id: 'INC-2035',
          type: IncidentType.noPower,
          source: IncidentSource.student,
          spotId: 'ENG-04',
          reportedAt: _ago(hours: 30),
          status: IncidentStatus.inProgress,
          reporter: students[8],
          handledBy: '值班員 #102',
          note: '插上充電線後沒有供電。',
        ),
        Incident(
          id: 'INC-2030',
          type: IncidentType.cableDamaged,
          source: IncidentSource.student,
          spotId: 'NSA-03',
          reportedAt: _ago(days: 3, hours: 2),
          status: IncidentStatus.resolved,
          reporter: students[4],
          handledBy: '值班員 #101',
          resolvedAt: _ago(days: 2, hours: 20),
          resolution: '已更換充電線。',
        ),
        Incident(
          id: 'INC-2025',
          type: IncidentType.occupiedByOther,
          source: IncidentSource.student,
          spotId: 'NSA-01',
          reportedAt: _ago(days: 6),
          status: IncidentStatus.resolved,
          reporter: students[6],
          involved: students[1],
          handledBy: '值班員 #104',
          resolvedAt: _ago(days: 5, hours: 22),
          resolution: '已聯繫車主移車並記 1 點。',
        ),
      ];
}
