import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/game_result.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();
  List<GameResult> _results = [];
  bool _isLoading = true;
  String _filter = 'All';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _filters = ['All', 'Correct!', 'Too High!', 'Too Low!'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadResults();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    final results = await _db.getAllGameResults();
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  List<GameResult> get _filteredResults {
    if (_filter == 'All') return _results;
    return _results.where((r) => r.status == _filter).toList();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear History?',
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will permanently delete all game records from the database.',
          style: GoogleFonts.outfit(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Delete All',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteAllGameResults();
      _loadResults();
    }
  }

  Future<void> _deleteRecord(GameResult result) async {
    if (result.id == null) return;
    await _db.deleteGameResult(result.id!);
    _loadResults();
  }

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('MMM d, y • h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Correct!':
        return AppTheme.accentGreen;
      case 'Too High!':
        return AppTheme.accentOrange;
      case 'Too Low!':
        return AppTheme.accentPurple;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Correct!':
        return Icons.check_circle_rounded;
      case 'Too High!':
        return Icons.keyboard_arrow_up_rounded;
      case 'Too Low!':
        return Icons.keyboard_arrow_down_rounded;
      default:
        return Icons.help_rounded;
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
        title: ShaderMask(
          shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
          child: Text(
            'Game History',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: AppTheme.accentRed),
              onPressed: _clearAll,
              tooltip: 'Clear all',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildStatsBar(),
                  const SizedBox(height: 12),
                  _buildFilterBar(),
                  const SizedBox(height: 8),
                  Expanded(child: _buildBody()),
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

  Widget _buildStatsBar() {
    final total = _results.length;
    final correct = _results.where((r) => r.status == 'Correct!').length;
    final accuracy =
        total > 0 ? ((correct / total) * 100).toStringAsFixed(0) : '0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _statChip('Total', '$total', AppTheme.accentCyan)),
          const SizedBox(width: 10),
          Expanded(child: _statChip('Correct', '$correct', AppTheme.accentGreen)),
          const SizedBox(width: 10),
          Expanded(child: _statChip('Accuracy', '$accuracy%', AppTheme.accentPurple)),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _filters[i];
          final isSelected = _filter == f;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppTheme.cardBorder,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.accentCyan.withOpacity(0.25),
                          blurRadius: 12,
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (f != 'All')
                    Icon(
                      _statusIcon(f),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : _statusColor(f),
                    ),
                  if (f != 'All') const SizedBox(width: 4),
                  Text(
                    f == 'Correct!' ? '✓ Correct' :
                    f == 'Too High!' ? '↑ High' :
                    f == 'Too Low!' ? '↓ Low' : 'All',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentCyan),
      );
    }

    if (_filteredResults.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.accentCyan,
      backgroundColor: AppTheme.cardBg,
      onRefresh: _loadResults,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _filteredResults.length,
        itemBuilder: (context, index) {
          final result = _filteredResults[index];
          return _buildResultTile(result, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cardBg,
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 48,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _filter == 'All' ? 'No games yet!' : 'No "$_filter" results',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filter == 'All'
                ? 'Play a game to see your history here'
                : 'Try a different filter',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(GameResult result, int index) {
    final color = _statusColor(result.status);
    final icon = _statusIcon(result.status);

    return Dismissible(
      key: Key('result_${result.id}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.accentRed.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentRed.withOpacity(0.3)),
        ),
        child: const Icon(Icons.delete_rounded, color: AppTheme.accentRed, size: 26),
      ),
      onDismissed: (_) => _deleteRecord(result),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200 + index * 30),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          title: Row(
            children: [
              Text(
                'Guess: ',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${result.guessedNumber}',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  result.status,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                if (result.status == 'Correct!') ...[
                  const Icon(
                    Icons.lock_open_rounded,
                    size: 13,
                    color: AppTheme.accentGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Target: ${result.targetNumber}  •  ',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _formatTimestamp(result.timestamp),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
