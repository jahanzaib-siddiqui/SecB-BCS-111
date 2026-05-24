import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/utils/app_utils.dart';
import '../../services/supabase_service.dart';
import '../../models/trip_model.dart';
import '../trip_planner/screens/plan_trip_screen.dart';
import '../trip_planner/screens/trip_detail_screen.dart';
import '../hotels/screens/hotels_screen.dart';
import '../attractions/screens/attractions_screen.dart';
import '../expense_tracker/screens/expense_overview_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<TripModel> _trips = [];
  bool _isLoading = true;
  String _userName = 'Traveler';
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _loadData();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await SupabaseService.getUserProfile();
      if (profile != null && mounted) {
        final name = profile['full_name'] as String? ?? '';
        setState(() => _userName =
            name.isNotEmpty ? name.split(' ').first : 'Traveler');
      }

      final tripsData = await SupabaseService.getTrips();
      if (mounted) {
        setState(() {
          _trips = tripsData.map((t) => TripModel.fromJson(t)).toList();
        });
      }
    } catch (e) {
      // Silently handle errors on home
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcomingTrips =
        _trips.where((t) => t.startDate.isAfter(DateTime.now())).toList();
    final activeTrip = _trips
        .where((t) =>
            t.startDate.isBefore(DateTime.now()) &&
            t.endDate.isAfter(DateTime.now()))
        .firstOrNull;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Animated Travel Background ─────────────────────────────────────
          _TravelBackground(controller: _bgController),

          // ─── Content ─────────────────────────────────────────────────────────
          RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.accent,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                    child: _buildHeader(upcomingTrips.length)),

                if (activeTrip != null)
                  SliverToBoxAdapter(
                      child: _buildActiveTripBanner(activeTrip)),

                SliverToBoxAdapter(child: _buildQuickActions()),

                SliverToBoxAdapter(child: _buildAIFeatures()),

                SliverToBoxAdapter(child: _buildPopularDestinations()),

                SliverToBoxAdapter(child: _buildRecentTrips()),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlanTripScreen()),
          ).then((_) => _loadData()),
          borderRadius: BorderRadius.circular(18),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Plan Trip',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.5, end: 0);
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────────
  Widget _buildHeader(int upcomingCount) {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final greetIcon =
        hour < 12 ? '☀️' : hour < 17 ? '🌤️' : '🌙';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // App logo pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.explore_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 5),
                    Text(
                      'TravelMate',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Notification bell
              _GlassButton(
                onTap: () {},
                child: const Icon(Icons.notifications_outlined,
                    color: AppColors.textSecondary, size: 22),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.1, end: 0),

          const SizedBox(height: 20),

          Text(
            '$greetIcon $greeting,',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ).animate().fadeIn(delay: 100.ms),

          Text(
            _userName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1, end: 0),

          const SizedBox(height: 6),

          ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: Text(
              upcomingCount > 0
                  ? '$upcomingCount upcoming trip${upcomingCount > 1 ? 's' : ''} waiting ✈️'
                  : 'Where shall we go next? ✈️',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }

  // ─── ACTIVE TRIP BANNER ────────────────────────────────────────────────────────
  Widget _buildActiveTripBanner(TripModel trip) {
    final daysLeft = trip.endDate.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A5276), Color(0xFF1ABC9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.flight_takeoff_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('Active Trip',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.white60)),
                ]),
                const SizedBox(height: 2),
                Text(
                  trip.destination,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$daysLeft day${daysLeft != 1 ? 's' : ''} remaining',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TripDetailScreen(trip: trip)),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: const Text('View',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0);
  }

  // ─── QUICK ACTIONS ─────────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.map_rounded,
        label: 'Plan Trip',
        gradient: [const Color(0xFF2E86DE), const Color(0xFF1A5276)],
        iconBg: const Color(0xFF1A5276),
      ),
      _QuickAction(
        icon: Icons.hotel_rounded,
        label: 'Hotels',
        gradient: [const Color(0xFF1ABC9C), const Color(0xFF148F77)],
        iconBg: const Color(0xFF148F77),
      ),
      _QuickAction(
        icon: Icons.photo_camera_rounded,
        label: 'Attractions',
        gradient: [const Color(0xFFF39C12), const Color(0xFFD68910)],
        iconBg: const Color(0xFFD68910),
      ),
      _QuickAction(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Expenses',
        gradient: [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
        iconBg: const Color(0xFFC0392B),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Quick Access'),
          const SizedBox(height: 14),
          Row(
            children: actions.asMap().entries.map((entry) {
              final i = entry.key;
              final action = entry.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleQuickAction(i),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: action.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: action.gradient.first.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(action.icon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 400 + i * 80))
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                    ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _handleQuickAction(int index) {
    switch (index) {
      case 0:
        Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PlanTripScreen()))
            .then((_) => _loadData());
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => HotelsScreen(destination: 'Lahore')));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AttractionsScreen(
                    destination: 'Lahore', tripType: 'Cultural')));
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ExpenseOverviewScreen()));
        break;
    }
  }

  // ─── AI FEATURES ───────────────────────────────────────────────────────────────
  Widget _buildAIFeatures() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _SectionHeader(title: 'AI-Powered'),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                gradient: AppColors.sunsetGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(children: [
                Icon(Icons.auto_awesome, size: 11, color: Colors.white),
                SizedBox(width: 3),
                Text('AI',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          // Main AI card
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlanTripScreen()),
            ).then((_) => _loadData()),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.auroraGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Itinerary Generator',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Get a personalized day-by-day plan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmallAICard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Budget\nOptimizer',
                  color: AppColors.teal,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallAICard(
                  icon: Icons.hotel_rounded,
                  title: 'Smart Hotel\nFinder',
                  color: AppColors.accent,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  // ─── POPULAR DESTINATIONS ──────────────────────────────────────────────────────
  Widget _buildPopularDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionHeader(title: 'Popular Destinations'),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.textHint),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 8),
            itemCount: AppConstants.popularDestinations.length,
            itemBuilder: (context, index) {
              final dest = AppConstants.popularDestinations[index];
              return _DestinationCard(
                destination: dest,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttractionsScreen(
                        destination: dest['name']!,
                        tripType: 'Cultural',
                      ),
                    ),
                  );
                },
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 700 + index * 70))
                  .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ─── RECENT TRIPS ──────────────────────────────────────────────────────────────
  Widget _buildRecentTrips() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (_trips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: EmptyState(
          icon: Icons.luggage_outlined,
          title: 'No trips yet',
          subtitle: 'Tap + to plan your first AI-powered trip!',
          actionLabel: 'Plan My First Trip',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlanTripScreen()),
          ).then((_) => _loadData()),
        ),
      );
    }

    final recentTrips = _trips.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionHeader(title: 'Recent Trips'),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: 14),
          ...recentTrips.asMap().entries.map((e) {
            return _TripCard(
              trip: e.value,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TripDetailScreen(trip: e.value)),
              ).then((_) => _loadData()),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 900 + e.key * 100))
                .slideY(begin: 0.15, end: 0);
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED TRAVEL BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
class _TravelBackground extends StatelessWidget {
  final AnimationController controller;

