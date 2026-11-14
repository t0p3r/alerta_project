import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHotlinesScreen extends StatelessWidget {
  const EmergencyHotlinesScreen({super.key});

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disaster & Rescue Hotlines')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _hotlineCard(
            title: 'MDRRMO 24/7 Operations Command',
            hotline: '911',
            alt: '(02) 8928-8754',
            radio: 'VHF 145.550 MHz (Tone 88.5)',
            badge: 'COMMAND CENTER',
            badgeColor: Colors.red,
          ),
          _hotlineCard(
            title: 'DOST-PHIVOLCS Mayon Volcano Observatory',
            hotline: '(052) 482-0031',
            alt: '(02) 8426-1468',
            radio: 'VHF 146.940 MHz (Bicol Volcano Net)',
            badge: 'MAYON ALERT 3',
            badgeColor: Colors.orange,
          ),
          _hotlineCard(
            title: 'Bureau of Fire Protection (BFP Search-Rescue)',
            hotline: '(02) 8646-0427',
            alt: '0917-888-3473',
            radio: 'VHF 144.740 MHz',
            badge: 'FIRE & EXTRACTION',
            badgeColor: Colors.deepOrange,
          ),
          _hotlineCard(
            title: 'Municipal Police Station (PNP)',
            hotline: '117',
            alt: '(02) 8646-1631',
            radio: 'VHF 148.125 MHz',
            badge: 'LAW & EVAC SECURITY',
            badgeColor: Colors.blue,
          ),
          _hotlineCard(
            title: 'Emergency Medical Services (Trauma Ambulance)',
            hotline: '(02) 8646-2436',
            alt: '0922-911-3677',
            radio: 'VHF 146.200 MHz',
            badge: 'AMBULANCE RESCUE',
            badgeColor: Colors.green,
          ),
          _hotlineCard(
            title: 'Philippine Coast Guard (PCG River / Marine)',
            hotline: '0917-724-4682',
            alt: '(02) 8527-8481',
            radio: 'Marine Ch 16 (156.800 MHz)',
            badge: 'WATER RESCUE BOAT',
            badgeColor: Colors.cyan,
          ),
          _hotlineCard(
            title: 'Philippine Red Cross Disaster Chapter',
            hotline: '143',
            alt: '(02) 8790-2300',
            radio: 'PRC Emergency Net',
            badge: 'FIRST AID & BLOOD',
            badgeColor: Colors.redAccent,
          ),
          _hotlineCard(
            title: 'Barangay DRRMC Quick Response Desk',
            hotline: '0919-456-7890',
            alt: '(02) 8646-9912',
            radio: 'Barangay Tanod UHF',
            badge: 'LOCAL RESPONDER',
            badgeColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _hotlineCard({
    required String title,
    required String hotline,
    required String alt,
    required String radio,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: badgeColor.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Hotline: $hotline  ·  Alt: $alt', style: const TextStyle(fontSize: 13, color: Colors.white70)),
          Text('Radio: $radio', style: const TextStyle(fontSize: 12, color: Colors.amberAccent)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              onPressed: () => _call(hotline),
              icon: const Icon(Icons.phone_in_talk, size: 18),
              label: Text('CALL $hotline NOW'),
            ),
          ),
        ],
      ),
    );
  }
}
