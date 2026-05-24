import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/other_models.dart';
import '../../../services/gemini_service.dart';
import '../../../services/supabase_service.dart';

class HotelsScreen extends StatefulWidget {
  final String destination;
  final double? budget;
  final String? currency;
  final String? tripId;

  const HotelsScreen({super.key, required this.destination, this.budget, this.currency, this.tripId});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  List<HotelModel> _hotels = [];
  bool _isLoading = false;
  String _selectedType = 'All';
  double _filterBudget = 0;
  final List<String> _typeFilters = ['All', 'Budget Hotel', '3-Star Hotel', '4-Star Hotel', '5-Star Hotel', 'Hostel', 'Resort'];

  @override
  void initState() {
    super.initState();
    _filterBudget = widget.budget ?? 5000;
    _fetchHotels();
  }

  Future<void> _fetchHotels({bool forceRefresh = false}) async {
    final cacheKey = 'hotels_${widget.destination}_${_filterBudget}_${_selectedType}';
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        try {
          final list = jsonDecode(cached) as List;
          setState(() => _hotels = list.map((h) => HotelModel.fromJson(h)).toList());
          return;
        } catch (_) {}
      }
    }

    setState(() => _isLoading = true);
    try {
      final raw = await GeminiService.getHotelRecommendations(
        destination: widget.destination,
        budgetPerNight: _filterBudget,
        currency: widget.currency ?? 'PKR',
        accommodationType: _selectedType == 'All' ? '3-Star Hotel' : _selectedType,
        guests: 2,
      );
      final list = jsonDecode(raw) as List;
      
      await prefs.setString(cacheKey, raw);
      
      setState(() => _hotels = list.map((h) => HotelModel.fromJson(h)).toList());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(width: 40, height: 40, decoration: BoxDecoration(color: context.surfaceElevated, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.glassBorder)), child: Icon(Icons.arrow_back_ios_new, color: context.textPrimary, size: 16)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Hotels', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
                        Text(widget.destination, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () => _fetchHotels(forceRefresh: true),
                      child: Container(width: 40, height: 40, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.refresh, color: Colors.white, size: 18)),
                    ),
                  ],
                ),
              ),

              // Filters
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _typeFilters.length,
                  itemBuilder: (_, i) {
                    final isSelected = _selectedType == _typeFilters[i];
                    return GestureDetector(
                      onTap: () { setState(() => _selectedType = _typeFilters[i]); _fetchHotels(); },
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
                        child: Text(_typeFilters[i], style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : context.textHint)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const CircularProgressIndicator(color: AppColors.accent),
                        const SizedBox(height: 16),
                        Text('Finding best hotels with AI...', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: context.textHint)),
                      ]))
                    : _hotels.isEmpty
                        ? EmptyState(icon: Icons.hotel_outlined, title: 'No hotels found', subtitle: 'Try refreshing', actionLabel: 'Refresh', onAction: () => _fetchHotels(forceRefresh: true))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _hotels.length,
                            itemBuilder: (context, i) => _HotelCard(
                              hotel: _hotels[i],
                              currency: widget.currency ?? 'PKR',
                              onSave: widget.tripId != null ? () => _saveHotel(_hotels[i], i) : null,
                            ).animate().fadeIn(delay: Duration(milliseconds: i * 80)).slideY(begin: 0.1, end: 0),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveHotel(HotelModel hotel, int index) async {
    try {
      await SupabaseService.saveHotel({'trip_id': widget.tripId, 'name': hotel.name, 'area': hotel.area, 'price_per_night': hotel.pricePerNight, 'rating': hotel.rating, 'description': hotel.description});
      setState(() => _hotels[index].isSaved = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hotel saved!'), backgroundColor: AppColors.success));
    } catch (_) {}
  }
}

class _HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final String currency;
  final VoidCallback? onSave;
  const _HotelCard({required this.hotel, required this.currency, this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: context.glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel header
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary.withOpacity(0.6)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.hotel, color: Colors.white, size: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(hotel.name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(hotel.area, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white70)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < hotel.rating.round() ? Colors.amber : Colors.white30))),
                  const SizedBox(height: 4),
                  Text('${hotel.rating.toStringAsFixed(1)} / 5', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white70)),
                ]),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppUtils.formatCurrency(hotel.pricePerNight, symbol: currency), style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent)),
                  Text('per night', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint)),
                ],
              ),
              const SizedBox(height: 8),
              Text(hotel.description, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textSecondary, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),

              // Amenities
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: hotel.amenities.take(4).map((a) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: context.surfaceElevated, borderRadius: BorderRadius.circular(6)),
                  child: Text(a, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: context.textSecondary)),
                )).toList(),
              ),

              const SizedBox(height: 10),
              // Pros
              if (hotel.pros.isNotEmpty) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.thumb_up_outlined, size: 14, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(child: Text(hotel.pros.first, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.success))),
                ]),
              ],

              const SizedBox(height: 8),
              Text('📌 ${hotel.bookingTip}', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint, height: 1.4)),

              if (onSave != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: hotel.isSaved ? null : onSave,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: hotel.isSaved ? AppColors.success.withOpacity(0.15) : AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: hotel.isSaved ? AppColors.success.withOpacity(0.3) : AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(hotel.isSaved ? Icons.bookmark : Icons.bookmark_border, size: 16, color: hotel.isSaved ? AppColors.success : AppColors.accent),
                      const SizedBox(width: 6),
                      Text(hotel.isSaved ? 'Saved' : 'Save to Trip', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: hotel.isSaved ? AppColors.success : AppColors.accent)),
                    ]),
                  ),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}
