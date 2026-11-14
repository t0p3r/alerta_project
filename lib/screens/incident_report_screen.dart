import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emergency_report.dart';
import '../services/alerta_state.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  IncidentType _selectedType = IncidentType.flooding;
  WaterLevel _waterLevel = WaterLevel.waistDeep;
  RoadPassability _roadPassability = RoadPassability.totallyImpassable;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _reporterNameController = TextEditingController();
  final TextEditingController _reporterPhoneController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  int _totalPeople = 4;
  int _infants = 0;
  int _seniors = 1;
  int _injured = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationService>().getCurrentLocation();
    });
  }

  String _categoryLabel(IncidentType t) {
    switch (t) {
      case IncidentType.flooding:
        return 'Flooding';
      case IncidentType.volcanicAshLahar:
        return 'Volcanic / Lahar';
      case IncidentType.damagedRoad:
        return 'Damaged Road';
      case IncidentType.landslide:
        return 'Landslide';
      case IncidentType.rescueRequest:
        return 'Rescue SOS';
      case IncidentType.collapsedBridge:
        return 'Bridge';
      case IncidentType.fire:
        return 'Fire';
    }
  }

  String _waterLabel(WaterLevel w) {
    switch (w) {
      case WaterLevel.ankleDeep:
        return 'Ankle-Deep (~0.2m)';
      case WaterLevel.kneeDeep:
        return 'Knee-Deep (~0.5m)';
      case WaterLevel.waistDeep:
        return 'Waist-Deep (~1.0m)';
      case WaterLevel.chestDeep:
        return 'Chest-Deep (~1.4m)';
      case WaterLevel.submergedRoof:
        return 'Roof-Level Submerged (>2.0m)';
    }
  }

  String _roadLabel(RoadPassability r) {
    switch (r) {
      case RoadPassability.passableAll:
        return 'Passable to All Vehicles';
      case RoadPassability.passableHeavyOnly:
        return 'Trucks / 4x4 Only';
      case RoadPassability.impassableLight:
        return 'Impassable to Light Vehicles';
      case RoadPassability.totallyImpassable:
        return 'Totally Impassable / Blocked';
    }
  }

  void _submitIncident() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final locationService = context.read<LocationService>();
    final position = locationService.currentPosition;
    final priority = (_selectedType == IncidentType.rescueRequest ||
            _selectedType == IncidentType.volcanicAshLahar ||
            _injured > 0)
        ? 'critical'
        : 'high';

    final report = EmergencyReport(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
      ticketNumber: 'ALT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      category: _selectedType,
      priority: priority,
      title: _titleController.text.trim(),
      details: _detailsController.text.trim(),
      waterLevel: _selectedType == IncidentType.flooding ? _waterLevel : null,
      roadPassability: (_selectedType == IncidentType.damagedRoad ||
              _selectedType == IncidentType.collapsedBridge ||
              _selectedType == IncidentType.landslide)
          ? _roadPassability
          : null,
      totalAffected: _totalPeople,
      infantCount: _infants,
      seniorCount: _seniors,
      injuredCount: _injured,
      address: locationService.currentAddress,
      barangay: _landmarkController.text.trim().isEmpty ? 'Direct GPS Pin' : _landmarkController.text.trim(),
      latitude: position?.latitude ?? 14.6324,
      longitude: position?.longitude ?? 121.0982,
      reporterName: _reporterNameController.text.trim(),
      reporterPhone: _reporterPhoneController.text.trim(),
      status: 'pending',
      createdAt: DateTime.now(),
    );

    context.read<AlertaState>().addReport(report);
    await context.read<FirebaseService>().submitReport(report);

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dispatched to Command ICS! Ticket: ${report.ticketNumber}'),
          backgroundColor: Colors.green,
        ),
      );
      _titleController.clear();
      _detailsController.clear();
      _landmarkController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationService = context.watch<LocationService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Report Emergency Incident')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Incident Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: IncidentType.values.map((type) {
                final selected = _selectedType == type;
                return ChoiceChip(
                  label: Text(_categoryLabel(type), style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  selectedColor: const Color(0xFFDC2626),
                  onSelected: (_) => setState(() => _selectedType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            if (_selectedType == IncidentType.flooding) ...[
              DropdownButtonFormField<WaterLevel>(
                value: _waterLevel,
                dropdownColor: const Color(0xFF1E293B),
                decoration: const InputDecoration(labelText: 'Flood Water Depth', border: OutlineInputBorder()),
                items: WaterLevel.values
                    .map((w) => DropdownMenuItem(value: w, child: Text(_waterLabel(w))))
                    .toList(),
                onChanged: (v) => setState(() => _waterLevel = v ?? WaterLevel.waistDeep),
              ),
              const SizedBox(height: 12),
            ],
            if (_selectedType == IncidentType.damagedRoad ||
                _selectedType == IncidentType.collapsedBridge ||
                _selectedType == IncidentType.landslide) ...[
              DropdownButtonFormField<RoadPassability>(
                value: _roadPassability,
                dropdownColor: const Color(0xFF1E293B),
                decoration: const InputDecoration(labelText: 'Road Passability', border: OutlineInputBorder()),
                items: RoadPassability.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(_roadLabel(r))))
                    .toList(),
                onChanged: (v) => setState(() => _roadPassability = v ?? RoadPassability.totallyImpassable),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: Colors.redAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('GPS Emergency Coordinates', style: TextStyle(fontSize: 11, color: Colors.white60)),
                        Text(locationService.currentAddress,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: () => locationService.getCurrentLocation()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _landmarkController,
              decoration: const InputDecoration(
                labelText: 'Barangay / Specific Landmark',
                hintText: 'e.g. Brgy. Malanday near Chapel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Incident Summary',
                hintText: 'e.g. Waist-deep flood / Ashfall & lahar rising',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Details & Immediate Hazards',
                hintText: 'Electrical wires down, medical needs, trapped persons...',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Please provide details' : null,
            ),
            const SizedBox(height: 14),
            const Text('Affected Persons Triage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _counterChip('Total', _totalPeople, (d) => setState(() => _totalPeople = (_totalPeople + d).clamp(0, 200))),
                _counterChip('Infants', _infants, (d) => setState(() => _infants = (_infants + d).clamp(0, 50))),
                _counterChip('Seniors', _seniors, (d) => setState(() => _seniors = (_seniors + d).clamp(0, 50))),
                _counterChip('Injured', _injured, (d) => setState(() => _injured = (_injured + d).clamp(0, 50))),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _reporterNameController,
                    decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Name required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _reporterPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Phone required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubmitting ? null : _submitIncident,
              icon: _isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label: Text(_isSubmitting ? 'DISPATCHING TO MDRRMO...' : 'SUBMIT RESCUE DISPATCH REPORT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterChip(String label, int val, void Function(int) onDelta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          InkWell(onTap: () => onDelta(-1), child: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.amber)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('$val', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          InkWell(onTap: () => onDelta(1), child: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF34D399))),
        ],
      ),
    );
  }
}
