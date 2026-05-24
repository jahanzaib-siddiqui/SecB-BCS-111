import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/trip_model.dart';
import '../../../services/supabase_service.dart';
import 'itinerary_screen.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  // Form data
  final _destinationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _preferencesCtrl = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 10));
  String _currency = 'PKR';
  String _tripType = 'Cultural';
  String _accommodation = 'Budget Hotel';
  String _travelMode = 'Bus';
  int _travelers = 2;

  bool _isGenerating = false;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _generateTrip();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.accent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 3));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _generateTrip() async {
    if (_destinationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_budgetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your budget'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final budget = double.parse(_budgetCtrl.text.replaceAll(',', ''));
      // Create trip in Supabase
      final userId = SupabaseService.currentUserId ?? '';
      final trip = TripModel(
        userId: userId,
        destination: _destinationCtrl.text.trim(),
        destinationCountry: 'Pakistan',
        startDate: _startDate,
        endDate: _endDate,
        budget: budget,
        currency: _currency,
        tripType: _tripType,
        accommodation: _accommodation,
        travelMode: _travelMode,
        travelers: _travelers,
        preferences: _preferencesCtrl.text.isNotEmpty ? _preferencesCtrl.text : null,
        status: 'planning',
      );

      final savedTrip = await SupabaseService.createTrip(trip.toJson());
      final savedTripModel = TripModel.fromJson(savedTrip);

      if (!mounted) return;

      // Navigate to itinerary screen with generation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ItineraryScreen(trip: savedTripModel, autoGenerate: true),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Destination', 'Dates & Budget', 'Preferences'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: context.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.glassBorder),
                        ),
                        child: Icon(Icons.arrow_back_ios_new, color: context.textPrimary, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Plan New Trip', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
                          Text('Step ${_currentPage + 1} of 3: ${steps[_currentPage]}', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: List.generate(3, (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: i <= _currentPage ? AppColors.accent : context.surfaceElevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
              ),

              const SizedBox(height: 20),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: _prevPage,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            side: BorderSide(color: context.glassBorder),
                          ),
                          child: Text('Back', style: TextStyle(fontFamily: 'Poppins', color: context.textSecondary)),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        label: _currentPage < 2 ? 'Continue' : 'Generate Trip ✨',
                        isLoading: _isGenerating,
                        onPressed: _nextPage,
                        icon: _currentPage < 2 ? null : const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where are you\nheaded? 🌍', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _destinationCtrl,
            style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              labelText: 'Destination City / Country',
              hintText: 'e.g. Hunza, Lahore, Dubai...',
              prefixIcon: Icon(Icons.search, color: context.textHint),
            ),
          ),
          const SizedBox(height: 20),
          Text('Popular Destinations', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.popularDestinations.map((d) {
              return GestureDetector(
                onTap: () => setState(() => _destinationCtrl.text = d['name']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.glassBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(d['name']!, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: context.textPrimary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Trip Type', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.tripTypes.map((type) {
              final isSelected = _tripType == type;
              return GestureDetector(
                onTap: () => setState(() => _tripType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.2) : context.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppColors.primary : context.glassBorder, width: isSelected ? 1.5 : 1),
                  ),
                  child: Text(type, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: isSelected ? AppColors.primary : context.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    final days = _endDate.difference(_startDate).inDays + 1;
    final budget = double.tryParse(_budgetCtrl.text.replaceAll(',', '')) ?? 0;
    final perDay = days > 0 && budget > 0 ? budget / days : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plan your dates\n& budget 💰', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary)),
          const SizedBox(height: 20),

          // Date pickers
          Row(
            children: [
              Expanded(child: _DatePickerCard(label: 'Start Date', date: _startDate, onTap: () => _pickDate(true))),
              const SizedBox(width: 12),
              Expanded(child: _DatePickerCard(label: 'End Date', date: _endDate, onTap: () => _pickDate(false))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
                const SizedBox(width: 8),
                Text('Duration: $days day${days != 1 ? 's' : ''}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Budget
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: context.surfaceElevated,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  border: Border(left: BorderSide(color: context.glassBorder), top: BorderSide(color: context.glassBorder), bottom: BorderSide(color: context.glassBorder)),
                ),
                child: DropdownButton<String>(
                  value: _currency,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  underline: const SizedBox(),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: context.textPrimary),
                  items: AppConstants.currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _currency = v!),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _budgetCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins'),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Total Budget',
                    hintText: '50000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(14))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(14)), borderSide: BorderSide(color: Colors.transparent)),
                  ),
                ),
              ),
            ],
          ),
          if (perDay > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('≈ ${AppUtils.formatCurrency(perDay.toDouble(), symbol: _currency)} per day', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint)),
            ),

          const SizedBox(height: 20),
          Text('Number of Travelers', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: () { if (_travelers > 1) setState(() => _travelers--); },
                icon: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: context.surfaceElevated, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.glassBorder)),
                  child: Icon(Icons.remove, color: context.textPrimary, size: 18),
                ),
              ),
              Text('$_travelers', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: context.textPrimary)),
              IconButton(
                onPressed: () { if (_travelers < 20) setState(() => _travelers++); },
                icon: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: context.surfaceElevated, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.glassBorder)),
                  child: Icon(Icons.add, color: context.textPrimary, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Text('traveler${_travelers != 1 ? 's' : ''}', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: context.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Almost done!\nCustomize your trip ✨', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary)),
          const SizedBox(height: 20),

          _OptionSelector(label: 'Accommodation Type', icon: Icons.hotel, options: AppConstants.accommodationTypes, selected: _accommodation, onSelected: (v) => setState(() => _accommodation = v)),
          const SizedBox(height: 16),
          _OptionSelector(label: 'Travel Mode', icon: Icons.directions_bus, options: AppConstants.travelModes, selected: _travelMode, onSelected: (v) => setState(() => _travelMode = v)),
          const SizedBox(height: 16),

          Text('Special Preferences (Optional)', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
          const SizedBox(height: 10),
          TextFormField(
            controller: _preferencesCtrl,
            maxLines: 3,
            style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins', fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'e.g. Vegetarian food, no spicy, accessibility needs, must-see places...',
            ),
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('AI will generate your personalized itinerary, hotel recommendations, and budget breakdown!', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DatePickerCard({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: context.textHint)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(AppUtils.formatDate(date), style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  const _OptionSelector({required this.label, required this.icon, required this.options, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 16, color: AppColors.accent), const SizedBox(width: 6), Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary))]),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelected(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withOpacity(0.2) : context.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.accent : context.glassBorder, width: isSelected ? 1.5 : 1),
                ),
                child: Text(opt, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isSelected ? AppColors.accent : context.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
