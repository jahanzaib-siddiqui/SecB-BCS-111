import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/app_constants.dart';

class GeminiService {
  static late final GenerativeModel _model;

  static void initialize() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 8192,
        topP: 0.95,
      ),
    );

  }

  static String _cleanJson(String text) {
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }

  // ─── Generate Full Trip Itinerary ─────────────────────────────────────────────
  static Future<String> generateItinerary({
    required String destination,
    required int days,
    required double budget,
    required String currency,
    required String tripType,
    required String accommodation,
    required String travelMode,
    required int travelers,
    String? preferences,
  }) async {
    final prompt = '''
You are TravelMate AI, an expert travel planner. Generate a detailed, practical ${days}-day travel itinerary for the following trip:

**Destination:** $destination
**Duration:** $days days
**Total Budget:** $currency ${budget.toStringAsFixed(0)}
**Budget Per Day:** $currency ${(budget / days).toStringAsFixed(0)}
**Trip Type:** $tripType
**Accommodation:** $accommodation
**Travel Mode:** $travelMode
**Number of Travelers:** $travelers
${preferences != null ? '**Special Preferences:** $preferences' : ''}

Please provide a comprehensive itinerary in the following JSON format:
{
  "summary": "Brief trip summary",
  "budget_breakdown": {
    "accommodation": number,
    "food": number,
    "transport": number,
    "activities": number,
    "miscellaneous": number,
    "total": number
  },
  "tips": ["tip1", "tip2", "tip3"],
  "best_time_to_visit": "season/month info",
  "days": [
    {
      "day": 1,
      "title": "Day title",
      "theme": "Theme for the day",
      "activities": [
        {
          "time": "9:00 AM",
          "title": "Activity name",
          "description": "Detailed description",
          "duration": "2 hours",
          "cost": number,
          "type": "sightseeing/food/transport/accommodation",
          "location": "Place name",
          "tips": "Helpful tip"
        }
      ],
      "meals": {
        "breakfast": {"place": "name", "estimated_cost": number, "description": ""},
        "lunch": {"place": "name", "estimated_cost": number, "description": ""},
        "dinner": {"place": "name", "estimated_cost": number, "description": ""}
      },
      "accommodation": {
        "name": "Hotel/place name",
        "estimated_cost": number,
        "area": "neighborhood"
      },
      "day_total": number
    }
  ]
}

Make it realistic, budget-appropriate, and include local experiences. Focus on authentic local culture and cuisine. Return ONLY the JSON without any markdown formatting.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return _cleanJson(response.text ?? '{}');
    } catch (e) {
      throw Exception('Failed to generate itinerary: $e');
    }
  }

  // ─── Get Hotel Recommendations ─────────────────────────────────────────────────
  static Future<String> getHotelRecommendations({
    required String destination,
    required double budgetPerNight,
    required String currency,
    required String accommodationType,
    required int guests,
  }) async {
    final prompt = '''
You are TravelMate AI. Recommend hotels for the following:

**Destination:** $destination
**Budget per night:** $currency ${budgetPerNight.toStringAsFixed(0)}
**Accommodation Type:** $accommodationType
**Number of Guests:** $guests

Return a JSON array of 6 hotel recommendations:
[
  {
    "name": "Hotel name",
    "type": "hotel type",
    "area": "neighborhood/area",
    "price_per_night": number,
    "rating": number (1-5),
    "amenities": ["wifi", "pool", "breakfast", etc],
    "description": "Brief description",
    "pros": ["pro1", "pro2"],
    "cons": ["con1"],
    "booking_tip": "How/where to book",
    "contact": "phone or website if known"
  }
]

Sort by value for money. Return ONLY the JSON array without markdown.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return _cleanJson(response.text ?? '[]');
    } catch (e) {
      throw Exception('Failed to get hotel recommendations: $e');
    }
  }

  // ─── Get Nearby Attractions ───────────────────────────────────────────────────
  static Future<String> getNearbyAttractions({
    required String destination,
    required String tripType,
  }) async {
    final prompt = '''
You are TravelMate AI. List the top attractions in $destination for a $tripType trip.

Return a JSON array of 10 attractions:
[
  {
    "name": "Attraction name",
    "type": "museum/park/monument/food/adventure/religious/nature/shopping",
    "description": "Detailed description",
    "location": "Area/Address",
    "entry_fee": number (0 if free),
    "currency": "PKR",
    "best_time": "morning/afternoon/evening",
    "duration": "2-3 hours",
    "rating": number (1-5),
    "tips": "Practical tips",
    "must_see": true/false,
    "lat": number,
    "lng": number
  }
]

Include a mix of famous landmarks, hidden gems, food spots, and local experiences. Return ONLY the JSON array.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return _cleanJson(response.text ?? '[]');
    } catch (e) {
      throw Exception('Failed to get attractions: $e');
    }
  }

  // ─── Budget Optimizer ────────────────────────────────────────────────────────
  static Future<String> optimizeBudget({
    required String destination,
    required double totalBudget,
    required String currency,
    required int days,
    required int travelers,
  }) async {
    final prompt = '''
You are TravelMate AI budget optimizer. Help optimize a trip budget:

**Destination:** $destination
**Total Budget:** $currency ${totalBudget.toStringAsFixed(0)}
**Duration:** $days days
**Travelers:** $travelers
**Per Person Budget:** $currency ${(totalBudget / travelers).toStringAsFixed(0)}

Provide detailed budget optimization in JSON:
{
  "feasibility": "excellent/good/tight/challenging",
  "feasibility_message": "explanation",
  "recommended_allocation": {
    "accommodation_percent": number,
    "food_percent": number,
    "transport_percent": number,
    "activities_percent": number,
    "shopping_percent": number,
    "emergency_fund_percent": number
  },
  "daily_budget": number,
  "money_saving_tips": ["tip1", "tip2", "tip3", "tip4", "tip5"],
  "budget_hotels": ["hotel1", "hotel2"],
  "budget_food_spots": ["place1", "place2"],
  "free_activities": ["activity1", "activity2", "activity3"],
  "best_value_transport": "recommended transport with reason",
  "warnings": ["warning if budget is too low"],
  "upgrades": ["what to splurge on if possible"]
}

Return ONLY the JSON without markdown.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return _cleanJson(response.text ?? '{}');
    } catch (e) {
      throw Exception('Failed to optimize budget: $e');
    }
  }

  // ─── Chat with AI ─────────────────────────────────────────────────────────────
  static Future<String> chat({
    required String userMessage,
    String? context,
  }) async {
    final systemContext = '''
You are TravelMate AI, a friendly and knowledgeable travel assistant specializing in Pakistan and international travel. 
You help travelers plan trips, find budget options, discover local culture, and make informed travel decisions.
Always be helpful, concise, and practical. Format responses with bullet points when listing multiple items.
${context != null ? 'Current trip context: $context' : ''}
''';

    try {
      final chat = _model.startChat(history: [
        Content.text(systemContext),
        Content.model([TextPart('I am TravelMate AI, ready to help you plan your perfect trip!')]),
      ]);
      final response = await chat.sendMessage(Content.text(userMessage));
      return response.text ?? 'I apologize, I could not process your request.';
    } catch (e) {
      throw Exception('Chat error: $e');
    }
  }
}
