import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../dashboard/services/status_provider.dart';
import '../../auth/services/auth_state.dart';

class CommandCenter extends StatelessWidget {
  const CommandCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StatusProvider>(context);
    final Color primary = provider.themeColor;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _appBar(context, primary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compliance strip
            _complianceBanner(),
            const SizedBox(height: 20),

            // Grid: Signals (left) + Main (right) — stacked on mobile
            Column(
              children: [
                // Signals
                _sectionLabel('PENDING AI SIGNALS', isLive: true, primary: primary),
                const SizedBox(height: 12),
                _signal('Kothrud: 40% Fever Spike', 'CONFIDENCE: 0.92', Colors.amber, LucideIcons.alertTriangle),
                _signal('Baner: Inventory Replenished', 'STATUS: GREEN ZONE', const Color(0xFF10B981), LucideIcons.checkCircle),
                _signal('Hadapsar: Cluster Detected', 'ACTION: IMMEDIATE', Colors.red, LucideIcons.flame),
                const SizedBox(height: 24),

                // Inventory
                _inventoryCard(primary),
                const SizedBox(height: 20),

                // Broadcast
                _broadcastCard(primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, Color primary) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Icon(LucideIcons.shieldCheck, color: primary, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PulsePoint', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: primary)),
            Text('ADMIN ACCESS GRANTED', style: GoogleFonts.spaceGrotesk(fontSize: 9, letterSpacing: 1.5, color: Colors.grey.shade400)),
          ]),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: primary.withOpacity(0.15))),
            child: Text('ADMIN', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.bold, color: primary)),
          ),
        ),
      ],
    );
  }

  Widget _complianceBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          const CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'DPDP ACT COMPLIANT · VIEWING AGGREGATED REGIONAL DATA ONLY',
              style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5),
            ),
          ),
          Text('0.04ms ago', style: GoogleFonts.spaceGrotesk(fontSize: 9, color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, {bool isLive = false, required Color primary}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
        if (isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2))),
            child: Text('LIVE', style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
          ),
      ],
    );
  }

  Widget _signal(String title, String sub, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]),
      child: Row(
        children: [
          Container(width: 3, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
              const SizedBox(height: 2),
              Text(sub, style: GoogleFonts.spaceGrotesk(fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
            ]),
          ),
          Icon(icon, color: color, size: 18),
        ],
      ),
    );
  }

  Widget _inventoryCard(Color primary) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('INVENTORY INSIGHT', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('STOCK: CRITICAL', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          Container(
            height: 140,
            width: double.infinity,
            color: Colors.grey.shade50,
            child: Center(child: Icon(LucideIcons.map, size: 36, color: Colors.grey.shade200)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stockBadge('Aundh', 'LOW', Colors.amber),
                _stockBadge('Kothrud', 'CRITICAL', Colors.red),
                _stockBadge('Wakad', 'STABLE', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockBadge(String area, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade100)),
      child: Column(children: [
        Text(area.toUpperCase(), style: GoogleFonts.spaceGrotesk(fontSize: 8, color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _broadcastCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Icon(LucideIcons.radio, color: primary, size: 18)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BROADCAST CENTER', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('GENERATE PREVENTATIVE ADVICE', style: GoogleFonts.spaceGrotesk(fontSize: 9, color: Colors.grey.shade400)),
            ]),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Fumigation starting in Kothrud today. Residents are advised to keep windows closed between 17:00 and 19:00 IST.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _verifyCheck('AI Signal Verified'),
            const SizedBox(width: 16),
            _verifyCheck('Inventory Aligned'),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: const Color(0xFF0A2B1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
              child: Text('VERIFY & BROADCAST ALERT', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifyCheck(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LucideIcons.checkCircle, size: 12, color: Color(0xFF10B981)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
      ],
    );
  }
}
