import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/trip_model.dart';
import '../../../services/gemini_service.dart';
import '../../../services/supabase_service.dart';

class ItineraryScreen extends StatefulWidget {
  final TripModel trip;
  final bool autoGenerate;
  const ItineraryScreen({super.key, required this.trip, this.autoGenerate = false});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  Map<String, dynamic>? _itineraryData;
  bool _isLoading = false;
  String _loadingMsg = 'Generating your personalized itinerary...';
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    if (widget.trip.id == null) {
      if (widget.autoGenerate) _generateItinerary();
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMsg = 'Loading your itinerary...';
    });

    try {
      final days = await SupabaseService.getItinerary(widget.trip.id!);
      if (days.isNotEmpty) {
        // Reconstruct JSON map structure from relational data
        final reconstructed = {
          'summary': widget.trip.aiSummary ?? 'Your AI-generated itinerary.',
          'budget_breakdown': widget.trip.budgetBreakdown,
          'tips': [],
          'days': days.map((d) {
            return {
              'day': d['day_number'],
              'title': d['title'] ?? 'Day ${d['day_number']}',
              'activities': d['itinerary_activities'] ?? [],
            };
          }).toList(),
        };
        
        setState(() => _itineraryData = reconstructed);
      } else if (widget.autoGenerate) {
        await _generateItinerary();
      }
    } catch (e) {
      if (widget.autoGenerate) {
        await _generateItinerary();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateItinerary() async {
    setState(() {
      _isLoading = true;
      _loadingMsg = '✨ AI is crafting your perfect itinerary...';
    });

    try {
      final days = widget.trip.durationDays;
      final raw = await GeminiService.generateItinerary(
        destination: widget.trip.destination,
        days: days,
        budget: widget.trip.budget,
        currency: widget.trip.currency,
        tripType: widget.trip.tripType,
        accommodation: widget.trip.accommodation,
        travelMode: widget.trip.travelMode,
        travelers: widget.trip.travelers,
        preferences: widget.trip.preferences,
      );

      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      setState(() => _itineraryData = parsed);

      // Save to Supabase
      if (widget.trip.id != null) {
        final daysList = (parsed['days'] as List?)
            ?.map((d) => {
                  'day_number': d['day'],
                  'date': widget.trip.startDate
                      .add(Duration(days: (d['day'] as int) - 1))
                      .toIso8601String(),
                  'title': d['title'],
                  'activities': d['activities'],
                })
            .toList() ?? [];

        await SupabaseService.saveItinerary(widget.trip.id!, daysList);

        // Update trip with AI summary
        await SupabaseService.updateTrip(widget.trip.id!, {
          'ai_summary': parsed['summary'],
          'budget_breakdown': jsonEncode(parsed['budget_breakdown']),
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generation failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              _buildHeader(),
              if (_isLoading) _buildLoadingView(),
              if (!_isLoading && _itineraryData == null) _buildEmptyView(),
              if (!_isLoading && _itineraryData != null) Expanded(child: _buildItineraryContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: context.surfaceElevated, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.glassBorder)),
              child: Icon(Icons.arrow_back_ios_new, color: context.textPrimary, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.trip.destination, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
                Text('${widget.trip.durationDays} days · ${AppUtils.formatCurrency(widget.trip.budget, symbol: widget.trip.currency)}', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint)),
              ],
            ),
          ),
          if (!_isLoading)
            GestureDetector(
              onTap: _generateItinerary,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1200.ms, color: AppColors.accent),
            const SizedBox(height: 24),
            Text(_loadingMsg, style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('This may take a moment...', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: context.textHint)),
            const SizedBox(height: 24),
            SizedBox(width: 200, child: LinearProgressIndicator(color: AppColors.accent, backgroundColor: context.surfaceElevated)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Expanded(
      child: EmptyState(
        icon: Icons.map_outlined,
        title: 'No Itinerary Yet',
        subtitle: 'Tap the magic wand to generate your AI-powered itinerary',
        actionLabel: 'Generate Now ✨',
        onAction: _generateItinerary,
      ),
    );
  }

  Widget _buildItineraryContent() {
    final days = (_itineraryData!['days'] as List?) ?? [];
    final summary = _itineraryData!['summary'] as String? ?? '';
    final tips = (_itineraryData!['tips'] as List?)?.cast<String>() ?? [];
    final budgetBreakdown = _itineraryData!['budget_breakdown'] as Map<String, dynamic>?;

    return Column(
      children: [
        // Summary Card
        if (summary.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(summary, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70, height: 1.5))),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.2, end: 0),

        // Day Tabs
        if (days.isNotEmpty) ...[
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: days.length,
              itemBuilder: (context, i) {
                final isSelected = _selectedDay == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : context.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.transparent : context.glassBorder),
                    ),
                    child: Text('Day ${i + 1}', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : context.textHint)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Day Content
        Expanded(
          child: days.isEmpty
              ? Center(child: Text('No days found', style: TextStyle(color: context.textHint)))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildDayCard(days[_selectedDay]),
                    if (budgetBreakdown != null) _buildBudgetBreakdown(budgetBreakdown),
                    if (tips.isNotEmpty) _buildTipsCard(tips),
                    const SizedBox(height: 20),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    final activities = (day['activities'] as List?) ?? [];
    final meals = day['meals'] as Map<String, dynamic>?;
    final accommodation = day['accommodation'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('${day['day']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day['title'] ?? '', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  if (day['theme'] != null) Text(day['theme'], style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...activities.asMap().entries.map((e) => _ActivityTile(activity: e.value, index: e.key)),
        if (meals != null) _buildMealsCard(meals),
        if (accommodation != null) _buildAccommodationCard(accommodation),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMealsCard(Map<String, dynamic> meals) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.restaurant, size: 16, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Meals', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 10),
          ...['breakfast', 'lunch', 'dinner'].map((meal) {
            final m = meals[meal] as Map<String, dynamic>?;
            if (m == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text('${AppUtils.capitalize(meal)}: ', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint)),
                  Expanded(child: Text(m['place'] ?? '', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textPrimary))),
                  Text(AppUtils.formatCurrency((m['estimated_cost'] as num?)?.toDouble() ?? 0, symbol: widget.trip.currency), style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.accent)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAccommodationCard(Map<String, dynamic> acc) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.hotel, size: 18, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acc['name'] ?? '', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
                Text(acc['area'] ?? '', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint)),
              ],
            ),
          ),
          Text(AppUtils.formatCurrency((acc['estimated_cost'] as num?)?.toDouble() ?? 0, symbol: widget.trip.currency), style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
        ],
      ),
    );
  }

  Widget _buildBudgetBreakdown(Map<String, dynamic> breakdown) {
    final categories = {
      'Accommodation': Icons.hotel,
      'Food': Icons.restaurant,
      'Transport': Icons.directions_bus,
      'Activities': Icons.local_activity,
      'Miscellaneous': Icons.more_horiz,
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget Breakdown', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
          const SizedBox(height: 12),
          ...categories.entries.map((e) {
            final key = e.key.toLowerCase();
            final amount = (breakdown[key] as num?)?.toDouble() ?? 0;
            final total = (breakdown['total'] as num?)?.toDouble() ?? 1;
            final percent = total > 0 ? amount / total : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(e.value, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.key, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: context.textPrimary))),
                      Text(AppUtils.formatCurrency(amount, symbol: widget.trip.currency), style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent.toDouble(),
                      backgroundColor: context.surfaceElevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTipsCard(List<String> tips) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 18),
            SizedBox(width: 8),
            Text('AI Travel Tips', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning)),
          ]),
          const SizedBox(height: 10),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: TextStyle(color: AppColors.warning, fontFamily: 'Poppins')),
                Expanded(child: Text(tip, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textSecondary, height: 1.5))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatefulWidget {
  final Map<String, dynamic> activity;
  final int index;
  const _ActivityTile({required this.activity, required this.index});

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile> {
  bool _expanded = false;

  Color get _typeColor {
    switch (widget.activity['type']) {
      case 'sightseeing': return AppColors.primary;
      case 'food': return AppColors.warning;
      case 'transport': return AppColors.accent;
      case 'accommodation': return const Color(0xFF9C27B0);
      default: return AppColors.info;
    }
  }

  IconData get _typeIcon {
    switch (widget.activity['type']) {
      case 'sightseeing': return Icons.camera_alt_outlined;
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_bus;
      case 'accommodation': return Icons.hotel;
      default: return Icons.local_activity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: context.glassBorder)),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: _typeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(_typeIcon, size: 18, color: _typeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.activity['title'] ?? '', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 11, color: context.textHint),
                            const SizedBox(width: 3),
                            Text('${widget.activity['time'] ?? ''} · ${widget.activity['duration'] ?? ''}', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if ((widget.activity['cost'] as num?) != null && (widget.activity['cost'] as num) > 0)
                    Text(AppUtils.formatCurrency((widget.activity['cost'] as num).toDouble(), symbol: ''), style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: context.textHint, size: 18),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: context.glassBorder, height: 1),
                  const SizedBox(height: 8),
                  if (widget.activity['description'] != null) Text(widget.activity['description'], style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textSecondary, height: 1.5)),
                  if (widget.activity['location'] != null) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.place, size: 13, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(widget.activity['location'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.accent)),
                    ]),
                  ],
                  if (widget.activity['tips'] != null) ...[
                    const SizedBox(height: 6),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.lightbulb_outline, size: 13, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Expanded(child: Text(widget.activity['tips'], style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint, height: 1.4))),
                    ]),
                  ],
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.index * 80));
  }
}
