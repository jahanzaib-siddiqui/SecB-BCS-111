import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/trip_model.dart';
import '../../../services/supabase_service.dart';
import 'itinerary_screen.dart';
import '../../hotels/screens/hotels_screen.dart';
import '../../attractions/screens/attractions_screen.dart';
import '../../expense_tracker/screens/expense_tracker_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final TripModel trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late TripModel _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  Future<void> _updateStatus(String status) async {
    if (_trip.id == null) return;
    await SupabaseService.updateTrip(_trip.id!, {'status': status});
    setState(() => _trip = _trip.copyWith(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -30, right: -30, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle))),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppBadge(label: _trip.tripType),
                              const SizedBox(height: 8),
                              Text(_trip.destination, style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                              Text('${AppUtils.formatDate(_trip.startDate)} → ${AppUtils.formatDate(_trip.endDate)}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                      children: [
                        StatCard(value: '${_trip.durationDays}', label: 'Days', icon: Icons.calendar_today, color: AppColors.primary),
                        StatCard(value: '${_trip.travelers}', label: 'Travelers', icon: Icons.people, color: AppColors.accent),
                        StatCard(value: AppUtils.formatCurrency(_trip.budget, symbol: _trip.currency), label: 'Total Budget', icon: Icons.account_balance_wallet, color: AppColors.warning),
                        StatCard(value: AppUtils.formatCurrency(_trip.remainingBudget, symbol: _trip.currency), label: 'Remaining', icon: Icons.savings, color: _trip.remainingBudget < 0 ? AppColors.error : AppColors.success),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Budget Progress
                    if (_trip.spentAmount > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.glassBorder)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Budget Usage', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
                                Text(AppUtils.formatPercent(_trip.spentPercentage), style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: _trip.spentPercentage > 0.9 ? AppColors.error : AppColors.accent)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _trip.spentPercentage.clamp(0.0, 1.0),
                                backgroundColor: context.surfaceElevated,
                                valueColor: AlwaysStoppedAnimation<Color>(_trip.spentPercentage > 0.9 ? AppColors.error : AppColors.accent),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Trip Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.glassBorder)),
                      child: Column(
                        children: [
                          InfoRow(icon: Icons.hotel, label: 'Accommodation', value: _trip.accommodation, iconColor: AppColors.primary),
                          Divider(color: context.glassBorder),
                          InfoRow(icon: Icons.directions_bus, label: 'Travel Mode', value: _trip.travelMode, iconColor: AppColors.accent),
                          Divider(color: context.glassBorder),
                          InfoRow(icon: Icons.info_outline, label: 'Status', value: _trip.status.toUpperCase(), iconColor: AppColors.warning),
                        ],
                      ),
                    ),

                    if (_trip.aiSummary != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text('AI Summary', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ]),
                            const SizedBox(height: 8),
                            Text(_trip.aiSummary!, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textSecondary, height: 1.5)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Action Buttons
                    Text('Actions', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary)),
                    const SizedBox(height: 12),

                    _ActionButton(icon: Icons.map_rounded, label: 'View AI Itinerary', color: AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItineraryScreen(trip: _trip)))),
                    const SizedBox(height: 10),
                    _ActionButton(icon: Icons.hotel_rounded, label: 'Hotel Recommendations', color: AppColors.accent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HotelsScreen(destination: _trip.destination, budget: _trip.budget / _trip.durationDays, currency: _trip.currency)))),
                    const SizedBox(height: 10),
                    _ActionButton(icon: Icons.place_rounded, label: 'Nearby Attractions', color: AppColors.warning, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttractionsScreen(destination: _trip.destination, tripType: _trip.tripType)))),
                    const SizedBox(height: 10),
                    _ActionButton(icon: Icons.receipt_long_rounded, label: 'Track Expenses', color: AppColors.error, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseTrackerScreen(trip: _trip)))),

                    const SizedBox(height: 24),

                    // Status Update
                    SectionHeader(title: 'Update Status'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: ['planning', 'ongoing', 'completed', 'cancelled'].map((status) {
                        final isSelected = _trip.status == status;
                        return GestureDetector(
                          onTap: () => _updateStatus(status),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent.withOpacity(0.2) : context.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppColors.accent : context.glassBorder),
                            ),
                            child: Text(AppUtils.capitalize(status), style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? AppColors.accent : context.textHint)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
