import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegionalPulseMonitor extends StatefulWidget {
  final String regionId;
  const RegionalPulseMonitor({super.key, required this.regionId});

  @override
  State<RegionalPulseMonitor> createState() => _RegionalPulseMonitorState();
}

class _RegionalPulseMonitorState extends State<RegionalPulseMonitor> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 2.0, end: 15.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('regional_status')
          .doc(widget.regionId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStaticCard(title: "ERROR", value: "0.0", color: Colors.red);
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildStaticCard(title: "INITIALIZING", value: "--", color: Colors.blueGrey);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String status = data['status'] ?? 'stable';
        final double pathogenIndex = (data['pulse_score'] ?? 0.0).toDouble();
        final String reasoning = data['reasoning'] ?? 'Processing neural data...';
        final String themeHex = data['ui_theme'] ?? '#4ADE80';
        final Color themeColor = _parseHexColor(themeHex);

        // Control Neural Heartbeat Animation
        if (status == 'alert') {
          if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }

        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F21),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withOpacity(status == 'alert' ? 0.15 : 0.05),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PATHOGEN PROPENSITY INDEX',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(LucideIcons.activity, size: 16, color: themeColor),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          pathogenIndex.toStringAsFixed(1),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                          child: Text(
                            '%',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              color: themeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'NEURAL DECISION MATRIX',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        letterSpacing: 1,
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reasoning,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaticCard({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F21),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
