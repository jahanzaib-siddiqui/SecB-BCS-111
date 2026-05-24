import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/trip_model.dart';
import '../../../services/supabase_service.dart';
import 'plan_trip_screen.dart';
import 'trip_detail_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<TripModel> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadTrips();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getTrips();
      setState(() => _trips = data.map((t) => TripModel.fromJson(t)).toList());
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TripModel> _filter(String status) {
    if (status == 'upcoming') return _trips.where((t) => t.startDate.isAfter(DateTime.now())).toList();
    if (status == 'ongoing') return _trips.where((t) => t.startDate.isBefore(DateTime.now()) && t.endDate.isAfter(DateTime.now())).toList();
    return _trips.where((t) => t.endDate.isBefore(DateTime.now())).toList();
  }

  Future<void> _deleteTrip(TripModel trip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Delete "${trip.destination}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true && trip.id != null) {
      await SupabaseService.deleteTrip(trip.id!);
      _loadTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Trips', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanTripScreen())).then((_) => _loadTrips()),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(color: context.surfaceElevated, borderRadius: BorderRadius.circular(14)),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: context.textHint,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12),
                    tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Ongoing'), Tab(text: 'Past')],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                    : TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _buildTripList(_filter('upcoming')),
                          _buildTripList(_filter('ongoing')),
                          _buildTripList(_filter('past')),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripList(List<TripModel> trips) {
    if (trips.isEmpty) {
      return EmptyState(
        icon: Icons.luggage_outlined,
        title: 'No trips here',
        subtitle: 'Plan a new trip to see it here',
        actionLabel: 'Plan a Trip',
        onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanTripScreen())).then((_) => _loadTrips()),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: trips.length,
        itemBuilder: (context, i) {
          final trip = trips[i];
          return Dismissible(
            key: Key(trip.id ?? i.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
            ),
            confirmDismiss: (_) async {
              await _deleteTrip(trip);
              return false;
            },
            child: _TripCard(
              trip: trip,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip))).then((_) => _loadTrips()),
            ).animate().fadeIn(delay: Duration(milliseconds: i * 100)).slideY(begin: 0.1, end: 0),
          );
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  const _TripCard({required this.trip, required this.onTap});

  static const Map<String, List<Color>> _typeGradients = {
    'Cultural':   [Color(0xFF8E44AD), Color(0xFF3498DB)],
    'Adventure':  [Color(0xFF1ABC9C), Color(0xFF148F77)],
    'Business':   [Color(0xFF2E86DE), Color(0xFF1A5276)],
    'Beach':      [Color(0xFFF39C12), Color(0xFFE74C3C)],
    'Religious':  [Color(0xFF6C3483), Color(0xFF2E86DE)],
    'Nature':     [Color(0xFF27AE60), Color(0xFF1ABC9C)],
    'Food':       [Color(0xFFD35400), Color(0xFFF39C12)],
    'Mountain':   [Color(0xFF16A085), Color(0xFF2980B9)],
    'City Tour':  [Color(0xFF2980B9), Color(0xFF6DD5FA)],
    'Pilgrimage': [Color(0xFF6C3483), Color(0xFF8E44AD)],
    'Honeymoon':  [Color(0xFFE74C3C), Color(0xFF8E44AD)],
    'Family':     [Color(0xFF27AE60), Color(0xFF2E86DE)],
    'Solo':       [Color(0xFF2E86DE), Color(0xFF1ABC9C)],
  };
  static const Map<String, IconData> _typeIcons = {
    'Cultural':   Icons.account_balance_rounded,
    'Adventure':  Icons.hiking_rounded,
    'Business':   Icons.business_center_rounded,
    'Beach':      Icons.beach_access_rounded,
    'Religious':  Icons.mosque_rounded,
    'Nature':     Icons.forest_rounded,
    'Food':       Icons.restaurant_rounded,
  };

  Color get _statusColor {
    switch (trip.status) {
      case 'ongoing':   return AppColors.success;
      case 'completed': return AppColors.textHint;
      case 'cancelled': return AppColors.error;
      default:          return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = trip.startDate.difference(DateTime.now()).inDays;
    final gradientColors = _typeGradients[trip.tripType] ?? [AppColors.primary, AppColors.primaryDark];

    final typeIcon = _typeIcons[trip.tripType] ?? Icons.flight_takeoff_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.glassBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            // ── Hero Banner ──
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Positioned(top: -25, right: -25, child: Container(width: 110, height: 110, decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle))),
                  Positioned(bottom: -15, left: 80, child: Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Spacer(),
                              Text(trip.destination, style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                              const SizedBox(height: 2),
                              Row(children: [
                                const Icon(Icons.calendar_today_rounded, size: 11, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text('${AppUtils.formatDate(trip.startDate)} → ${AppUtils.formatDate(trip.endDate)}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white70)),
                              ]),
                            ],
                          ),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
                              const SizedBox(width: 5),
                              Text(AppUtils.capitalize(trip.status), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                            ]),
                          ),
                          const Spacer(),
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                            child: Icon(typeIcon, color: Colors.white, size: 24),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Info Row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  _Chip(icon: Icons.nights_stay_rounded, label: '${trip.durationDays}N', color: AppColors.primary),
                  const SizedBox(width: 8),
                  _Chip(icon: Icons.group_rounded, label: '${trip.travelers}', color: AppColors.accent),
                  const SizedBox(width: 8),
                  _Chip(icon: Icons.account_balance_wallet_rounded, label: AppUtils.formatCurrency(trip.budget, symbol: trip.currency), color: AppColors.warning),
                  const Spacer(),
                  if (daysLeft > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      child: Text('In $daysLeft days', style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                ],
              ),
            ),

            // ── Budget Progress ──
            if (trip.spentAmount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Spent ${AppUtils.formatCurrency(trip.spentAmount, symbol: trip.currency)} of ${AppUtils.formatCurrency(trip.budget, symbol: trip.currency)}',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: context.textHint)),
                    Text(AppUtils.formatPercent(trip.spentPercentage),
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700, color: trip.spentPercentage > 0.9 ? AppColors.error : AppColors.accent)),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: trip.spentPercentage.clamp(0, 1),
                      backgroundColor: context.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(trip.spentPercentage > 0.9 ? AppColors.error : AppColors.accent),
                      minHeight: 5,
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