  const _TravelBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF0B1426), Color(0xFF0D1F38), Color(0xFF091929)]
                  : const [Color(0xFFF0F6FF), Color(0xFFEAF3FF), Color(0xFFF5F8FF)],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(
            painter: _TravelBgPainter(controller.value, isDark: isDark),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _TravelBgPainter extends CustomPainter {
  final double t;
  final bool isDark;
  _TravelBgPainter(this.t, {this.isDark = true});

  @override
  void paint(Canvas canvas, Size size) {
    final orbOpacity = isDark ? 0.12 : 0.10;
    final orbs = [
      _Orb(cx: 0.15, cy: 0.1,  r: 0.35, color: const Color(0xFF2E86DE)),
      _Orb(cx: 0.85, cy: 0.25, r: 0.28, color: const Color(0xFF1ABC9C)),
      _Orb(cx: 0.5,  cy: 0.6,  r: 0.32, color: const Color(0xFF6C3483)),
      _Orb(cx: 0.1,  cy: 0.75, r: 0.22, color: const Color(0xFF2E86DE)),
      _Orb(cx: 0.9,  cy: 0.8,  r: 0.25, color: const Color(0xFFF39C12)),
    ];

    for (int i = 0; i < orbs.length; i++) {
      final orb = orbs[i];
      final phase = (t + i * 0.2) % 1.0;
      final dy = math.sin(phase * math.pi * 2) * 0.04;
      final cx = orb.cx * size.width;
      final cy = (orb.cy + dy) * size.height;
      final r  = orb.r * size.width * 0.65;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [orb.color.withOpacity(orbOpacity), orb.color.withOpacity(0.0)],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }

    // Subtle dots – white on dark, dark on light
    final dotBase = isDark ? Colors.white : Colors.black;
    final rng = math.Random(42);
    for (int i = 0; i < 35; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final pulse = (math.sin((t * math.pi * 2) + i * 0.7) + 1) / 2;
      final dotOpacity = isDark
          ? 0.04 + pulse * 0.06
          : 0.03 + pulse * 0.04;
      canvas.drawCircle(
        Offset(x, y),
        1.0 + pulse * 1.0,
        Paint()..color = dotBase.withOpacity(dotOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(_TravelBgPainter old) => old.t != t || old.isDark != isDark;
}

class _Orb {
  final double cx, cy, r;
  final Color color;
  const _Orb({required this.cx, required this.cy, required this.r, required this.color});
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASS BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL AI CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SmallAICard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SmallAICard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESTINATION CARD — with custom landmark icons
// ─────────────────────────────────────────────────────────────────────────────
class _DestinationCard extends StatelessWidget {
  final Map<String, dynamic> destination;
  final VoidCallback onTap;

  const _DestinationCard({required this.destination, required this.onTap});

  /// Per-city gradients matching the city's character
  static const Map<String, List<Color>> _gradients = {
    'Lahore':    [Color(0xFF8E44AD), Color(0xFF3498DB)],
    'Hunza':     [Color(0xFF1ABC9C), Color(0xFF2E86DE)],
    'Swat':      [Color(0xFF27AE60), Color(0xFF1ABC9C)],
    'Murree':    [Color(0xFF2980B9), Color(0xFF6DD5FA)],
    'Karachi':   [Color(0xFFF39C12), Color(0xFFE74C3C)],
    'Islamabad': [Color(0xFF2E86DE), Color(0xFF8E44AD)],
    'Skardu':    [Color(0xFF16A085), Color(0xFF2980B9)],
    'Peshawar':  [Color(0xFFD35400), Color(0xFFF39C12)],
  };

  /// Landmark-appropriate icons for each city
  static const Map<String, IconData> _icons = {
    'Lahore':    Icons.account_balance_rounded,  // Badshahi Mosque
    'Hunza':     Icons.terrain_rounded,           // Mountain valleys
    'Swat':      Icons.forest_rounded,            // Green forests
    'Murree':    Icons.ac_unit_rounded,           // Snow-capped
    'Karachi':   Icons.waves_rounded,             // Coastal city
    'Islamabad': Icons.park_rounded,              // Green capital
    'Skardu':    Icons.landscape_rounded,         // K2 landscape
    'Peshawar':  Icons.mosque_rounded,            // Ancient city
  };

  /// Short poetic taglines per city
  static const Map<String, String> _taglines = {
    'Lahore':    'City of Gardens',
    'Hunza':     'Heaven on Earth',
    'Swat':      'Switzerland of Pakistan',
    'Murree':    'Queen of Hills',
    'Karachi':   'City of Lights',
    'Islamabad': 'Green Capital',
    'Skardu':    'Gateway to K2',
    'Peshawar':  'Pearl of Frontier',
  };

  @override
  Widget build(BuildContext context) {
    final name = destination['name'] as String;
    final rating = destination['rating'];
    final gradient = _gradients[name] ?? [AppColors.primary, AppColors.teal];
    final icon = _icons[name] ?? Icons.place_rounded;
    final tagline = _taglines[name] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -18,
              right: -18,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -12,
              left: -12,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Landmark icon container
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25), width: 1.5),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),

                  const Spacer(),

                  // City name
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Tagline
                  Text(
                    tagline,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rating row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            '$rating',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ]),
                      ),
                      const Spacer(),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRIP CARD
// ─────────────────────────────────────────────────────────────────────────────
class _TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const _TripCard({required this.trip, required this.onTap});

  Color get _statusColor {
    switch (trip.status) {
      case 'ongoing':
        return AppColors.success;
      case 'completed':
        return AppColors.textHint;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData get _tripIcon {
    switch (trip.tripType.toLowerCase()) {
      case 'adventure':    return Icons.terrain_rounded;
      case 'beach':        return Icons.waves_rounded;
      case 'mountain':     return Icons.landscape_rounded;
      case 'city tour':    return Icons.location_city_rounded;
      case 'cultural':     return Icons.account_balance_rounded;
      case 'pilgrimage':   return Icons.mosque_rounded;
      case 'honeymoon':    return Icons.favorite_rounded;
      case 'family':       return Icons.family_restroom_rounded;
      case 'business':     return Icons.business_center_rounded;
      default:             return Icons.flight_takeoff_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Trip type icon
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(_tripIcon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.destination,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${AppUtils.formatDate(trip.startDate)} · ${trip.durationDays} days',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MiniTag(
                            label: trip.tripType,
                            color: AppColors.primary),
                        const SizedBox(width: 6),
                        _MiniTag(
                          label: AppUtils.formatCurrency(trip.budget,
                              symbol: trip.currency),
                          color: AppColors.teal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Status indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _statusColor.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.status,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      color: _statusColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _QuickAction {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final Color iconBg;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.iconBg,
  });
}
