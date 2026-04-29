import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../auth/services/auth_state.dart';

const _kLocalities = [
  '[PUNE] Kothrud',
  '[PUNE] Baner',
  '[PUNE] Hadapsar',
  '[PUNE] Wakad',
  '[PUNE] Aundh',
  '[PUNE] Viman Nagar',
  '[PUNE] Bavdhan',
  '[PUNE] Hinjewadi',
  '[PUNE] Magarpatta',
  '[PUNE] Pimple Saudagar',
  '[PUNE] Shivajinagar',
  '[PUNE] Swargate',
  '[PUNE] Katraj',
  '[PUNE] Kondhwa',
  '[PUNE] Pashan',
  '[MUMBAI] Bandra',
  '[MUMBAI] Andheri',
  '[MUMBAI] Juhu',
  '[MUMBAI] Borivali',
  '[MUMBAI] Colaba',
  '[MUMBAI] Dadar',
  '[MUMBAI] Ghatkopar',
  '[MUMBAI] Kurla',
  '[MUMBAI] Malad',
  '[MUMBAI] Powai',
  '[MUMBAI] Worli',
  '[MUMBAI] Chembur',
  '[MUMBAI] Sion',
  '[MUMBAI] Mulund',
  '[MUMBAI] Kandivali',
];

const _kLocalityCoords = {
  '[PUNE] Kothrud': '18.50° N, 73.81° E',
  '[PUNE] Baner': '18.56° N, 73.79° E',
  '[PUNE] Hadapsar': '18.50° N, 73.92° E',
  '[PUNE] Wakad': '18.59° N, 73.76° E',
  '[PUNE] Aundh': '18.56° N, 73.81° E',
  '[PUNE] Viman Nagar': '18.56° N, 73.91° E',
  '[PUNE] Bavdhan': '18.51° N, 73.77° E',
  '[PUNE] Hinjewadi': '18.59° N, 73.73° E',
  '[PUNE] Magarpatta': '18.51° N, 73.93° E',
  '[PUNE] Pimple Saudagar': '18.60° N, 73.78° E',
  '[PUNE] Shivajinagar': '18.53° N, 73.85° E',
  '[PUNE] Swargate': '18.50° N, 73.85° E',
  '[PUNE] Katraj': '18.45° N, 73.85° E',
  '[PUNE] Kondhwa': '18.47° N, 73.89° E',
  '[PUNE] Pashan': '18.54° N, 73.79° E',
  '[MUMBAI] Bandra': '19.05° N, 72.82° E',
  '[MUMBAI] Andheri': '19.11° N, 72.85° E',
  '[MUMBAI] Juhu': '19.10° N, 72.82° E',
  '[MUMBAI] Borivali': '19.23° N, 72.85° E',
  '[MUMBAI] Colaba': '18.91° N, 72.81° E',
  '[MUMBAI] Dadar': '19.01° N, 72.84° E',
  '[MUMBAI] Ghatkopar': '19.08° N, 72.91° E',
  '[MUMBAI] Kurla': '19.06° N, 72.88° E',
  '[MUMBAI] Malad': '19.18° N, 72.84° E',
  '[MUMBAI] Powai': '19.12° N, 72.90° E',
  '[MUMBAI] Worli': '19.01° N, 72.81° E',
  '[MUMBAI] Chembur': '19.05° N, 72.90° E',
  '[MUMBAI] Sion': '19.03° N, 72.86° E',
  '[MUMBAI] Mulund': '19.17° N, 72.95° E',
  '[MUMBAI] Kandivali': '19.20° N, 72.85° E',
};

const _kAgeGroups = ['10–20', '20–30', '30–40', '40–50', '50–60+'];

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String _selectedAge = '20–30';
  String _selectedLocality = _kLocalities[0];
  bool _loading = false;

  static const Color _primary = Color(0xFF059669);

  void _continue() async {
    setState(() => _loading = true);
    
    // Request location permission per user requirement
    try {
      final status = await Permission.location.request();
      if (status.isPermanentlyDenied) {
        // Handle permanently denied case if necessary, but proceed to dashboard anyway
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      context.read<AuthState>().completeSetup(
            age: _selectedAge,
            loc: _selectedLocality,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          const Icon(LucideIcons.radio, color: _primary, size: 18),
          const SizedBox(width: 8),
          Text('CENTRAL_DISTRICT_V01',
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black, letterSpacing: -0.3)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade100,
              child: const Icon(LucideIcons.user, size: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Step Indicator ──────────────────────────────────────
              Row(children: [
                Text('STEP 01 / 02',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 9, fontWeight: FontWeight.bold, color: _primary, letterSpacing: 2)),
                const SizedBox(width: 12),
                Container(width: 40, height: 1, color: _primary.withOpacity(0.2)),
              ]),
              const SizedBox(height: 12),

              Text('Biometric\nParameters',
                  style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.1,
                      letterSpacing: -1)),
              const SizedBox(height: 12),
              Text(
                'Calibrate your observer profile by defining your demographic segment and geographic zone.',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500, height: 1.6),
              ),
              const SizedBox(height: 40),

              // ── Age Cohort ────────────────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Age Cohort',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('BINNED DEMOGRAPHIC DATA',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 9, color: Colors.grey.shade400, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(_selectedAge,
                            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: _primary)),
                        Text('SELECTED',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
                      ]),
                    ]),
                    const SizedBox(height: 28),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _kAgeGroups
                            .map((age) => GestureDetector(
                                  onTap: () => setState(() => _selectedAge = age),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedAge == age ? _primary.withOpacity(0.1) : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: _selectedAge == age
                                              ? _primary.withOpacity(0.4)
                                              : Colors.grey.shade200),
                                    ),
                                    child: Text(
                                      age,
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          fontWeight: _selectedAge == age ? FontWeight.bold : FontWeight.w500,
                                          color: _selectedAge == age ? _primary : Colors.grey.shade400),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Spatial Context ──────────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Spatial Context',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('GEOGRAPHIC SURVEILLANCE ROOT',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 9, color: Colors.grey.shade400, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),

                    // Locality Dropdown
                    Text('SELECT YOUR LOCALITY',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLocality,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 16),
                          iconEnabledColor: _primary,
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
                          items: _kLocalities
                              .map((loc) => DropdownMenuItem(
                                    value: loc,
                                    child: Text(loc, style: GoogleFonts.inter(fontSize: 13, fontWeight: loc.startsWith('[') ? FontWeight.bold : FontWeight.normal)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedLocality = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info hint
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _primary.withOpacity(0.08))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.info, size: 13, color: _primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Providing your locality allows PulsePoint to benchmark regional disease signals against your demographic.',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Map Visual ───────────────────────────────────────────
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9F4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _primary.withOpacity(0.1)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse ring
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.85, end: 1.15),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOut,
                      builder: (_, v, child) => Transform.scale(scale: v, child: child),
                      child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _primary.withOpacity(0.12), width: 1))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: _primary.withOpacity(0.2))),
                      child: const Icon(LucideIcons.locateFixed, color: _primary, size: 26),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _primary.withOpacity(0.1))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedLocality,
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                            Text(_kLocalityCoords[_selectedLocality] ?? '18.5204° N, 73.8567° E',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9, fontWeight: FontWeight.bold, color: _primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Action Button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ADE80),
                    foregroundColor: const Color(0xFF0A2B1A),
                    disabledBackgroundColor: const Color(0xFF4ADE80).withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A2B1A)))
                      : Text('CONTINUE TO DASHBOARD',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primary.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}
