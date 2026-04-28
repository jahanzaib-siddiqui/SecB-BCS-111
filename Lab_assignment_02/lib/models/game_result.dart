class GameResult {
  final int? id;
  final int guessedNumber;
  final int targetNumber;
  final String status;
  final String timestamp;

  GameResult({
    this.id,
    required this.guessedNumber,
    required this.targetNumber,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'guessed_number': guessedNumber,
      'target_number': targetNumber,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      id: map['id'] as int?,
      guessedNumber: map['guessed_number'] as int,
      targetNumber: map['target_number'] as int,
      status: map['status'] as String,
      timestamp: map['timestamp'] as String,
    );
  }

  @override
  String toString() {
    return 'GameResult{id: $id, guessedNumber: $guessedNumber, targetNumber: $targetNumber, status: $status, timestamp: $timestamp}';
  }
}
