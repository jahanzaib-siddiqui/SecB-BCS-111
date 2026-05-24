class AppConstants {
  // ─── Supabase ────────────────────────────────────────────────────────────────
  static const String supabaseUrl = 'https://xaehfolfkeclfjdmpyew.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhZWhmb2xma2VjbGZqZG1weWV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NDMxNzksImV4cCI6MjA5NDQxOTE3OX0.aGiDvuyfhC4LtpSd5ANVSsdRykBLL9mhtTNzVG8fwc0';

  // ─── Google Gemini ───────────────────────────────────────────────────────────
  static const String geminiApiKey = 'AIzaSyB9WpbEz1JsIF5wPQJN6D-rs48JJan8VQw';

  // ─── App Info ────────────────────────────────────────────────────────────────
  static const String appName = 'TravelMate';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your AI Travel Companion';

  // ─── Currency ────────────────────────────────────────────────────────────────
  static const String defaultCurrency = 'PKR';
  static const List<String> currencies = [
    'PKR', 'USD', 'EUR', 'GBP', 'AED', 'SAR', 'INR', 'CAD', 'AUD'
  ];

  // ─── Trip Types ───────────────────────────────────────────────────────────────
  static const List<String> tripTypes = [
    'Adventure', 'Cultural', 'Beach', 'Mountain', 'City Tour',
    'Pilgrimage', 'Honeymoon', 'Family', 'Solo', 'Business'
  ];

  // ─── Accommodation Types ──────────────────────────────────────────────────────
  static const List<String> accommodationTypes = [
    'Budget Hotel', '3-Star Hotel', '4-Star Hotel', '5-Star Hotel',
    'Hostel', 'Airbnb', 'Resort', 'Guesthouse'
  ];

  // ─── Travel Modes ────────────────────────────────────────────────────────────
  static const List<String> travelModes = [
    'Flight', 'Train', 'Bus', 'Car', 'Bike', 'Walking'
  ];

  // ─── Budget Categories ────────────────────────────────────────────────────────
  static const List<String> expenseCategories = [
    'Accommodation', 'Food', 'Transport', 'Activities',
    'Shopping', 'Healthcare', 'Miscellaneous'
  ];

  // ─── Popular Destinations (Pakistan focus) ────────────────────────────────────
  static const List<Map<String, dynamic>> popularDestinations = [
    {'name': 'Lahore', 'country': 'Pakistan', 'image': 'lahore', 'rating': 4.8},
    {'name': 'Hunza', 'country': 'Pakistan', 'image': 'hunza', 'rating': 4.9},
    {'name': 'Swat', 'country': 'Pakistan', 'image': 'swat', 'rating': 4.7},
    {'name': 'Murree', 'country': 'Pakistan', 'image': 'murree', 'rating': 4.5},
    {'name': 'Karachi', 'country': 'Pakistan', 'image': 'karachi', 'rating': 4.3},
    {'name': 'Islamabad', 'country': 'Pakistan', 'image': 'islamabad', 'rating': 4.6},
    {'name': 'Skardu', 'country': 'Pakistan', 'image': 'skardu', 'rating': 4.9},
    {'name': 'Peshawar', 'country': 'Pakistan', 'image': 'peshawar', 'rating': 4.4},
  ];
}
