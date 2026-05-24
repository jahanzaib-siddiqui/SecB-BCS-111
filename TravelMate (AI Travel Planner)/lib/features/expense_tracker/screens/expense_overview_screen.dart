import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/app_utils.dart';
import '../../../services/supabase_service.dart';
import '../../../models/trip_model.dart';
import 'expense_tracker_screen.dart';


class ExpenseOverviewScreen extends StatefulWidget {
  const ExpenseOverviewScreen({super.key});

  @override
  State<ExpenseOverviewScreen> createState() => _ExpenseOverviewScreenState();
}

class _ExpenseOverviewScreenState extends State<ExpenseOverviewScreen> {
  List<TripModel> _trips = [];
  bool _isLoading = true;
  double _totalBudget = 0;
  double _totalSpent = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getTrips();
      final trips = data.map((t) => TripModel.fromJson(t)).toList();
      final budget = trips.fold(0.0, (s, t) => s + t.budget);
      final spent = trips.fold(0.0, (s, t) => s + t.spentAmount);
      setState(() { _trips = trips; _totalBudget = budget; _totalSpent = spent; });
    } catch (_) {}
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.accent,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text('Expense Overview', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary)),
                      const SizedBox(height: 20),

                      // Summary Cards
                      Row(
                        children: [
                          Expanded(child: StatCard(value: AppUtils.formatCurrency(_totalBudget, symbol: 'PKR'), label: 'Total Budget', icon: Icons.account_balance_wallet, color: AppColors.primary)),
                          const SizedBox(width: 12),
                          Expanded(child: StatCard(value: AppUtils.formatCurrency(_totalSpent, symbol: 'PKR'), label: 'Total Spent', icon: Icons.money_off, color: AppColors.error)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: StatCard(value: AppUtils.formatCurrency(_totalBudget - _totalSpent, symbol: 'PKR'), label: 'Remaining', icon: Icons.savings, color: AppColors.success)),
                          const SizedBox(width: 12),
                          Expanded(child: StatCard(value: '${_trips.length}', label: 'Total Trips', icon: Icons.luggage, color: AppColors.accent)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (_trips.isEmpty)
                        const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'No expense data', subtitle: 'Plan a trip and track expenses to see them here')
                      else ...[
                        Text('Budget by Trip', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                        const SizedBox(height: 12),
                        ..._trips.where((t) => t.budget > 0).map((trip) => _TripBudgetCard(
                              trip: trip,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExpenseTrackerScreen(trip: trip),
                                  ),
                                ).then((_) => _loadData());
                              },
                            )),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _TripBudgetCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  const _TripBudgetCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = trip.budget > 0 ? (trip.spentAmount / trip.budget).clamp(0.0, 1.0) : 0.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.glassBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(trip.destination, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary), overflow: TextOverflow.ellipsis)),
              AppBadge(label: trip.status, color: trip.status == 'ongoing' ? AppColors.success : AppColors.primary),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Spent: ${AppUtils.formatCurrency(trip.spentAmount, symbol: trip.currency)}', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint)),
              Text('Budget: ${AppUtils.formatCurrency(trip.budget, symbol: trip.currency)}', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: context.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(pct > 0.9 ? AppColors.error : AppColors.accent),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
