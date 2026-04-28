import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/game_result.dart';
import '../theme/app_theme.dart';
import 'history_screen.dart';

class ResultScreen extends StatefulWidget {
  final GameResult result;
  final int attemptCount;

  const ResultScreen({
    super.key,
    required this.result,
    required this.attemptCount,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _particleAnimation;

  bool get _isCorrect => widget.result.status == 'Correct!';
  bool get _isTooHigh => widget.result.status == 'Too High!';

  LinearGradient get _resultGradient {
    if (_isCorrect) return AppTheme.correctGradient;
    if (_isTooHigh) return AppTheme.tooHighGradient;
    return AppTheme.tooLowGradient;
  }

  Color get _accentColor {
    if (_isCorrect) return AppTheme.accentGreen;
    if (_isTooHigh) return AppTheme.accentOrange;
    return AppTheme.accentPurple;
  }

  IconData get _statusIcon {
    if (_isCorrect) return Icons.check_circle_rounded;
    if (_isTooHigh) return Icons.keyboard_arrow_up_rounded;
    return Icons.keyboard_arrow_down_rounded;
  }

  String get _statusMessage {
    if (_isCorrect) return 'Nailed it! 🎉';
    if (_isTooHigh) return 'Too High! Go lower';
    return 'Too Low! Go higher';
  }

  String get _motivationalText {
    if (_isCorrect) {
      if (widget.attemptCount == 1) return 'Incredible! First try!';
      if (widget.attemptCount <= 3) return 'Amazing! Very few attempts!';
      return 'Well done! You figured it out!';
    }
    if (_isTooHigh) return 'Your guess was above the target. Try a smaller number!';
    return 'Your guess was below the target. Try a larger number!';
  }

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
      _slideController.forward();
      if (_isCorrect) _particleController.repeat();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('MMM d, y • h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Result',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          if (_isCorrect) _buildCelebrationOverlay(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildStatusBadge(),
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildResultCard(),
                        const SizedBox(height: 20),
                        _buildDetailCards(),
                        const SizedBox(height: 20),
                        _buildTimestampCard(),
                        const SizedBox(height: 32),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF0A0E1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, _) {
        return IgnorePointer(
          child: CustomPaint(
            painter: _ConfettiPainter(_particleController.value),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _resultGradient,
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.5),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              _statusIcon,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) =>
                _resultGradient.createShader(bounds),
            child: Text(
              _statusMessage,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _motivationalText,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            _accentColor.withOpacity(0.15),
            _accentColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _accentColor.withOpacity(0.3), width: 1.5),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Text(
            'YOUR GUESS',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (b) => _resultGradient.createShader(b),
            child: Text(
              '${widget.result.guessedNumber}',
              style: GoogleFonts.outfit(
                fontSize: 72,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          if (_isCorrect) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.accentGreen.withOpacity(0.4)),
              ),
              child: Text(
                '🎯 Exact Match!',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCards() {
    return Row(
      children: [
        Expanded(
          child: _detailCard(
            'Target',
            _isCorrect
                ? '${widget.result.targetNumber}'
                : '???',
            Icons.lock_rounded,
            _isCorrect ? _accentColor : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _detailCard(
            'Attempt',
            '#${widget.attemptCount}',
            Icons.repeat_rounded,
            AppTheme.accentCyan,
          ),
        ),
      ],
    );
  }

  Widget _detailCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded,
              color: AppTheme.textSecondary, size: 18),
          const SizedBox(width: 10),
          Text(
            _formatTimestamp(widget.result.timestamp),
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: _resultGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: Colors.white),
              label: Text(
                _isCorrect ? 'Play Again' : 'Try Again',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.history_rounded, size: 20),
            label: Text(
              'View History',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.cardBorder, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  _ConfettiPainter(this.progress);

  final List<Color> _colors = const [
    AppTheme.accentCyan,
    AppTheme.accentGreen,
    AppTheme.accentPurple,
    Colors.yellow,
    Colors.pink,
    Colors.orange,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = _SeededRandom(42);
    final paint = Paint();
    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final startY = -20.0;
      final endY = size.height + 20;
      final y = startY + (endY - startY) * progress + rng.nextDouble() * 60;
      paint.color = _colors[i % _colors.length].withOpacity(
        (1 - progress).clamp(0, 1) * 0.8,
      );
      canvas.drawCircle(Offset(x, y % size.height), rng.nextDouble() * 5 + 2, paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

class _SeededRandom {
  int _seed;
  _SeededRandom(this._seed);
  double nextDouble() {
    _seed = (_seed * 1664525 + 1013904223) & 0xFFFFFFFF;
    return (_seed & 0x7FFFFFFF) / 0x7FFFFFFF;
  }
}
