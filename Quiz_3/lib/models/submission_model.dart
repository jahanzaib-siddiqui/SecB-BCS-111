class SubmissionModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final DateTime? createdAt;

  SubmissionModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    this.createdAt,
  });

  // Convert a Map (JSON) from Supabase into a SubmissionModel
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as String?,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Convert a SubmissionModel into a Map (JSON) for Supabase
  Map<String, dynamic> toJson({bool includeId = false}) {
    final Map<String, dynamic> data = {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'gender': gender,
    };
    if (includeId && id != null) {
      data['id'] = id;
    }
    return data;
  }

  // Create a copy of SubmissionModel with some updated fields
  SubmissionModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? gender,
    DateTime? createdAt,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
