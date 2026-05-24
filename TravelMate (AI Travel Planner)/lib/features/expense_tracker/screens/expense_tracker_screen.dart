import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/trip_model.dart';
import '../../../models/other_models.dart';
import '../../../services/supabase_service.dart';


class ExpenseTrackerScreen extends StatefulWidget {
  final TripModel trip;
  const ExpenseTrackerScreen({super.key, required this.trip});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    if (widget.trip.id == null) return;
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getExpenses(widget.trip.id!);
      setState(() => _expenses = data.map((e) => ExpenseModel.fromJson(e)).toList());
    } catch (_) {}
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  double get _totalSpent => _expenses.fold(0, (sum, e) => sum + e.amount);

  Map<String, double> get _categoryTotals {
    final Map<String, double> totals = {};
    for (final e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  void _showAddExpenseDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String category = AppConstants.expenseCategories.first;
    DateTime date = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Expense', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  GestureDetector(onTap: () => Navigator.pop(ctx), child: Icon(Icons.close, color: context.textHint)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleCtrl,
                style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins'),
                decoration: InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.label_outline, color: context.textHint)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  labelText: 'Amount (${widget.trip.currency})',
                  prefixIcon: Icon(Icons.attach_money, color: context.textHint),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                dropdownColor: Theme.of(context).colorScheme.surface,
                decoration: InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined, color: context.textHint)),
                style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins', fontSize: 14),
                items: AppConstants.expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setModalState(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteCtrl,
                style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins'),
                decoration: InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.notes, color: context.textHint)),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Add Expense',
                onPressed: () async {
                  if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  try {
                    await SupabaseService.addExpense({
                      'trip_id': widget.trip.id,
                      'title': titleCtrl.text.trim(),
                      'amount': double.parse(amountCtrl.text),
                      'category': category,
                      'currency': widget.trip.currency,
                      'date': date.toIso8601String(),
                      'note': noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                    });
                    // Update spent amount on trip
                    final newSpent = _totalSpent + double.parse(amountCtrl.text);
                    if (widget.trip.id != null) {
                      await SupabaseService.updateTrip(widget.trip.id!, {'spent_amount': newSpent});
                    }
                    _loadExpenses();
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.trip.budget;
    final spent = _totalSpent;
    final remaining = budget - spent;
    final percentage = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final categoryTotals = _categoryTotals;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: context.surfaceElevated, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.glassBorder)), child: Icon(Icons.arrow_back_ios_new, color: context.textPrimary, size: 16))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Expense Tracker', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
                        Text(widget.trip.destination, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: _showAddExpenseDialog,
                      child: Container(width: 40, height: 40, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.add, color: Colors.white)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // Budget Summary Card
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const Text('Total Budget', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                                      Text(AppUtils.formatCurrency(budget, symbol: widget.trip.currency), style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                                    ]),
                                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                      const Text('Remaining', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                                      Text(AppUtils.formatCurrency(remaining, symbol: widget.trip.currency), style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800, color: remaining < 0 ? const Color(0xFFFF5252) : Colors.white)),
                                    ]),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: percentage,
                                    backgroundColor: Colors.white24,
                                    valueColor: AlwaysStoppedAnimation<Color>(percentage > 0.9 ? const Color(0xFFFF5252) : Colors.white),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('Spent: ${AppUtils.formatCurrency(spent, symbol: widget.trip.currency)}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                                  Text('${(percentage * 100).toStringAsFixed(1)}% used', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                                ]),
                              ],
                            ),
                          ).animate().fadeIn().slideY(begin: -0.1, end: 0),

                          const SizedBox(height: 20),

                          // Pie Chart
                          if (categoryTotals.isNotEmpty) ...[
                            Text('Spending by Category', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.glassBorder)),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    child: PieChart(PieChartData(
                                      sections: categoryTotals.entries.toList().asMap().entries.map((entry) {
                                        final i = entry.key;
                                        final cat = entry.value;
                                        final percent = spent > 0 ? (cat.value / spent * 100) : 0;
                                        return PieChartSectionData(
                                          value: cat.value,
                                          color: AppColors.categoryColors[i % AppColors.categoryColors.length],
                                          title: '${percent.toStringAsFixed(0)}%',
                                          radius: 60,
                                          titleStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                        );
                                      }).toList(),
                                      sectionsSpace: 3,
                                      centerSpaceRadius: 35,
                                    )),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 6,
                                    children: categoryTotals.entries.toList().asMap().entries.map((entry) {
                                      final i = entry.key;
                                      final cat = entry.value;
                                      final color = AppColors.categoryColors[i % AppColors.categoryColors.length];
                                      return Row(mainAxisSize: MainAxisSize.min, children: [
                                        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                        const SizedBox(width: 4),
                                        Text('${cat.key}: ${AppUtils.formatCurrency(cat.value, symbol: '')}', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textSecondary)),
                                      ]);
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Expense List
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('Transactions', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                            Text('${_expenses.length} items', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint)),
                          ]),
                          const SizedBox(height: 12),

                          if (_expenses.isEmpty)
                            EmptyState(icon: Icons.receipt_long_outlined, title: 'No expenses yet', subtitle: 'Tap + to add your first expense', actionLabel: 'Add Expense', onAction: _showAddExpenseDialog)
                          else
                            ..._expenses.asMap().entries.map((e) => _ExpenseTile(
                              expense: e.value,
                              onDelete: () async {
                                if (e.value.id != null) {
                                  await SupabaseService.deleteExpense(e.value.id!);
                                  _loadExpenses();
                                }
                              },
                            ).animate().fadeIn(delay: Duration(milliseconds: e.key * 60))),

                          const SizedBox(height: 60),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onDelete;
  const _ExpenseTile({required this.expense, required this.onDelete});

  static const Map<String, IconData> _catIcons = {
    'Accommodation': Icons.hotel,
    'Food': Icons.restaurant,
    'Transport': Icons.directions_bus,
    'Activities': Icons.local_activity,
    'Shopping': Icons.shopping_bag,
    'Healthcare': Icons.medical_services,
    'Miscellaneous': Icons.more_horiz,
  };

  int get _catIndex => AppConstants.expenseCategories.indexOf(expense.category);
  Color get _color => AppColors.categoryColors[_catIndex.clamp(0, AppColors.categoryColors.length - 1)];

  IconData get _icon => _catIcons[expense.category] ?? Icons.receipt;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id ?? expense.title),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: context.glassBorder)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: _color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(_icon, size: 18, color: _color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(expense.title, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
                  Text('${expense.category} · ${AppUtils.formatDateShort(expense.date)}', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint)),
                ]),
              ),
              Text('-${AppUtils.formatCurrency(expense.amount, symbol: expense.currency)}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}
