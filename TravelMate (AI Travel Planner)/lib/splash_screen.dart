import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import 'main_shell.dart';
import 'features/auth/screens/auth_screen.dart';
import 'services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbController;
  late AnimationController _planeController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _checkAuth();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _planeController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    if (SupabaseService.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B1426), Color(0xFF0D1F38), Color(0xFF091929)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // ─── Background orbs ──────────────────────────────────────────
                CustomPaint(
                  painter: _SplashBgPainter(_orbController.value),
                  child: const SizedBox.expand(),
                ),

                // ─── Content ──────────────────────────────────────────────────
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ─── App Icon ────────────────────────────────────────
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: AppColors.teal.withOpacity(0.3),
                                blurRadius: 60,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.explore_rounded,
                            size: 62,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 700.ms)
                            .scale(
                              begin: const Offset(0.4, 0.4),
                              duration: 700.ms,
                              curve: Curves.elasticOut,
                            ),

                        const SizedBox(height: 32),

                        // ─── App Name ────────────────────────────────────────
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: const Text(
                            'TravelMate',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0, delay: 400.ms),

                        const SizedBox(height: 8),

                        // ─── Tagline ─────────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.12)),
                          ),
                          child: const Text(
                            '✈️  Your AI Travel Companion',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 500.ms),

                        const SizedBox(height: 70),

                        // ─── Animated dots loader ─────────────────────────────
                        _DotsLoader()
                            .animate()
                            .fadeIn(delay: 900.ms, duration: 400.ms),

                        const SizedBox(height: 16),

                        const Text(
                          'Preparing your adventure...',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textHint,
                            letterSpacing: 0.3,
                          ),
                        ).animate().fadeIn(delay: 1100.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DotsLoader extends StatefulWidget {
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _controllers.add(c);
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) c.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _controllers.asMap().entries.map((e) {
        return AnimatedBuilder(
          animation: e.value,
          builder: (_, __) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8 + e.value.value * 4,
              height: 8 + e.value.value * 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4 * e.value.value),
                    blurRadius: 8,
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _SplashBgPainter extends CustomPainter {
  final double t;
  _SplashBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final orbs = [
      _OrbData(0.15, 0.15, 0.55, const Color(0xFF2E86DE)),
      _OrbData(0.85, 0.2, 0.45, const Color(0xFF1ABC9C)),
      _OrbData(0.5, 0.75, 0.5, const Color(0xFF6C3483)),
      _OrbData(0.1, 0.85, 0.35, const Color(0xFFF39C12)),
    ];

    for (int i = 0; i < orbs.length; i++) {
      final o = orbs[i];
      final dy = math.sin((t + i * 0.25) * math.pi * 2) * 0.05;
      final cx = o.cx * size.width;
      final cy = (o.cy + dy) * size.height;
      final r = o.r * size.width;

      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [o.color.withOpacity(0.18), o.color.withOpacity(0.0)],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_SplashBgPainter old) => old.t != t;
}

class _OrbData {
  final double cx, cy, r;
  final Color color;
  const _OrbData(this.cx, this.cy, this.r, this.color);
}
