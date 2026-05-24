class ExpenseModel {
  final String? id;
  final String tripId;
  final String category;
  final String title;
  final double amount;
  final String currency;
  final DateTime date;
  final String? note;
  final String? receiptUrl;
  final DateTime? createdAt;

  const ExpenseModel({
    this.id,
    required this.tripId,
    required this.category,
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
    this.note,
    this.receiptUrl,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'trip_id': tripId,
    'category': category,
    'title': title,
    'amount': amount,
    'currency': currency,
    'date': date.toIso8601String(),
    'note': note,
    'receipt_url': receiptUrl,
  };

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id'],
    tripId: json['trip_id'] ?? '',
    category: json['category'] ?? 'Miscellaneous',
    title: json['title'] ?? '',
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] ?? 'PKR',
    date: DateTime.parse(json['date']),
    note: json['note'],
    receiptUrl: json['receipt_url'],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
  );
}

class HotelModel {
  final String name;
  final String type;
  final String area;
  final double pricePerNight;
  final double rating;
  final List<String> amenities;
  final String description;
  final List<String> pros;
  final List<String> cons;
  final String bookingTip;
  final String? contact;
  final String? imageUrl;
  bool isSaved;

  HotelModel({
    required this.name,
    required this.type,
    required this.area,
    required this.pricePerNight,
    required this.rating,
    required this.amenities,
    required this.description,
    required this.pros,
    required this.cons,
    required this.bookingTip,
    this.contact,
    this.imageUrl,
    this.isSaved = false,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) => HotelModel(
    name: json['name'] ?? '',
    type: json['type'] ?? '',
    area: json['area'] ?? '',
    pricePerNight: (json['price_per_night'] as num?)?.toDouble() ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    amenities: List<String>.from(json['amenities'] ?? []),
    description: json['description'] ?? '',
    pros: List<String>.from(json['pros'] ?? []),
    cons: List<String>.from(json['cons'] ?? []),
    bookingTip: json['booking_tip'] ?? '',
    contact: json['contact'],
    imageUrl: json['image_url'],
  );
}

class AttractionModel {
  final String name;
  final String type;
  final String description;
  final String location;
  final double entryFee;
  final String currency;
  final String bestTime;
  final String duration;
  final double rating;
  final String tips;
  final bool mustSee;
  final double? lat;
  final double? lng;
  bool isSaved;

  AttractionModel({
    required this.name,
    required this.type,
    required this.description,
    required this.location,
    required this.entryFee,
    required this.currency,
    required this.bestTime,
    required this.duration,
    required this.rating,
    required this.tips,
    required this.mustSee,
    this.lat,
    this.lng,
    this.isSaved = false,
  });

  factory AttractionModel.fromJson(Map<String, dynamic> json) =>
      AttractionModel(
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        description: json['description'] ?? '',
        location: json['location'] ?? '',
        entryFee: (json['entry_fee'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] ?? 'PKR',
        bestTime: json['best_time'] ?? '',
        duration: json['duration'] ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        tips: json['tips'] ?? '',
        mustSee: json['must_see'] ?? false,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}
