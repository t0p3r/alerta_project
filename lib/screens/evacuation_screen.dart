import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/evacuation_center.dart';
import '../services/alerta_state.dart';

class EvacuationScreen extends StatefulWidget {
  const EvacuationScreen({super.key});

  @override
  State<EvacuationScreen> createState() => _EvacuationScreenState();
}

class _EvacuationScreenState extends State<EvacuationScreen> {
  String _filter = 'all';

  Future<void> _openGoogleMapsDirections(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _dialManager(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AlertaState>();
    final centers = state.evacuationCenters.where((c) {
      if (_filter == 'open') return c.status == 'open' && !c.isFull;
      if (_filter == 'pets') return c.facilities.any((f) => f.toLowerCase().contains('pet'));
      if (_filter == 'medical') return c.facilities.any((f) => f.toLowerCase().contains('medical'));
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Evacuation Centers & Shelters')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                ChoiceChip(label: const Text('All (5)'), selected: _filter == 'all', onSelected: (_) => setState(() => _filter = 'all')),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Open Only'), selected: _filter == 'open', onSelected: (_) => setState(() => _filter = 'open')),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Pet-Friendly'), selected: _filter == 'pets', onSelected: (_) => setState(() => _filter = 'pets')),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Medical Hub'), selected: _filter == 'medical', onSelected: (_) => setState(() => _filter = 'medical')),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: centers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, idx) => _buildCenterCard(centers[idx]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterCard(EvacuationCenter center) {
    final percentage = (center.currentOccupants / center.maxCapacity).clamp(0.0, 1.0);
    final statusColor = center.isFull
        ? Colors.red
        : center.status == 'standby'
            ? Colors.blueAccent
            : (percentage > 0.85 ? Colors.amber : Colors.green);
    final statusText = center.isFull
        ? 'FULL CAPACITY'
        : center.status == 'standby'
            ? 'STANDBY'
            : (percentage > 0.85 ? 'NEAR FULL (${(percentage * 100).round()}%)' : 'OPEN');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(center.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${center.barangay} · ${center.managerName}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white10,
            color: statusColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${center.currentOccupants} / ${center.maxCapacity} Occupants', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              Text('${center.availableSlots} slots left', style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(center.notes, style: const TextStyle(fontSize: 11.5, color: Colors.white60)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: center.facilities
                .map((f) => Chip(
                      label: Text(f, style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.black26,
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _dialManager(center.managerContact),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call Desk'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                  onPressed: () => _openGoogleMapsDirections(center.latitude, center.longitude),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Get Route'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
