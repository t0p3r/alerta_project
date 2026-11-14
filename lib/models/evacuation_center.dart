class EvacuationCenter {
  final String id;
  final String name;
  final String barangay;
  final double latitude;
  final double longitude;
  final int maxCapacity;
  final int currentOccupants;
  final String status; // open, full, standby, closed
  final String managerName;
  final String managerContact;
  final List<String> facilities;
  final String notes;

  EvacuationCenter({
    required this.id,
    required this.name,
    required this.barangay,
    required this.latitude,
    required this.longitude,
    required this.maxCapacity,
    required this.currentOccupants,
    required this.status,
    required this.managerName,
    required this.managerContact,
    required this.facilities,
    required this.notes,
  });

  double get occupancyPercentage => (currentOccupants / maxCapacity) * 100;
  bool get isFull => currentOccupants >= maxCapacity || status == 'full';
  int get availableSlots => (maxCapacity - currentOccupants).clamp(0, maxCapacity);

  factory EvacuationCenter.fromMap(String id, Map<String, dynamic> data) {
    return EvacuationCenter(
      id: id,
      name: data['name'] ?? 'Evacuation Center',
      barangay: data['barangay'] ?? '',
      latitude: (data['latitude'] ?? 14.6324).toDouble(),
      longitude: (data['longitude'] ?? 121.0982).toDouble(),
      maxCapacity: (data['maxCapacity'] ?? 500) as int,
      currentOccupants: (data['currentOccupants'] ?? 0) as int,
      status: data['status'] ?? 'open',
      managerName: data['managerName'] ?? 'DRRM Officer',
      managerContact: data['managerContact'] ?? '911',
      facilities: List<String>.from(data['facilities'] ?? []),
      notes: data['notes'] ?? '',
    );
  }
}
