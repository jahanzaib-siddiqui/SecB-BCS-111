import 'dart:convert';

class TripModel {
  final String? id;
  final String userId;
  final String destination;
  final String destinationCountry;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String currency;
  final String tripType;
  final String accommodation;
  final String travelMode;
  final int travelers;
  final String? preferences;
  final String? coverImageUrl;
  final String status; // planning, ongoing, completed, cancelled
  final Map<String, dynamic>? budgetBreakdown;
  final String? aiSummary;
  final double spentAmount;
  final DateTime? createdAt;

  const TripModel({
    this.id,
    required this.userId,
    required this.destination,
    required this.destinationCountry,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.currency,
    required this.tripType,
    required this.accommodation,
    required this.travelMode,
    required this.travelers,
    this.preferences,
    this.coverImageUrl,
    this.status = 'planning',
    this.budgetBreakdown,
    this.aiSummary,
    this.spentAmount = 0.0,
    this.createdAt,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;
  double get remainingBudget => budget - spentAmount;
  double get spentPercentage => budget > 0 ? (spentAmount / budget) : 0;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'destination': destination,
      'destination_country': destinationCountry,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'budget': budget,
      'currency': currency,
      'trip_type': tripType,
      'accommodation': accommodation,
      'travel_mode': travelMode,
      'travelers': travelers,
      'preferences': preferences,
      'cover_image_url': coverImageUrl,
      'status': status,
      'budget_breakdown': budgetBreakdown != null
          ? jsonEncode(budgetBreakdown)
          : null,
      'ai_summary': aiSummary,
      'spent_amount': spentAmount,
    };
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      destination: json['destination'] ?? '',
      destinationCountry: json['destination_country'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      budget: (json['budget'] as num).toDouble(),
      currency: json['currency'] ?? 'PKR',
      tripType: json['trip_type'] ?? 'Cultural',
      accommodation: json['accommodation'] ?? 'Budget Hotel',
      travelMode: json['travel_mode'] ?? 'Bus',
      travelers: json['travelers'] ?? 1,
      preferences: json['preferences'],
      coverImageUrl: json['cover_image_url'],
      status: json['status'] ?? 'planning',
      budgetBreakdown: json['budget_breakdown'] != null
          ? jsonDecode(json['budget_breakdown'])
          : null,
      aiSummary: json['ai_summary'],
      spentAmount: (json['spent_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  TripModel copyWith({
    String? id,
    String? destination,
    String? destinationCountry,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? currency,
    String? tripType,
    String? accommodation,
    String? travelMode,
    int? travelers,
    String? preferences,
    String? coverImageUrl,
    String? status,
    Map<String, dynamic>? budgetBreakdown,
    String? aiSummary,
    double? spentAmount,
  }) {
    return TripModel(
      id: id ?? this.id,
      userId: userId,
      destination: destination ?? this.destination,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      tripType: tripType ?? this.tripType,
      accommodation: accommodation ?? this.accommodation,
      travelMode: travelMode ?? this.travelMode,
      travelers: travelers ?? this.travelers,
      preferences: preferences ?? this.preferences,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      budgetBreakdown: budgetBreakdown ?? this.budgetBreakdown,
      aiSummary: aiSummary ?? this.aiSummary,
      spentAmount: spentAmount ?? this.spentAmount,
      createdAt: createdAt,
    );
  }
}
