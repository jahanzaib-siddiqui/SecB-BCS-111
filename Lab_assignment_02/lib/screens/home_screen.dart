import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../models/game_result.dart';
import 'result_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _guessController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper();

  int _targetNumber = 0;
  int _maxNumber = 100;
  int _attemptCount = 0;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _generateNewNumber();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  void _generateNewNumber() {
    final rng = Random();
    _targetNumber = rng.nextInt(_maxNumber) + 1;
    _attemptCount = 0;
    _guessController.clear();
  }

  void _resetGame() {
    setState(() {
      _generateNewNumber();
    });
    _fadeController.reset();
    _fadeController.forward();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.refresh, color: AppTheme.accentCyan),
            const SizedBox(width: 8),
            Text(
              'New game started! Guess 1–$_maxNumber',
              style: GoogleFonts.outfit(color: AppTheme.textPrimary),
            ),
          ],
        ),
        backgroundColor: AppTheme.cardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitGuess() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.reset();
      _shakeController.forward();
      return;
    }

    final guess = int.parse(_guessController.text.trim());
    setState(() => _isLoading = true);
    _attemptCount++;

    String status;
    if (guess == _targetNumber) {
      status = 'Correct!';
    } else if (guess > _targetNumber) {
      status = 'Too High!';
    } else {
      status = 'Too Low!';
    }

    final result = GameResult(
      guessedNumber: guess,
      targetNumber: _targetNumber,
      status: status,
      timestamp: DateTime.now().toIso8601String(),
    );

    await _db.insertGameResult(result);

    if (mounted) {
      setState(() => _isLoading = false);
      if (status == 'Correct!') _generateNewNumber();

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ResultScreen(result: result, attemptCount: _attemptCount),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: Curves.easeInOutCubic),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ).then((_) {
        if (status == 'Correct!') {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _guessController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Number Quest',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [AppTheme.accentCyan, AppTheme.accentPurple],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            tooltip: 'History',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Animated background
          _buildBackground(size),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildHeaderSection(),
                    const SizedBox(height: 32),
                    _buildGuessCard(),
                    const SizedBox(height: 24),
                    _buildRangeSelector(),
                    const SizedBox(height: 24),
                    _buildAttemptsInfo(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    _buildNewGameButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D1B2A), Color(0xFF0A0E1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -80,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentPurple.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -60,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: 2 - _pulseAnimation.value,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentCyan.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentCyan.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.casino_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            'Guess the Number',
            style: GoogleFonts.outfit(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A random number from 1 to $_maxNumber is waiting…',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 15,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGuessCard() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = _shakeAnimation.value > 0
            ? sin(_shakeAnimation.value * 3 * pi) * 8
            : 0.0;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentCyan.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Guess',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentCyan,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _guessController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '?',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 28,
                    color: AppTheme.textSecondary.withOpacity(0.4),
                    fontWeight: FontWeight.w700,
                  ),
                  prefixIcon: const Icon(
                    Icons.tag_rounded,
                    color: AppTheme.accentCyan,
                    size: 22,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a number';
                  }
                  final num = int.tryParse(value.trim());
                  if (num == null) return 'Enter a valid number';
                  if (num < 1 || num > _maxNumber) {
                    return 'Enter a number between 1 and $_maxNumber';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submitGuess(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AppTheme.accentPurple, size: 20),
          const SizedBox(width: 12),
          Text(
            'Range: 1 – $_maxNumber',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          _rangeChip(50),
          const SizedBox(width: 8),
          _rangeChip(100),
          const SizedBox(width: 8),
          _rangeChip(500),
        ],
      ),
    );
  }

  Widget _rangeChip(int value) {
    final isSelected = _maxNumber == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _maxNumber = value;
          _generateNewNumber();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.surfaceGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.cardBorder,
          ),
        ),
        child: Text(
          '$value',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAttemptsInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _infoChip(
          Icons.repeat_rounded,
          'Attempts',
          '$_attemptCount',
          AppTheme.accentCyan,
        ),
        const SizedBox(width: 16),
        _infoChip(
          Icons.straighten_rounded,
          'Range',
          '1 - $_maxNumber',
          AppTheme.accentPurple,
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentCyan.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitGuess,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'Submit Guess',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNewGameButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _resetGame,
        icon: const Icon(Icons.refresh_rounded, size: 20),
        label: Text(
          'New Game',
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
    );
  }
}
