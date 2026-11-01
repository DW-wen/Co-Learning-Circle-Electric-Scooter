import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/rules.dart';
import '../../models/station.dart';
import '../../wireframe/wire.dart';

/// Map placeholder + nearby stations with per-spot availability.
class NearbyStationsTab extends StatelessWidget {
  const NearbyStationsTab({
    super.key,
    required this.stations,
    required this.onScan,
  });

  final List<ChargingStation> stations;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final sorted = [...stations]
      ..sort((a, b) => a.distanceM.compareTo(b.distanceM));

    return ListView(
      padding: const EdgeInsets.all(Sp.x4),
      children: [
        WirePlaceholder(
          label: S.mapPlaceholder,
          icon: Icons.map_outlined,
          height: 180,
          child: MapPins(
            pins: [
              for (final st in sorted)
                MapPin(
                  x: st.mapX,
                  y: st.mapY,
                  label: '${st.name} · '
                      '${S.freeSpots(st.availableCount, st.spots.length)}',
                  color: st.availableCount > 0 ? Wf.ok : Wf.bad,
                ),
            ],
          ),
        ),
        const SizedBox(height: Sp.x4),
        Row(
          children: [
            Expanded(
                child: Text(S.stationsNearby(sorted.length), style: Tx.label)),
            Text(S.rate(ServiceRules.ntdPerHour), style: Tx.small),
          ],
        ),
        const SizedBox(height: Sp.x2),
        const _Legend(),
        const SizedBox(height: Sp.x3),
        for (final st in sorted)
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.x3),
            child: _StationCard(station: st, onScan: onScan),
          ),
      ],
    );
  }
}

Color spotColor(SpotStatus s) => switch (s) {
      SpotStatus.available => Wf.ok,
      SpotStatus.charging => Wf.info,
      SpotStatus.occupied => Wf.warn,
      SpotStatus.offline => Wf.muted,
    };

String spotStatusLabel(SpotStatus s) => switch (s) {
      SpotStatus.available => S.spotAvailable,
      SpotStatus.charging => S.spotCharging,
      SpotStatus.occupied => S.spotOccupied,
      SpotStatus.offline => S.spotOffline,
    };

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Sp.x3,
      runSpacing: Sp.x1,
      children: [
        for (final s in SpotStatus.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: spotColor(s),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: Sp.x1),
              Text(spotStatusLabel(s), style: Tx.small),
            ],
          ),
      ],
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard({required this.station, required this.onScan});

  final ChargingStation station;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final free = station.availableCount;
    return WireCard(
      padding: const EdgeInsets.all(Sp.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.ev_station, color: Wf.muted),
              const SizedBox(width: Sp.x2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(station.name, style: Tx.bold),
                    Text(S.meters(station.distanceM), style: Tx.small),
                  ],
                ),
              ),
              StatusBadge(
                free > 0
                    ? S.freeSpots(free, station.spots.length)
                    : S.full,
                color: free > 0 ? Wf.ok : Wf.bad,
              ),
            ],
          ),
          const SizedBox(height: Sp.x3),
          Wrap(
            spacing: Sp.x2,
            runSpacing: Sp.x2,
            children: [for (final sp in station.spots) _SpotChip(spot: sp)],
          ),
          const SizedBox(height: Sp.x3),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: free > 0 ? onScan : null,
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text(S.scanHere),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotChip extends StatelessWidget {
  const _SpotChip({required this.spot});

  final ChargingSpot spot;

  @override
  Widget build(BuildContext context) {
    final color = spotColor(spot.status);
    return Tooltip(
      message: '${spot.id} · ${spotStatusLabel(spot.status)}',
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: Sp.x1),
        decoration: BoxDecoration(
          color: Wf.tint(color),
          border: Border.all(color: color.withAlpha(140)),
          borderRadius: BorderRadius.circular(Rd.md),
        ),
        child: Column(
          children: [
            Text(spot.label,
                style: TextStyle(fontWeight: FontWeight.w700, color: color)),
            Text(spotStatusLabel(spot.status),
                style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}
