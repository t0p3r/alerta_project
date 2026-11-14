import 'package:cloud_firestore/cloud_firestore.dart';

enum IncidentType { flooding, damagedRoad, collapsedBridge, landslide, rescueRequest, fire, volcanicAshLahar }
enum WaterLevel { ankleDeep, kneeDeep, waistDeep, chestDeep, submergedRoof }
enum RoadPassability { passableAll, passableHeavyOnly, impassableLight, totallyImpassable }

class EmergencyReport {
  final String id;
  final String ticketNumber;
  final IncidentType category;
  final String priority; // critical, high, medium, low
  final String title;
  final String details;
  final WaterLevel? waterLevel;
  final RoadPassability? roadPassability;
  final int totalAffected;
  final int infantCount;
  final int seniorCount;
  final int injuredCount;
  final String address;
  final String barangay;
  final double latitude;
  final double longitude;
  final String reporterName;
  final String reporterPhone;
  final String status; // pending, triaged, unit_dispatched, on_scene, resolved
  final String? assignedUnit;
  final String? photoUrl;
  final DateTime createdAt;

  EmergencyReport({
    required this.id,
    required this.ticketNumber,
    required this.category,
    required this.priority,
    required this.title,
    required this.details,
    this.waterLevel,
    this.roadPassability,
    required this.totalAffected,
    required this.infantCount,
    required this.seniorCount,
    required this.injuredCount,
    required this.address,
    required this.barangay,
    required this.latitude,
    required this.longitude,
    required this.reporterName,
    required this.reporterPhone,
    required this.status,
    this.assignedUnit,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ticketNumber': ticketNumber,
      'category': category.name,
      'priority': priority,
      'title': title,
      'details': details,
      'waterLevel': waterLevel?.name,
      'roadPassability': roadPassability?.name,
      'affected': {
        'total': totalAffected,
        'infants': infantCount,
        'seniors': seniorCount,
        'injured': injuredCount,
      },
      'location': {
        'address': address,
        'barangay': barangay,
        'geoPoint': GeoPoint(latitude, longitude),
      },
      'reporter': {
        'name': reporterName,
        'phone': reporterPhone,
      },
      'status': status,
      'assignedUnit': assignedUnit,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory EmergencyReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geo = data['location']?['geoPoint'] as GeoPoint? ?? const GeoPoint(14.5995, 120.9842);
    final affected = data['affected'] as Map<String, dynamic>? ?? {};

    return EmergencyReport(
      id: doc.id,
      ticketNumber: data['ticketNumber'] ?? 'ALT-0000',
      category: IncidentType.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => IncidentType.rescueRequest,
      ),
      priority: data['priority'] ?? 'high',
      title: data['title'] ?? 'Emergency Incident',
      details: data['details'] ?? '',
      totalAffected: (affected['total'] ?? 1) as int,
      infantCount: (affected['infants'] ?? 0) as int,
      seniorCount: (affected['seniors'] ?? 0) as int,
      injuredCount: (affected['injured'] ?? 0) as int,
      address: data['location']?['address'] ?? '',
      barangay: data['location']?['barangay'] ?? '',
      latitude: geo.latitude,
      longitude: geo.longitude,
      reporterName: data['reporter']?['name'] ?? '',
      reporterPhone: data['reporter']?['phone'] ?? '',
      status: data['status'] ?? 'pending',
      assignedUnit: data['assignedUnit'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
