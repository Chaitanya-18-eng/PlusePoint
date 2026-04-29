import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorMsg;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  static const String _prefEmail = 'pp_email';
  static const String _prefPass = 'pp_pass';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMsg = null;
    });
    _animCtrl.reset();
    _animCtrl.forward();
  }

  Future<void> _submit() async {
    setState(() => _errorMsg = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text;

    if (_isSignUp) {
      // Register: check email not already taken
      final existing = prefs.getString(_prefEmail);
      if (existing != null && existing == email) {
        setState(() {
          _loading = false;
          _errorMsg = 'An account with this email already exists. Please sign in.';
        });
        return;
      }
      await prefs.setString(_prefEmail, email);
      await prefs.setString(_prefPass, pass);
      if (mounted) context.read<AuthState>().login();
    } else {
      // Sign In: verify against stored credentials
      final storedEmail = prefs.getString(_prefEmail);
      final storedPass = prefs.getString(_prefPass);

      if (storedEmail == null) {
        setState(() {
          _loading = false;
          _errorMsg = 'No account found. Please sign up first.';
        });
        return;
      }

      if (storedEmail == email && storedPass == pass) {
        if (mounted) context.read<AuthState>().login();
      } else {
        setState(() {
          _loading = false;
          _errorMsg = 'Incorrect email or password. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF059669);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // ── Brand ──────────────────────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Icon(LucideIcons.activity, color: primary, size: 34),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'PULSEPOINT',
                    style: GoogleFonts.inter(
                        fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NEURAL SURVEILLANCE BACKBONE',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 36),

                  // ── Card ───────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 40,
                            offset: const Offset(0, 16)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            _isSignUp ? 'Create Account' : 'Welcome Back',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isSignUp
                                ? 'Register as a Public Observer'
                                : 'Sign in to your observer account',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 24),

                          // Email
                          _label('ACCESS EMAIL'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: _dec('Enter your email', LucideIcons.mail),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Password
                          _label('PASSWORD'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: _dec(
                              '••••••••',
                              LucideIcons.lock,
                              suffix: _eyeToggle(_obscurePass, () => setState(() => _obscurePass = !_obscurePass)),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 6) return 'Minimum 6 characters';
                              return null;
                            },
                          ),

                          // Confirm Password (sign-up only)
                          if (_isSignUp) ...[
                            const SizedBox(height: 18),
                            _label('CONFIRM PASSWORD'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmCtrl,
                              obscureText: _obscureConfirm,
                              style: GoogleFonts.inter(fontSize: 14),
                              decoration: _dec(
                                '••••••••',
                                LucideIcons.lock,
                                suffix: _eyeToggle(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please confirm your password';
                                if (v != _passCtrl.text) return 'Passwords do not match';
                                return null;
                              },
                            ),
                          ],

                          // Error Banner
                          if (_errorMsg != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.red.shade100)),
                              child: Row(children: [
                                Icon(LucideIcons.alertCircle, size: 14, color: Colors.red.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_errorMsg!,
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.red.shade600)),
                                ),
                              ]),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // Submit
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: primary.withOpacity(0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(
                                      _isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 16),

                          // Toggle Sign In / Sign Up
                          Center(
                            child: GestureDetector(
                              onTap: _toggleMode,
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400),
                                  children: [
                                    TextSpan(text: _isSignUp ? 'Already have an account? ' : "Don't have an account? "),
                                    TextSpan(
                                      text: _isSignUp ? 'Sign In' : 'Sign Up',
                                      style: GoogleFonts.inter(
                                          fontSize: 12, fontWeight: FontWeight.bold, color: primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Footer
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 24, height: 1, color: Colors.grey.shade200),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'DPDP ACT 2026 · COMPLIANT',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 9, color: Colors.grey.shade400, letterSpacing: 1.5),
                      ),
                    ),
                    Container(width: 24, height: 1, color: Colors.grey.shade200),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
          fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.2),
    );
  }

  InputDecoration _dec(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 13),
      prefixIcon: Icon(icon, size: 16, color: Colors.grey.shade300),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder:
          const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF1F5F9), width: 2)),
      focusedBorder:
          const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF059669), width: 2)),
      errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
      focusedErrorBorder:
          const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
      errorStyle: GoogleFonts.inter(fontSize: 11),
    );
  }

  Widget _eyeToggle(bool obscure, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
          obscure ? LucideIcons.eyeOff : LucideIcons.eye, size: 16, color: Colors.grey.shade400),
    );
  }
}
