import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../services/status_provider.dart';
import '../../auth/services/auth_state.dart';

class ObserverDashboard extends StatefulWidget {
  const ObserverDashboard({super.key});

  @override
  State<ObserverDashboard> createState() => _ObserverDashboardState();
}

class _ObserverDashboardState extends State<ObserverDashboard> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _pulseCtrl;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Sync region monitoring with selected locality
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthState>();
      context.read<StatusProvider>().setRegion(auth.locality);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StatusProvider>(context);
    final Color primary = provider.themeColor;
    final bool isAlert = provider.status == 'alert';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          _DashboardHome(
            primary: primary,
            isAlert: isAlert,
            provider: provider,
            pulse: _pulseCtrl,
            onProfileClick: () => _pageController.animateToPage(3, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic),
          ),
          _SurroundView(primary: primary, pulse: _pulseCtrl),
          _InsightsView(primary: primary, provider: provider),
          _ProfileView(primary: primary),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(primary),
    );
  }

  Widget _buildBottomNav(Color primary) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5))),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, LucideIcons.home, primary),
              _navItem(1, LucideIcons.map, primary),
              _navItem(2, LucideIcons.lineChart, primary),
              _navItem(3, LucideIcons.user, primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, Color primary) {
    final bool active = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: active ? primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: active ? primary : Colors.grey.shade300, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TAB 1 — Dashboard Home (matches dashboard_with_profile_nav)
// ─────────────────────────────────────────────────────────────────
class _DashboardHome extends StatefulWidget {
  const _DashboardHome({
    required this.primary,
    required this.isAlert,
    required this.provider,
    required this.pulse,
    required this.onProfileClick,
  });
  final Color primary;
  final bool isAlert;
  final StatusProvider provider;
  final Animation<double> pulse;
  final VoidCallback onProfileClick;

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  double _scrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>();
    final double opacity = (_scrollOffset / 60).clamp(0.0, 0.9);
    final double blur = (_scrollOffset / 60).clamp(0.0, 15.0);

    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            setState(() {
              _scrollOffset = notification.metrics.pixels;
            });
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(1.0 - opacity),
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: Row(children: [
                Icon(LucideIcons.radio, color: widget.primary, size: 18),
                const SizedBox(width: 8),
                Text(auth.locality.toUpperCase().replaceAll(' — ', '_'),
                    style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        letterSpacing: -0.3)),
              ]),
              actions: [
                Center(
                  child: Text('NODE SYNC: ACTIVE',
                      style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w600, color: Colors.grey.shade400, letterSpacing: 1.5)),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: widget.onProfileClick,
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(LucideIcons.user, size: 14, color: Theme.of(context).iconTheme.color?.withOpacity(0.5) ?? Colors.grey)),
                  ),
                ),
              ],
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(opacity),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor.withOpacity(opacity),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _FadeInSlide(delay: 0, child: _SafetyCard(primary: widget.primary, isAlert: widget.isAlert, provider: widget.provider, pulse: widget.pulse)),
                  const SizedBox(height: 16),
                  _FadeInSlide(delay: 100, child: _PredictionCard(primary: widget.primary, isAlert: widget.isAlert, provider: widget.provider)),
                  const SizedBox(height: 16),
                  _FadeInSlide(delay: 200, child: _WeatherCard(primary: widget.primary)),
                  const SizedBox(height: 16),
                  _FadeInSlide(delay: 300, child: _PharmacyCard(primary: widget.primary)),
                  const SizedBox(height: 16),
                  _FadeInSlide(delay: 400, child: _ClinicalCard(primary: widget.primary)),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Animation Helper ─────────────────────────────────────────
class _FadeInSlide extends StatefulWidget {
  const _FadeInSlide({required this.child, this.delay = 0});
  final Widget child;
  final int delay;

  @override
  State<_FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<_FadeInSlide> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(top: _visible ? 0 : 40),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        opacity: _visible ? 1.0 : 0.0,
        child: widget.child,
      ),
    );
  }
}

