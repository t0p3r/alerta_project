import 'package:flutter/material.dart';
import '../models/emergency_report.dart';
import '../models/evacuation_center.dart';

class WeatherBulletin {
  final String id;
  final String source;
  final String category;
  final String headline;
  final String description;
  final String action;
  final String issuedAt;
  final bool isCritical;

  const WeatherBulletin({
    required this.id,
    required this.source,
    required this.category,
    required this.headline,
    required this.description,
    required this.action,
    required this.issuedAt,
    this.isCritical = false,
  });
}

class GoBagItem {
  final String id;
  final String category;
  final String name;
  final String description;
  final bool essential;
  bool completed;

  GoBagItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.essential,
    required this.completed,
  });
}

class AlertaState extends ChangeNotifier {
  bool drillModeActive = false;

  final List<WeatherBulletin> bulletins = [
    const WeatherBulletin(
      id: 'pagasa-clear',
      source: 'PAGASA',
      category: 'PAR Status',
      headline: 'NO ACTIVE TROPICAL CYCLONE in PAR (TCWS: NONE)',
      description:
          'There is currently NO active tropical cyclone inside the Philippine Area of Responsibility. Easterlies and localized thunderstorms prevail.',
      action: 'Normal monitoring. Watch for localized afternoon thunderstorm rainshowers.',
      issuedAt: 'Official PAGASA Bulletin',
      isCritical: false,
    ),
    const WeatherBulletin(
      id: 'phivolcs-mayon-3',
      source: 'PHIVOLCS',
      category: 'Volcano Alert Level 3',
      headline: 'MAYON VOLCANO: ALERT LEVEL 3 (Magmatic Unrest)',
      description:
          'New summit lava dome, minor Strombolian bursts, incandescent rockfalls, and ~2,170 tonnes/day SO2 flux observed over Albay.',
      action: 'Strictly NO ENTRY inside the 6-km Permanent Danger Zone (PDZ). Watch gullies for lahars.',
      issuedAt: 'DOST-PHIVOLCS Bulletin',
      isCritical: true,
    ),
    const WeatherBulletin(
      id: 'mdrrmo-river',
      source: 'MDRRMO',
      category: 'Flood Watch',
      headline: 'Municipal River Basin: Normal Level (12.4m / 15m Alert)',
      description: 'All pumping stations & flood gates in standby normal mode across all 16 barangays.',
      action: 'Routine monitoring active.',
      issuedAt: 'MDRRMO Telemetry',
      isCritical: false,
    ),
  ];

  final List<EvacuationCenter> evacuationCenters = [
    EvacuationCenter(
      id: 'evac-01',
      name: 'Municipal Sports & Disaster Complex',
      barangay: 'Barangay San Roque',
      latitude: 14.6324,
      longitude: 121.0982,
      maxCapacity: 1200,
      currentOccupants: 740,
      status: 'open',
      managerName: 'Capt. Rodrigo Santos',
      managerContact: '0917-555-1201',
      facilities: ['Generator', 'Potable Water', 'Medical Hub', 'Pet-Friendly', 'PWD Ramp'],
      notes: 'Primary designated typhoon shelter with 150kVA generator & elevated cots.',
    ),
    EvacuationCenter(
      id: 'evac-02',
      name: 'San Jose Elementary Evacuation Hub',
      barangay: 'Barangay Malanday',
      latitude: 14.6418,
      longitude: 121.0915,
      maxCapacity: 650,
      currentOccupants: 610,
      status: 'open',
      managerName: 'Principal Ma. Elena Cruz',
      managerContact: '0918-444-2390',
      facilities: ['Generator', 'Clean Water', 'Medical Station', 'PWD Ramp'],
      notes: '94% full. 2nd floor classrooms equipped with emergency solar lamps.',
    ),
    EvacuationCenter(
      id: 'evac-03',
      name: 'District Community Multi-Purpose Pavilion',
      barangay: 'Barangay Santa Elena',
      latitude: 14.6285,
      longitude: 121.1070,
      maxCapacity: 450,
      currentOccupants: 120,
      status: 'open',
      managerName: 'Kgd. Danilo Reyes',
      managerContact: '0920-111-9874',
      facilities: ['Generator', 'Potable Water', 'Pet-Friendly', 'Solar Backup'],
      notes: 'Accepts domesticated pets in secure crates. Potable water station active.',
    ),
    EvacuationCenter(
      id: 'evac-04',
      name: 'Highland Covered Court Youth Center',
      barangay: 'Barangay Fortune Ridge',
      latitude: 14.6521,
      longitude: 121.1210,
      maxCapacity: 500,
      currentOccupants: 500,
      status: 'full',
      managerName: 'Councilor Arlene Morales',
      managerContact: '0922-333-8712',
      facilities: ['Generator', 'Clean Water', 'Medical Station'],
      notes: 'FULL CAPACITY. Redirecting new evacuees to Municipal Sports Complex.',
    ),
    EvacuationCenter(
      id: 'evac-05',
      name: 'Barangay Concepcion Emergency Shelter',
      barangay: 'Barangay Concepcion',
      latitude: 14.6465,
      longitude: 121.1030,
      maxCapacity: 350,
      currentOccupants: 0,
      status: 'standby',
      managerName: 'Kgd. Manuel Bautista',
      managerContact: '0916-777-4521',
      facilities: ['Clean Water', 'Relief Pack', 'PWD Ramp', 'Solar Backup'],
      notes: 'On standby for secondary wave preemptive evacuation.',
    ),
  ];

