import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  final FocusNode _searchFocusNode = FocusNode();

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  WeatherErrorType? _errorType;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Load default city on start
    _fetchWeather('Karachi');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather(String city) async {
    if (city.trim().isEmpty) {
      _showSnackBar('Please enter a city name', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorType = null;
    });

    _fadeController.reset();
    _slideController.reset();

    try {
      final weather = await _weatherService.getWeatherByCity(city.trim());
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    } on WeatherException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _errorType = e.type;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred.';
        _errorType = WeatherErrorType.unknown;
      });
      _fadeController.forward();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError
            ? const Color(0xFFE53E3E)
            : const Color(0xFF38A169),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (_weather == null) {
      return [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)];
    }
    final condition = _weather!.condition.toLowerCase();
    if (condition.contains('clear') || condition.contains('sunny')) {
      final hour = DateTime.now().hour;
      if (hour >= 6 && hour < 18) {
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5), const Color(0xFF81D4FA)];
      } else {
        return [const Color(0xFF0D0D2B), const Color(0xFF1A1A5E), const Color(0xFF2D2D8F)];
      }
    } else if (condition.contains('cloud')) {
      return [const Color(0xFF37474F), const Color(0xFF546E7A), const Color(0xFF78909C)];
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return [const Color(0xFF1A237E), const Color(0xFF283593), const Color(0xFF1565C0)];
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return [const Color(0xFF1A1A2E), const Color(0xFF2D1B69), const Color(0xFF11073F)];
    } else if (condition.contains('snow')) {
      return [const Color(0xFF37474F), const Color(0xFF78909C), const Color(0xFFB0BEC5)];
    } else if (condition.contains('mist') || condition.contains('fog') || condition.contains('haze')) {
      return [const Color(0xFF455A64), const Color(0xFF607D8B), const Color(0xFF90A4AE)];
    }
    return [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)];
  }

  String _getWeatherEmoji() {
    if (_weather == null) return '🌍';
    final condition = _weather!.condition.toLowerCase();
    final icon = _weather!.iconCode;

    if (icon.endsWith('n')) {
      if (condition.contains('clear')) return '🌙';
      if (condition.contains('cloud')) return '☁️';
    }
    if (condition.contains('clear')) return '☀️';
    if (condition.contains('few cloud')) return '🌤️';
    if (condition.contains('scatter')) return '🌥️';
    if (condition.contains('broken') || condition.contains('overcast')) return '☁️';
    if (condition.contains('shower') || condition.contains('drizzle')) return '🌦️';
    if (condition.contains('rain')) return '🌧️';
    if (condition.contains('thunder')) return '⛈️';
    if (condition.contains('snow')) return '❄️';
    if (condition.contains('mist') || condition.contains('fog')) return '🌫️';
    if (condition.contains('haze')) return '😶‍🌫️';
    return '🌈';
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradientColors();

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WeatherNow',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.wb_sunny_rounded,
                  color: Colors.amber, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.7), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search city (e.g. London, Tokyo)...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onSubmitted: (value) {
                      _searchFocusNode.unfocus();
                      _fetchWeather(value);
                    },
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.text,
                    cursorColor: Colors.white,
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: Icon(Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.6), size: 18),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _searchFocusNode.unfocus();
                    _fetchWeather(_searchController.text);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9C89FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: _buildErrorState(),
      );
    } else if (_weather != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildWeatherContent(),
        ),
      );
    } else {
      return _buildInitialState();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                children: [
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Fetching weather data...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please wait a moment',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌍', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Discover Weather',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search for any city to get\nreal-time weather information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final icon = _errorType == WeatherErrorType.noInternet
        ? '📡'
        : _errorType == WeatherErrorType.cityNotFound
            ? '🗺️'
            : _errorType == WeatherErrorType.invalidApiKey
                ? '🔑'
                : '⚠️';

    return Center(
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                'Oops!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  _fetchWeather(_searchController.text.isNotEmpty
                      ? _searchController.text
                      : 'Karachi');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9C89FF)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final w = _weather!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          _buildMainWeatherCard(w),
          const SizedBox(height: 16),
          _buildDetailsGrid(w),
          const SizedBox(height: 16),
          _buildSunriseSunsetCard(w),
          const SizedBox(height: 16),
          _buildWindVisibilityRow(w),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard(WeatherModel w) {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // City & Country
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Colors.redAccent, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${w.cityName}, ${w.country}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('h:mm a · MMM d').format(w.localTime),
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Big emoji + temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWeatherEmoji(),
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      '${w.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w200,
                        height: 1,
                      ),
                    ),
                    Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Condition
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                w.description.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Divider
            Divider(color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 14),

            // Feels like / min-max
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Feels Like', '${w.feelsLike.round()}°C',
                    Icons.thermostat_rounded),
                _buildVerticalDivider(),
                _buildMiniStat(
                    'Low', '${w.tempMin.round()}°C', Icons.arrow_downward_rounded),
                _buildVerticalDivider(),
                _buildMiniStat(
                    'High', '${w.tempMax.round()}°C', Icons.arrow_upward_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(WeatherModel w) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailCard(
            emoji: '💧',
            label: 'Humidity',
            value: '${w.humidity}%',
            sublabel: w.humidity > 70 ? 'High' : w.humidity > 40 ? 'Moderate' : 'Low',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailCard(
            emoji: '📊',
            label: 'Pressure',
            value: '${w.pressure} hPa',
            sublabel: w.pressure > 1013 ? 'High Pressure' : 'Low Pressure',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String emoji,
    required String label,
    required String value,
    required String sublabel,
  }) {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                sublabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunriseSunsetCard(WeatherModel w) {
    final totalDuration =
        w.sunset.difference(w.sunrise).inMinutes.toDouble();
    final elapsed =
        DateTime.now().difference(w.sunrise).inMinutes.toDouble();
    final progress = (elapsed / totalDuration).clamp(0.0, 1.0);

    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_twilight_rounded,
                    color: Colors.amber.withValues(alpha: 0.8), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Sunrise & Sunset',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSunTime(
                    '🌅', 'Sunrise', DateFormat('h:mm a').format(w.sunrise)),
                _buildSunTime(
                    '🌇', 'Sunset', DateFormat('h:mm a').format(w.sunset)),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dawn',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10)),
                Text('Dusk',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunTime(String emoji, String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style:
              TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWindVisibilityRow(WeatherModel w) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailCard(
            emoji: '🌬️',
            label: 'Wind Speed',
            value: '${w.windSpeed.toStringAsFixed(1)} m/s',
            sublabel: w.windSpeed < 3
                ? 'Calm'
                : w.windSpeed < 8
                    ? 'Moderate'
                    : 'Strong Wind',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailCard(
            emoji: '👁️',
            label: 'Visibility',
            value: '${(w.visibility / 1000).toStringAsFixed(1)} km',
            sublabel: w.visibility >= 10000
                ? 'Excellent'
                : w.visibility >= 5000
                    ? 'Good'
                    : 'Poor',
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
