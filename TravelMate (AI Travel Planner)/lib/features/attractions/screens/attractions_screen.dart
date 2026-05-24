import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/other_models.dart';
import '../../../services/gemini_service.dart';

class AttractionsScreen extends StatefulWidget {
  final String destination;
  final String tripType;
  final String? tripId;
  const AttractionsScreen({super.key, required this.destination, required this.tripType, this.tripId});

  @override
  State<AttractionsScreen> createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  List<AttractionModel> _attractions = [];
  bool _isLoading = false;
  String _selectedType = 'All';

  final List<String> _types = ['All', 'sightseeing', 'food', 'nature', 'museum', 'adventure', 'religious', 'shopping'];

  @override
  void initState() {
    super.initState();
    _fetchAttractions();
  }

  Future<void> _fetchAttractions({bool forceRefresh = false}) async {
    final cacheKey = 'attractions_${widget.destination}_${widget.tripType}';
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        try {
          final list = jsonDecode(cached) as List;
          setState(() => _attractions = list.map((a) => AttractionModel.fromJson(a)).toList());
          return;
        } catch (_) {}
      }
    }

    setState(() => _isLoading = true);
    try {
      final raw = await GeminiService.getNearbyAttractions(destination: widget.destination, tripType: widget.tripType);
      final list = jsonDecode(raw) as List;
      
      await prefs.setString(cacheKey, raw);
      
      setState(() => _attractions = list.map((a) => AttractionModel.fromJson(a)).toList());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<AttractionModel> get _filtered {
    if (_selectedType == 'All') return _attractions;
    return _attractions.where((a) => a.type == _selectedType).toList();
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: context.surfaceElevated, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.glassBorder)), child: Icon(Icons.arrow_back_ios_new, color: context.textPrimary, size: 16))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Attractions', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      Text(widget.destination, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint)),
                    ])),
                    GestureDetector(onTap: () => _fetchAttractions(forceRefresh: true), child: Container(width: 40, height: 40, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.refresh, color: Colors.white, size: 18))),
                  ],
                ),
              ),

              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _types.length,
                  itemBuilder: (_, i) {
                    final isSelected = _selectedType == _types[i];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = _types[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : context.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? Colors.transparent : context.glassBorder),
                        ),
                        child: Text(_types[i][0].toUpperCase() + _types[i].substring(1), style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : context.textHint)),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _isLoading
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const CircularProgressIndicator(color: AppColors.accent),
                        const SizedBox(height: 16),
                        Text('Discovering attractions with AI...', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: context.textHint)),
                      ]))
                    : _filtered.isEmpty
                        ? EmptyState(icon: Icons.place_outlined, title: 'No attractions', subtitle: 'Try a different filter or refresh', actionLabel: 'Refresh', onAction: () => _fetchAttractions(forceRefresh: true))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) => _AttractionCard(attraction: _filtered[i])
                                .animate()
                                .fadeIn(delay: Duration(milliseconds: i * 70))
                                .slideY(begin: 0.1, end: 0),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttractionCard extends StatefulWidget {
  final AttractionModel attraction;
  const _AttractionCard({required this.attraction});

  @override
  State<_AttractionCard> createState() => _AttractionCardState();
}

class _AttractionCardState extends State<_AttractionCard> {
  bool _expanded = false;

  static const Map<String, Color> _typeColors = {
    'sightseeing': AppColors.primary,
    'food': AppColors.warning,
    'nature': Color(0xFF4CAF50),
    'museum': Color(0xFF9C27B0),
    'adventure': AppColors.error,
    'religious': AppColors.accent,
    'shopping': Color(0xFFFF9800),
  };

  static const Map<String, IconData> _typeIcons = {
    'sightseeing': Icons.camera_alt_outlined,
    'food': Icons.restaurant,
    'nature': Icons.forest,
    'museum': Icons.museum,
    'adventure': Icons.hiking,
    'religious': Icons.mosque,
    'shopping': Icons.shopping_bag_outlined,
  };

  Color get _color => _typeColors[widget.attraction.type] ?? AppColors.primary;
  IconData get _icon => _typeIcons[widget.attraction.type] ?? Icons.place;

  @override
  Widget build(BuildContext context) {
    final a = widget.attraction;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.glassBorder)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: _color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(_icon, color: _color, size: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(a.name, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary))),
                        if (a.mustSee) AppBadge(label: 'Must See', color: AppColors.warning),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.place, size: 12, color: context.textHint),
                        const SizedBox(width: 3),
                        Expanded(child: Text(a.location, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint), overflow: TextOverflow.ellipsis)),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Row(children: List.generate(5, (i) => Icon(Icons.star, size: 11, color: i < a.rating.round() ? Colors.amber : context.glassBorder))),
                        const SizedBox(width: 6),
                        Text(a.rating.toStringAsFixed(1), style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint)),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 11, color: context.textHint),
                        const SizedBox(width: 3),
                        Text(a.duration, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint)),
                      ]),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(a.entryFee == 0 ? 'Free' : '${a.currency} ${a.entryFee.toStringAsFixed(0)}', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: a.entryFee == 0 ? AppColors.success : AppColors.accent)),
                    const SizedBox(height: 4),
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: context.textHint, size: 18),
                  ]),
                ],
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Divider(color: context.glassBorder, height: 1),
                  const SizedBox(height: 10),
                  Text(a.description, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textSecondary, height: 1.5)),
                  const SizedBox(height: 8),
                  Row(children: [
                    AppBadge(label: '🕐 Best: ${a.bestTime}', color: AppColors.primary),
                    const SizedBox(width: 6),
                    AppBadge(label: a.type, color: _color),
                  ]),
                  if (a.tips.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Expanded(child: Text(a.tips, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint, height: 1.4))),
                    ]),
                  ],
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
