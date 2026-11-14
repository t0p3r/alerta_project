import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emergency_report.dart';
import '../services/alerta_state.dart';

class PreparednessCommandScreen extends StatefulWidget {
  const PreparednessCommandScreen({super.key});

  @override
  State<PreparednessCommandScreen> createState() => _PreparednessCommandScreenState();
}

class _PreparednessCommandScreenState extends State<PreparednessCommandScreen> {
  bool _showCommandCenter = false;
  String _statusFilter = 'all';

  void _openBroadcastDialog(BuildContext context) {
    final headlineCtrl = TextEditingController();
    final actionCtrl = TextEditingController(text: 'Preemptive evacuation mandatory for high-risk barangays.');
    String category = 'Flood Advisory';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Row(
            children: [
              Icon(Icons.campaign, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('Issue ICS Broadcast', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: const Color(0xFF1E293B),
                  decoration: const InputDecoration(labelText: 'Alert Category', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Flood Advisory', child: Text('Flood Advisory (MDRRMO)')),
                    DropdownMenuItem(value: 'Volcanic Activity', child: Text('Volcanic / Lahar (PHIVOLCS)')),
                    DropdownMenuItem(value: 'Typhoon', child: Text('Typhoon Warning (PAGASA)')),
                    DropdownMenuItem(value: 'Heavy Rainfall', child: Text('Red Rainfall Warning')),
                  ],
                  onChanged: (v) => setDialogState(() => category = v ?? 'Flood Advisory'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: headlineCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Alert Headline',
                    hintText: 'e.g. Forced Evacuation - Barangay Malanday',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: actionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Recommended Action',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              onPressed: () {
                if (headlineCtrl.text.trim().isEmpty) return;
                context.read<AlertaState>().broadcastBulletin(
                  source: category == 'Volcanic Activity' ? 'PHIVOLCS' : 'MDRRMO',
                  category: category,
                  headline: headlineCtrl.text.trim(),
                  action: actionCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Emergency bulletin broadcast to Home Alerts!'), backgroundColor: Colors.red),
                );
              },
              child: const Text('BROADCAST NOW'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AlertaState>();
    final completed = state.completedGoBagCount;
    final total = state.goBagItems.length;
    final pct = total > 0 ? completed / total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_showCommandCenter ? 'MDRRMO Command Center' : '72-Hr Go-Bag & ICS'),
        actions: [
          if (_showCommandCenter)
            IconButton(
              icon: const Icon(Icons.campaign, color: Color(0xFFEF4444)),
              tooltip: 'Broadcast Alert',
              onPressed: () => _openBroadcastDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, icon: Icon(Icons.backpack_outlined), label: Text('72-Hr Go-Bag')),
                ButtonSegment(value: true, icon: Icon(Icons.security), label: Text('Command ICS')),
              ],
              selected: {_showCommandCenter},
              onSelectionChanged: (s) => setState(() => _showCommandCenter = s.first),
            ),
          ),
          Expanded(
            child: _showCommandCenter
                ? _buildCommandView(context, state)
                : _buildGoBagView(state, completed, total, pct),
          ),
        ],
      ),
    );
  }

  Widget _buildGoBagView(AlertaState state, int completed, int total, double pct) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
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
                  const Text('Go-Bag Readiness', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    '$completed / $total Ready (${(pct * 100).round()}%)',
                    style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: Colors.white10,
                color: pct >= 0.8 ? const Color(0xFF10B981) : Colors.amber,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              const Text(
                'Includes N95 volcanic ash masks, 3-day potable water, solar/AM-FM radio, and waterproof documents.',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...state.goBagItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.completed ? const Color(0xFF10B981).withOpacity(0.4) : Colors.white10,
              ),
            ),
            child: CheckboxListTile(
              value: item.completed,
              onChanged: (_) => state.toggleGoBagItem(item.id),
              activeColor: const Color(0xFF10B981),
              title: Text(
                item.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: item.completed ? TextDecoration.lineThrough : null,
                  color: item.completed ? Colors.white60 : Colors.white,
                ),
              ),
              subtitle: Text(
                '${item.category} · ${item.description}',
                style: const TextStyle(fontSize: 11, color: Colors.white60),
              ),
              secondary: item.essential
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('72H', style: TextStyle(fontSize: 10, color: Color(0xFFF87171), fontWeight: FontWeight.bold)),
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCommandView(BuildContext context, AlertaState state) {
    final pendingCount = state.reports.where((r) => r.status == 'pending').length;
    final criticalCount = state.reports.where((r) => r.priority == 'critical' && r.status != 'resolved').length;
    final totalOcc = state.evacuationCenters.fold<int>(0, (s, c) => s + c.currentOccupants);
    final totalCap = state.evacuationCenters.fold<int>(0, (s, c) => s + c.maxCapacity);

    final filtered = state.reports.where((r) {
      if (_statusFilter == 'pending') return r.status == 'pending';
      if (_statusFilter == 'active') return r.status == 'triaged' || r.status == 'unit_dispatched' || r.status == 'on_scene';
      if (_statusFilter == 'resolved') return r.status == 'resolved';
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Metrics strip
        Row(
          children: [
            _metricBox('Critical', '$criticalCount', const Color(0xFFEF4444)),
            const SizedBox(width: 8),
            _metricBox('Pending', '$pendingCount', Colors.amber),
            const SizedBox(width: 8),
            _metricBox('Evacuees', '$totalOcc/$totalCap', const Color(0xFF38BDF8)),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => _openBroadcastDialog(context),
          icon: const Icon(Icons.campaign),
          label: const Text('ISSUE EMERGENCY PUBLIC BROADCAST'),
        ),
        const SizedBox(height: 16),
        const Text('Live Incident Dispatch Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(label: const Text('All'), selected: _statusFilter == 'all', onSelected: (_) => setState(() => _statusFilter = 'all')),
            ChoiceChip(label: const Text('Pending'), selected: _statusFilter == 'pending', onSelected: (_) => setState(() => _statusFilter = 'pending')),
            ChoiceChip(label: const Text('Active'), selected: _statusFilter == 'active', onSelected: (_) => setState(() => _statusFilter = 'active')),
            ChoiceChip(label: const Text('Resolved'), selected: _statusFilter == 'resolved', onSelected: (_) => setState(() => _statusFilter = 'resolved')),
          ],
        ),
        const SizedBox(height: 10),
        ...filtered.map((rep) => _incidentCard(context, state, rep)),
        const SizedBox(height: 16),
        const Text('Shelter Occupancy Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...state.evacuationCenters.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${c.currentOccupants} / ${c.maxCapacity} (${c.status.toUpperCase()})',
                            style: const TextStyle(fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.amber),
                    onPressed: () => state.updateEvacOccupants(c.id, -25),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF34D399)),
                    onPressed: () => state.updateEvacOccupants(c.id, 25),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _metricBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  Widget _incidentCard(BuildContext context, AlertaState state, EmergencyReport rep) {
    final statusColor = rep.status == 'resolved'
        ? const Color(0xFF10B981)
        : rep.status == 'pending'
            ? const Color(0xFFEF4444)
            : Colors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${rep.ticketNumber} · ${rep.barangay}', style: const TextStyle(fontSize: 11, color: Colors.white60)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                child: Text(rep.status.toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(rep.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(rep.details, style: const TextStyle(fontSize: 12, color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (rep.assignedUnit != null) ...[
            const SizedBox(height: 6),
            Text('Unit: ${rep.assignedUnit}', style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              if (rep.status == 'pending' || rep.status == 'triaged')
                OutlinedButton(
                  onPressed: () => state.updateReportStatus(rep.id, 'unit_dispatched', assignedUnit: 'MDRRMO Rescue Team Alpha'),
                  child: const Text('Dispatch Unit'),
                ),
              if (rep.status == 'unit_dispatched')
                OutlinedButton(
                  onPressed: () => state.updateReportStatus(rep.id, 'on_scene'),
                  child: const Text('Mark On-Scene'),
                ),
              if (rep.status != 'resolved')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                  onPressed: () => state.updateReportStatus(rep.id, 'resolved'),
                  child: const Text('Resolve'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
