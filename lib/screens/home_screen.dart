import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_report.dart';
import '../services/alerta_state.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherService>().fetchWeather();
    });
  }

  Future<void> _dialEmergency(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openSosModal(BuildContext context) {
    final locationService = context.read<LocationService>();
    locationService.getCurrentLocation();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Consumer<LocationService>(
        builder: (ctx, loc, _) {
          final lat = loc.currentPosition?.latitude.toStringAsFixed(5) ?? '14.63240';
          final lng = loc.currentPosition?.longitude.toStringAsFixed(5) ?? '121.09820';
          final smsText = 'SOS EMERGENCY! Need immediate rescue. GPS: $lat, $lng (${loc.currentAddress})';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sensors, color: Color(0xFFEF4444), size: 28),
                    SizedBox(width: 10),
                    Text('EMERGENCY SOS BEACON', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF87171))),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live GPS Coordinates:', style: TextStyle(fontSize: 11, color: Colors.white60)),
                      const SizedBox(height: 2),
                      Text('$lat, $lng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF34D399))),
                      Text(loc.currentAddress, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final report = EmergencyReport(
                        id: 'sos-${DateTime.now().millisecondsSinceEpoch}',
                        ticketNumber: 'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        category: IncidentType.rescueRequest,
                        priority: 'critical',
                        title: 'ONE-TAP SOS BEACON DISTRESS SIGNAL',
                        details: smsText,
                        totalAffected: 1,
                        infantCount: 0,
                        seniorCount: 0,
                        injuredCount: 1,
                        address: loc.currentAddress,
                        barangay: 'GPS SOS Pin',
                        latitude: double.tryParse(lat) ?? 14.6324,
                        longitude: double.tryParse(lng) ?? 121.0982,
                        reporterName: 'Citizen SOS App',
                        reporterPhone: 'Device GPS',
                        status: 'pending',
                        createdAt: DateTime.now(),
                      );
                      context.read<AlertaState>().addReport(report);
                      context.read<FirebaseService>().submitReport(report);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('SOS Broadcasted (${report.ticketNumber}) to Command ICS!'), backgroundColor: Colors.red),
                      );
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('DISPATCH CRITICAL SOS TO COMMAND'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: smsText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('GPS SOS message copied to clipboard!')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy GPS SMS'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                        onPressed: () => _dialEmergency('911'),
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call 911'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherService>();
    final state = context.watch<AlertaState>();
    final reading = weather.current;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('ALERTA MDRRMO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              state.drillModeActive ? Icons.notifications_active : Icons.notifications_none,
              color: state.drillModeActive ? Colors.amber : Colors.white70,
            ),
            tooltip: 'Toggle LGU Drill Simulator',
            onPressed: () => state.toggleDrillMode(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: () => _openSosModal(context),
              icon: const Icon(Icons.sos, size: 18),
              label: const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.drillModeActive)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF7F1D1D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEF4444), width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'DRILL SIMULATOR ACTIVE: Practice Signal #3 Flood & Volcano Evacuation Protocol.',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Live PAGASA 8-Station Synoptic Weather Monitor
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(8)),
                        child: const Text('PAGASA: TCWS NONE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      Row(
                        children: [
                          Text(reading.isLiveApi ? 'LIVE API' : 'BASELINE', style: const TextStyle(fontSize: 10, color: Color(0xFF6EE7B7), fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: weather.isLoading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.refresh, size: 18, color: Colors.white),
                            onPressed: () => weather.fetchWeather(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: weather.selectedStationId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F172A),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                      labelText: 'PAGASA Synoptic Station',
                    ),
                    items: WeatherService.stations
                        .map((s) => DropdownMenuItem(value: s.id, child: Text('${s.region} · ${s.name}', style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) weather.fetchWeather(val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${reading.temperatureC}°C · ${reading.description}',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          Text('Feels ${reading.feelsLikeC}°C · ${reading.updatedAt}',
                              style: const TextStyle(fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Wind: ${reading.windSpeedKmh} km/h', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          Text('RH: ${reading.humidity}% · Rain: ${reading.precipitationMm} mm',
                              style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PAR Status: Clear (No active tropical cyclone). Easterlies & localized thunderstorms prevailing.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFA7F3D0)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Official DOST-PHIVOLCS Mayon Volcano Alert Level 3 Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7C2D12).withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF97316), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFEA580C), borderRadius: BorderRadius.circular(8)),
                        child: const Text('MAYON: ALERT LEVEL 3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('DOST-PHIVOLCS (Albay)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Intensified magmatic unrest: New summit lava dome, minor Strombolian bursts, rockfalls, and elevated SO2 (~2,170 t/day). 6-km Permanent Danger Zone strictly NO ENTRY.',
                    style: TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                  const Divider(height: 20, color: Colors.white12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('6-km PDZ: EVACUATE / NO ENTRY', style: TextStyle(color: Color(0xFFFDBA74), fontWeight: FontWeight.bold, fontSize: 11)),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFEA580C),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        onPressed: () => _dialEmergency('0524820031'),
                        icon: const Icon(Icons.volcano, size: 15),
                        label: const Text('Call PHIVOLCS', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Quick Disaster Action Grid
            const Text('Emergency Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  title: 'Report Incident',
                  subtitle: 'Flood, Lahar, Rescue',
                  icon: Icons.campaign,
                  color: Colors.blueAccent,
                  onTap: () => widget.onNavigateTab?.call(1),
                ),
                _buildActionCard(
                  title: 'Evacuation Hubs',
                  subtitle: '5 Shelters & Routes',
                  icon: Icons.night_shelter,
                  color: const Color(0xFF10B981),
                  onTap: () => widget.onNavigateTab?.call(2),
                ),
                _buildActionCard(
                  title: '72-Hr Go-Bag',
                  subtitle: '${state.completedGoBagCount}/${state.goBagItems.length} Packed · ICS',
                  icon: Icons.backpack,
                  color: Colors.amber,
                  onTap: () => widget.onNavigateTab?.call(4),
                ),
                _buildActionCard(
                  title: 'SOS GPS Beacon',
                  subtitle: 'One-Tap 911 & ICS',
                  icon: Icons.sensors,
                  color: Colors.redAccent,
                  onTap: () => _openSosModal(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text('Active Advisories & Broadcasts', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...state.bulletins.map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: b.isCritical ? const Color(0xFFEF4444).withOpacity(0.6) : Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${b.source} · ${b.category} · ${b.issuedAt}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: b.isCritical ? const Color(0xFFF87171) : const Color(0xFF6EE7B7))),
                      const SizedBox(height: 4),
                      Text(b.headline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(b.action, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}