// ── Status Card ────────────────────────────────────────────────────
// ── Safety Status Card (Engine 3.0) ────────────────────────────────
class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.primary, required this.isAlert, required this.provider, required this.pulse});
  final Color primary;
  final bool isAlert;
  final StatusProvider provider;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAlert ? Colors.red.shade300.withOpacity(0.5) : Theme.of(context).dividerColor.withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.2).animate(pulse),
                child: Container(width: 8, height: 8, decoration: BoxDecoration(color: primary, shape: BoxShape.circle)),
              ),
              const SizedBox(width: 10),
              Text('REAL-TIME SAFETY ORACLE',
                  style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: primary, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            provider.safetyLabel,
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -1.2),
          ),
          const SizedBox(height: 12),
          Text(
            isAlert ? 'DANGER: Multiple outbreaks detected in your immediate vicinity. Move to safe zone.' : 'SAFE: No infectious signals found. Area status is optimal.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Weather Card ───────────────────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatusProvider>();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('ENVIRONMENT',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 8, fontWeight: FontWeight.bold, color: primary, letterSpacing: 1.5)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('LIVE DATA', style: GoogleFonts.spaceGrotesk(fontSize: 6, fontWeight: FontWeight.bold, color: primary)),
            ),
          ]),
          const SizedBox(height: 12),
          Text(provider.weatherDesc,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Text('${provider.temperature.toStringAsFixed(1)}°C',
              style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color, height: 1)),
          Text('Surface Conditions',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(LucideIcons.droplets, size: 12, color: Colors.blue),
              const SizedBox(width: 8),
              Text('${provider.humidity.toStringAsFixed(0)}% Humidity', 
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Pharmacy Card ──────────────────────────────────────────────────
class _PharmacyCard extends StatelessWidget {
  const _PharmacyCard({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatusProvider>();
    final isLow = provider.stockLabel == 'Low Stock';
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isLow ? Colors.red.shade100 : Theme.of(context).dividerColor.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('MEDICINE SUPPLY',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 8, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.amber.shade700, letterSpacing: 1.5)),
            Icon(LucideIcons.truck, size: 16, color: isLow ? Colors.red : Colors.amber.shade400),
          ]),
          const SizedBox(height: 12),
          Text(provider.stockLabel, 
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: isLow ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 8),
          Text(isLow ? 'URGENT: Pharmacies reporting stock depletion.' : 'Pharmacy network reporting sufficient inventory.',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ── Clinical Card (UPGRADED) ─────────────────────────────────────────
class _ClinicalCard extends StatelessWidget {
  const _ClinicalCard({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatusProvider>();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('HOSPITAL CAPACITY',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 8, fontWeight: FontWeight.bold, color: primary, letterSpacing: 1.5)),
            Icon(LucideIcons.building2, size: 16, color: primary.withOpacity(0.4)),
          ]),
          const SizedBox(height: 12),
          Text('Local Facility Load', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          ...provider.hospitals.map((h) => _hospitalRow(h, primary, context)).toList(),
        ],
      ),
    );
  }

  Widget _hospitalRow(dynamic h, Color primary, BuildContext context) {
    final int total = (h['dengue'] ?? 0) + (h['malaria'] ?? 0) + (h['unknown'] ?? 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(h['name'].toUpperCase(), style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: primary.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
              child: Text('~1.2 km', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: primary)),
            ),
            const SizedBox(width: 12),
            Text('$total Patients', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: primary)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _countTag('Dengue: ${h['dengue']}'),
            const SizedBox(width: 8),
            _countTag('Malaria: ${h['malaria']}'),
            const SizedBox(width: 8),
            if (h['unknown'] > 0) _countTag('UNKNOWN: ${h['unknown']}', isWarning: true),
          ]),
        ],
      ),
    );
  }

  Widget _countTag(String text, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: isWarning ? Colors.red : Colors.blue)),
    );
  }
}

