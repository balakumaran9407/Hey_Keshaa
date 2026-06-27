class HairScan {
  final String id;
  final double temperature;
  final double humidity;
  final double moisture;
  final bool motion;
  final DateTime timestamp;
  final String? notes;

  HairScan({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.motion,
    required this.timestamp,
    this.notes,
  });

  // Convert HairScan to Map for SQLite database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'temperature': temperature,
      'humidity': humidity,
      'moisture': moisture,
      'motion': motion ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  // Convert HairScan to JSON for Firebase/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temperature': temperature,
      'humidity': humidity,
      'moisture': moisture,
      'motion': motion,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  // Create HairScan from Map (from SQLite database)
  factory HairScan.fromMap(Map<String, dynamic> map) {
    return HairScan(
      id: map['id'] as String,
      temperature: map['temperature'] as double,
      humidity: map['humidity'] as double,
      moisture: map['moisture'] as double,
      motion: map['motion'] == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String?,
    );
  }

  // Create HairScan from JSON (from Firebase/API)
  factory HairScan.fromJson(Map<String, dynamic> json) {
    return HairScan(
      id: json['id'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      moisture: (json['moisture'] as num).toDouble(),
      motion: json['motion'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }

  // Create a copy with optional modifications
  HairScan copyWith({
    String? id,
    double? temperature,
    double? humidity,
    double? moisture,
    bool? motion,
    DateTime? timestamp,
    String? notes,
  }) {
    return HairScan(
      id: id ?? this.id,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      moisture: moisture ?? this.moisture,
      motion: motion ?? this.motion,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'HairScan(id: $id, temperature: $temperature, humidity: $humidity, moisture: $moisture, motion: $motion, timestamp: $timestamp, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HairScan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
