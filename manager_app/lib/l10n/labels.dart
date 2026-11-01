// Enum -> zh-TW label mapping (kept out of the models).

import '../models/models.dart';
import 'strings.dart';

String stationStatusLabel(StationStatus s) => switch (s) {
      StationStatus.notCharging => S.statusNotCharging,
      StationStatus.charging => S.statusCharging,
      StationStatus.occupied => S.statusOccupied,
      StationStatus.offline => S.statusOffline,
    };

String incidentTypeLabel(IncidentType t) => switch (t) {
      IncidentType.noPower => S.typeNoPower,
      IncidentType.occupiedByOther => S.typeOccupiedByOther,
      IncidentType.cableDamaged => S.typeCable,
      IncidentType.qrUnreadable => S.typeQr,
      IncidentType.unscannedOccupancy => S.typeUnscanned,
      IncidentType.unregisteredVehicle => S.typeUnregistered,
      IncidentType.deviceOffline => S.typeDeviceOffline,
      IncidentType.other => S.typeOther,
    };

String incidentStatusLabel(IncidentStatus s) => switch (s) {
      IncidentStatus.open => S.statusOpen,
      IncidentStatus.inProgress => S.statusInProgress,
      IncidentStatus.resolved => S.statusResolved,
    };

String incidentSourceLabel(IncidentSource s) => switch (s) {
      IncidentSource.student => S.sourceStudent,
      IncidentSource.system => S.sourceSystem,
      IncidentSource.patrol => S.sourcePatrol,
    };