// ── Aggregate Card ─────────────────────────────────────────────────
class _AggregateCard extends StatelessWidget {
  const _AggregateCard({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SYSTEM SYNTHESIS',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 8, fontWeight: FontWeight.bold, color: primary, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Text('Aggregate Regional Vitals',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _m('Alert Risk', 'Low', context),
              _m('Sync', '99.8%', context),
              _m('Bio-Load', 'Normal', context, color: primary),
            ],
          ),
          const SizedBox(height: 18),
          Text('TRAJECTORY: STABLE',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _m(String label, String value, BuildContext context, {Color? color}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
      const SizedBox(height: 6),
      Text(value,
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w900, color: color ?? Theme.of(context).textTheme.bodyLarge?.color)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────
// TAB 2 — Surround / Map
// ─────────────────────────────────────────────────────────────────
class _SurroundView extends StatefulWidget {
  const _SurroundView({required this.primary, required this.pulse});
  final Color primary;
  final Animation<double> pulse;

  @override
  State<_SurroundView> createState() => _SurroundViewState();
}

class _SurroundViewState extends State<_SurroundView> {
  final MapController _mapController = MapController();
  double _scrollOffset = 0;
  
  // 30-Area Precision Mapping
  static const Map<String, ll.LatLng> _kNeighborhoods = {
    '[PUNE] Kothrud': ll.LatLng(18.5074, 73.8150),
    '[PUNE] Baner': ll.LatLng(18.5590, 73.7868),
    '[PUNE] Hadapsar': ll.LatLng(18.5089, 73.9259),
    '[PUNE] Wakad': ll.LatLng(18.5987, 73.7607),
    '[PUNE] Aundh': ll.LatLng(18.5626, 73.8105),
    '[PUNE] Viman Nagar': ll.LatLng(18.5679, 73.9143),
    '[PUNE] Bavdhan': ll.LatLng(18.5135, 73.7744),
    '[PUNE] Hinjewadi': ll.LatLng(18.5913, 73.7389),
    '[PUNE] Magarpatta': ll.LatLng(18.5144, 73.9352),
    '[PUNE] Pimple Saudagar': ll.LatLng(18.6011, 73.7841),
    '[PUNE] Shivajinagar': ll.LatLng(18.5308, 73.8549),
    '[PUNE] Swargate': ll.LatLng(18.5018, 73.8545),
    '[PUNE] Katraj': ll.LatLng(18.4529, 73.8545),
    '[PUNE] Kondhwa': ll.LatLng(18.4771, 73.8907),
    '[PUNE] Pashan': ll.LatLng(18.5415, 73.7925),
    '[MUMBAI] Bandra': ll.LatLng(19.0596, 72.8295),
    '[MUMBAI] Andheri': ll.LatLng(19.1136, 72.8697),
    '[MUMBAI] Juhu': ll.LatLng(19.1000, 72.8200),
    '[MUMBAI] Borivali': ll.LatLng(19.2307, 72.8567),
    '[MUMBAI] Colaba': ll.LatLng(18.9067, 72.8147),
    '[MUMBAI] Dadar': ll.LatLng(19.0178, 72.8478),
    '[MUMBAI] Ghatkopar': ll.LatLng(19.0833, 72.9111),
    '[MUMBAI] Kurla': ll.LatLng(19.0667, 72.8833),
    '[MUMBAI] Malad': ll.LatLng(19.1861, 72.8486),
    '[MUMBAI] Powai': ll.LatLng(19.1247, 72.9023),
    '[MUMBAI] Worli': ll.LatLng(19.0167, 72.8167),
    '[MUMBAI] Chembur': ll.LatLng(19.0500, 72.9000),
    '[MUMBAI] Sion': ll.LatLng(19.0300, 72.8600),
    '[MUMBAI] Mulund': ll.LatLng(19.1726, 72.9565),
    '[MUMBAI] Kandivali': ll.LatLng(19.2000, 72.8500),
  };

  ll.LatLng _getCoords(String locality) {
    return _kNeighborhoods[locality] ?? _kNeighborhoods.values.first;
  }

  // Precision Pinpointing logic
  List<Marker> _getPOIMarkers(ll.LatLng center, List<dynamic> hospitals) {
    final List<Marker> markers = [];
    
    // 1. Observer Node (User)
    markers.add(
      Marker(
        point: center,
        width: 50,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
             AnimatedBuilder(
               animation: widget.pulse,
               builder: (_, child) => Container(
                 width: 40 * widget.pulse.value,
                 height: 40 * widget.pulse.value,
                 decoration: BoxDecoration(
                   color: widget.primary.withOpacity(1.0 - widget.pulse.value),
                   shape: BoxShape.circle,
                 ),
               ),
             ),
             Container(
               width: 12,
               height: 12,
               decoration: BoxDecoration(color: widget.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
             ),
          ],
        ),
      ),
    );

    // 2. Pinpointed Hospitals (Sector-based placement)
    for (int i = 0; i < hospitals.length; i++) {
      final h = hospitals[i];
      final double latOff = i == 0 ? 0.004 : (i == 1 ? -0.003 : 0.001);
      final double lngOff = i == 0 ? 0.005 : (i == 1 ? 0.006 : -0.007);
      
      markers.add(
        Marker(
          point: ll.LatLng(center.latitude + latOff, center.longitude + lngOff),
          width: 80,
          height: 80,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.blue.shade200)),
                child: Text(h['name'] ?? 'Clinic', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold)),
              ),
              const Icon(LucideIcons.home, color: Colors.blue, size: 24),
            ],
          ),
        ),
      );
    }

    markers.add(
      Marker(
        point: ll.LatLng(center.latitude - 0.005, center.longitude - 0.004),
        width: 40,
        height: 40,
        child: const Icon(LucideIcons.pill, color: Colors.orange, size: 22),
      ),
    );

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>();
    final statusProvider = context.watch<StatusProvider>();
    final ll.LatLng location = _getCoords(auth.locality);
    
    final double opacity = (_scrollOffset / 60).clamp(0.0, 0.9);
    final double blur = (_scrollOffset / 60).clamp(0.0, 15.0);

    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollUpdateNotification) setState(() => _scrollOffset = n.metrics.pixels);
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(1.0 - opacity),
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: Text('SURROUND',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 10, fontWeight: FontWeight.bold, color: widget.primary, letterSpacing: 2)),
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(opacity),
                      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(opacity))),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _FadeInSlide(delay: 50, child: Text(auth.locality.split(']')[1].trim(),
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 32),
                  _FadeInSlide(
                    delay: 150,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 520,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                border: Border.all(color: widget.primary.withOpacity(0.2), width: 2)),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: location,
                                initialZoom: 14.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.pulsepoint.app',
                                ),
                                MarkerLayer(
                                  markers: _getPOIMarkers(location, statusProvider.hospitals),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton.small(
                            onPressed: () => _mapController.move(location, 13.0),
                            backgroundColor: Colors.white,
                            foregroundColor: widget.primary,
                            child: const Icon(LucideIcons.locateFixed, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FadeInSlide(delay: 250, child: _ClinicalCard(primary: widget.primary)),
                  const SizedBox(height: 24),
                  _FadeInSlide(
                    delay: 350,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: widget.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                           Icon(LucideIcons.shieldCheck, size: 16, color: widget.primary),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Text(
                               'PULSE-SYNC ACTIVE: Tracking ${auth.locality.split(' — ')[0]} district metrics in real-time.',
                               style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                             ),
                           ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TAB 4 — Profile
// ─────────────────────────────────────────────────────────────────
class _ProfileView extends StatefulWidget {
  const _ProfileView({required this.primary});
  final Color primary;

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  double _scrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final double opacity = (_scrollOffset / 60).clamp(0.0, 0.9);
    final double blur = (_scrollOffset / 60).clamp(0.0, 15.0);

    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollUpdateNotification) setState(() => _scrollOffset = n.metrics.pixels);
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(1.0 - opacity),
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: Text('PROFILE',
                  style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: widget.primary, letterSpacing: 2)),
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(opacity),
                      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(opacity))),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  Center(
                    child: _FadeInSlide(
                      delay: 0,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: widget.primary.withOpacity(0.1),
                        child: Icon(LucideIcons.user, size: 40, color: widget.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: _FadeInSlide(
                      delay: 100,
                      child: Text('Observer Node',
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: _FadeInSlide(
                      delay: 150,
                      child: Text(
                        '${auth.ageGroup} · ${auth.locality}',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Theme Toggle Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(auth.isDarkMode ? LucideIcons.moon : LucideIcons.sun, size: 20, color: widget.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Appearance Mode',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Switch.adaptive(
                          value: auth.isDarkMode,
                          activeColor: widget.primary,
                          onChanged: (_) => auth.toggleTheme(),
                        ),
                      ],
                    ),
                  ),
                  _row('Age Cohort', auth.ageGroup.isNotEmpty ? auth.ageGroup : '—', LucideIcons.users),
                  _row('Locality', auth.locality.isNotEmpty ? auth.locality : '—', LucideIcons.mapPin),
                  _row('Node ID', 'DIST_V01', LucideIcons.fingerprint),
                  _row('Status', 'Active Observer', LucideIcons.activity),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => context.read<AuthState>().logout(),
                      icon: const Icon(LucideIcons.logOut, size: 16),
                      label: Text('Sign Out',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          side: BorderSide(color: Theme.of(context).dividerColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5))),
      child: Row(children: [
        Icon(icon, size: 16, color: widget.primary),
        const SizedBox(width: 14),
        Expanded(
            child: Text(label,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500))),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// ── Prediction & Forecast Card (NEW) ────────────────────────────────
class _PredictionCard extends StatelessWidget {
  const _PredictionCard({required this.primary, required this.isAlert, required this.provider});
  final Color primary;
  final bool isAlert;
  final StatusProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isAlert ? Colors.red.shade100 : Theme.of(context).dividerColor.withOpacity(0.5), width: isAlert ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PREDICTION & MITIGATION',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 8, fontWeight: FontWeight.bold, color: primary, letterSpacing: 1.5)),
              Icon(LucideIcons.sparkles, size: 16, color: primary.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(isAlert ? LucideIcons.alertCircle : LucideIcons.shield, color: primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isAlert ? provider.pathogenType : 'System Status: Optimal',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(provider.safetyLabel,
              style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: isAlert ? Colors.red : Colors.grey.shade400)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PREVENTIVE PROTOCOL',
                    style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.bold, color: primary)),
                const SizedBox(height: 8),
                Text(provider.preventiveMeasures,
                    style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).textTheme.bodyLarge?.color, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Insights View (Engine 3.0 Checklist) ──────────────────────────
class _InsightsView extends StatefulWidget {
  const _InsightsView({required this.primary, required this.provider});
  final Color primary;
  final StatusProvider provider;

  @override
  State<_InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<_InsightsView> {
  double _scrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> measures = widget.provider.preventiveMeasures.split('. ');
    final double opacity = (_scrollOffset / 60).clamp(0.0, 0.9);
    final double blur = (_scrollOffset / 60).clamp(0.0, 15.0);

    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollUpdateNotification) setState(() => _scrollOffset = n.metrics.pixels);
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(1.0 - opacity),
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: Text('INSIGHTS & MITIGATION',
                  style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: widget.primary, letterSpacing: 2)),
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(opacity),
                      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(opacity))),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _FadeInSlide(delay: 100, child: Text('Safety Checklist', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 32),
                  ...List.generate(measures.length, (i) {
                    if (measures[i].isEmpty) return const SizedBox();
                    return _FadeInSlide(
                      delay: 200 + (i * 100),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.checkCircle, color: widget.primary, size: 20),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(measures[i], style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color, height: 1.4)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