  final List<EmergencyReport> reports = [
    EmergencyReport(
      id: 'rep-101',
      ticketNumber: 'ALT-2026-0891',
      category: IncidentType.rescueRequest,
      priority: 'critical',
      title: 'Family of 6 Trapped on 2nd Floor Roof with Infant',
      details: 'Chest-deep water on ground floor, power out. 6-month infant and 72yo stroke patient needing oxygen.',
      waterLevel: WaterLevel.chestDeep,
      totalAffected: 6,
      infantCount: 1,
      seniorCount: 1,
      injuredCount: 1,
      address: '#45 Riverside Drive, Greenview Park',
      barangay: 'Barangay Malanday',
      latitude: 14.6412,
      longitude: 121.0921,
      reporterName: 'Carlos Mendoza',
      reporterPhone: '0917-882-9012',
      status: 'unit_dispatched',
      assignedUnit: 'MDRRMO Water Rescue Boat Bravo',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    EmergencyReport(
      id: 'rep-102',
      ticketNumber: 'ALT-2026-0892',
      category: IncidentType.flooding,
      priority: 'high',
      title: 'Flash Flooding - Waist-Deep Water in Alleyways',
      details: 'Creek overflowed into Purok 4 residential alleys. Strong current blocking exit.',
      waterLevel: WaterLevel.waistDeep,
      totalAffected: 18,
      infantCount: 2,
      seniorCount: 4,
      injuredCount: 0,
      address: 'Purok 4, Creek Road',
      barangay: 'Barangay San Roque',
      latitude: 14.6338,
      longitude: 121.0995,
      reporterName: 'Jessica Alcantara',
      reporterPhone: '0928-445-6671',
      status: 'on_scene',
      assignedUnit: 'BDRRMC QRT & BFP Engine 2',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    EmergencyReport(
      id: 'rep-103',
      ticketNumber: 'ALT-2026-0893',
      category: IncidentType.damagedRoad,
      priority: 'high',
      title: 'Main Access Road Blocked - Fallen Tree & Live Wires',
      details: 'Acacia tree fell across both northbound lanes. Electrical wires sparking on wet road.',
      roadPassability: RoadPassability.totallyImpassable,
      totalAffected: 0,
      infantCount: 0,
      seniorCount: 0,
      injuredCount: 0,
      address: 'J.P. Rizal Ave cor. Bonifacio Hwy',
      barangay: 'Barangay Santa Elena',
      latitude: 14.6291,
      longitude: 121.1042,
      reporterName: 'Sgt. Roberto Dimalanta',
      reporterPhone: '0919-332-1140',
      status: 'triaged',
      assignedUnit: 'DPWH Clearing Crew',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    EmergencyReport(
      id: 'rep-104',
      ticketNumber: 'ALT-2026-0894',
      category: IncidentType.landslide,
      priority: 'critical',
      title: 'Slope Collapse & Mudslide Near Hillside Homes',
      details: 'Mud and loose boulders slipped onto backyards at Sitio Puting Bato. Residents evacuated.',
      roadPassability: RoadPassability.impassableLight,
      totalAffected: 12,
      infantCount: 1,
      seniorCount: 3,
      injuredCount: 1,
      address: 'Sitio Puting Bato, Upper Ridge Rd',
      barangay: 'Barangay Fortune Ridge',
      latitude: 14.6540,
      longitude: 121.1245,
      reporterName: 'Kgd. Noel Perez',
      reporterPhone: '0939-998-1234',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
  ];

  final List<GoBagItem> goBagItems = [
    GoBagItem(id: 'gb1', category: 'Water & Food', name: 'Drinking Water (4–6 Liters/person)', description: '3-day hydration & basic hygiene supply.', essential: true, completed: true),
    GoBagItem(id: 'gb2', category: 'Water & Food', name: 'Canned & Ready-to-Eat Food', description: 'Easy-open tuna, sardines, biscuits, manual can opener.', essential: true, completed: true),
    GoBagItem(id: 'gb3', category: 'Medical & Ashfall', name: 'First Aid Kit & 7-Day Medicines', description: 'Bandages, povidone-iodine, paracetamol, ORS, maintenance meds.', essential: true, completed: false),
    GoBagItem(id: 'gb4', category: 'Medical & Ashfall', name: 'N95 Dust Masks & Goggles (Volcanic Ash)', description: 'Essential protection for Mayon ashfall, wipes, sanitizer.', essential: true, completed: true),
    GoBagItem(id: 'gb5', category: 'Tools & Light', name: 'Waterproof Flashlight & Extra Batteries', description: 'LED flashlight or headlamp with sealed spare cells.', essential: true, completed: true),
    GoBagItem(id: 'gb6', category: 'Tools & Light', name: 'Battery / Solar AM-FM Radio', description: 'For PAGASA & PHIVOLCS broadcasts if cell towers fail.', essential: true, completed: false),
    GoBagItem(id: 'gb7', category: 'Tools & Light', name: 'Emergency Whistle & Multi-Tool', description: 'High-decibel whistle to signal rescue teams.', essential: true, completed: true),
    GoBagItem(id: 'gb8', category: 'Tools & Light', name: '20,000mAh Power Bank & Cable', description: 'Stored in waterproof ziplock pouch.', essential: true, completed: false),
    GoBagItem(id: 'gb9', category: 'Documents & Cash', name: 'Waterproof Document Pouch & Cash', description: 'IDs, birth certificates, land titles, small bills.', essential: true, completed: false),
    GoBagItem(id: 'gb10', category: 'Personal Safety', name: 'Raincoat, Blanket & Quick-Dry Clothes', description: '2 sets clothes, sturdy boots, emergency thermal blanket.', essential: false, completed: true),
  ];

  void toggleDrillMode() {
    drillModeActive = !drillModeActive;
    notifyListeners();
  }

  void addReport(EmergencyReport report) {
    reports.insert(0, report);
    notifyListeners();
  }

  void updateReportStatus(String id, String newStatus, {String? assignedUnit}) {
    final idx = reports.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    final old = reports[idx];
    reports[idx] = EmergencyReport(
      id: old.id,
      ticketNumber: old.ticketNumber,
      category: old.category,
      priority: old.priority,
      title: old.title,
      details: old.details,
      waterLevel: old.waterLevel,
      roadPassability: old.roadPassability,
      totalAffected: old.totalAffected,
      infantCount: old.infantCount,
      seniorCount: old.seniorCount,
      injuredCount: old.injuredCount,
      address: old.address,
      barangay: old.barangay,
      latitude: old.latitude,
      longitude: old.longitude,
      reporterName: old.reporterName,
      reporterPhone: old.reporterPhone,
      status: newStatus,
      assignedUnit: assignedUnit ?? old.assignedUnit,
      photoUrl: old.photoUrl,
      createdAt: old.createdAt,
    );
    notifyListeners();
  }

  void updateEvacOccupants(String id, int delta) {
    final idx = evacuationCenters.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final old = evacuationCenters[idx];
    final nextOcc = (old.currentOccupants + delta).clamp(0, old.maxCapacity);
    final nextStatus = nextOcc >= old.maxCapacity ? 'full' : (nextOcc == 0 ? 'standby' : 'open');
    evacuationCenters[idx] = EvacuationCenter(
      id: old.id,
      name: old.name,
      barangay: old.barangay,
      latitude: old.latitude,
      longitude: old.longitude,
      maxCapacity: old.maxCapacity,
      currentOccupants: nextOcc,
      status: nextStatus,
      managerName: old.managerName,
      managerContact: old.managerContact,
      facilities: old.facilities,
      notes: old.notes,
    );
    notifyListeners();
  }

  void broadcastBulletin({required String source, required String category, required String headline, required String action}) {
    bulletins.insert(
      0,
      WeatherBulletin(
        id: 'b-${DateTime.now().millisecondsSinceEpoch}',
        source: source,
        category: category,
        headline: headline,
        description: 'Official emergency dispatch issued via ALERTA Command Center.',
        action: action,
        issuedAt: 'Just now (ICS Broadcast)',
        isCritical: true,
      ),
    );
    notifyListeners();
  }

  void toggleGoBagItem(String id) {
    final item = goBagItems.firstWhere((i) => i.id == id);
    item.completed = !item.completed;
    notifyListeners();
  }

  int get completedGoBagCount => goBagItems.where((i) => i.completed).length;
}
