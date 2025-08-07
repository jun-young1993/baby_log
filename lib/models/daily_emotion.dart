class DailyEmotion {
  final DateTime date;
  final Map<String, double> emotions;
  final String? dominantEmotion;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DailyEmotion({
    required this.date,
    required this.emotions,
    this.dominantEmotion,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON에서 DailyEmotion 객체 생성
  factory DailyEmotion.fromJson(Map<String, dynamic> json) {
    return DailyEmotion(
      date: DateTime.parse(json['date']),
      emotions: Map<String, double>.from(json['emotions']),
      dominantEmotion: json['dominantEmotion'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// DailyEmotion 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'emotions': emotions,
      'dominantEmotion': dominantEmotion,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 감정 데이터 복사본 생성
  DailyEmotion copyWith({
    DateTime? date,
    Map<String, double>? emotions,
    String? dominantEmotion,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyEmotion(
      date: date ?? this.date,
      emotions: emotions ?? this.emotions,
      dominantEmotion: dominantEmotion ?? this.dominantEmotion,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 주요 감정 계산
  String get calculatedDominantEmotion {
    if (emotions.isEmpty) return '';

    return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 감정 점수 합계
  double get totalEmotionScore {
    return emotions.values.fold(0.0, (sum, score) => sum + score);
  }

  /// 감정 개수
  int get emotionCount {
    return emotions.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyEmotion && other.date == date;
  }

  @override
  int get hashCode => date.hashCode;

  @override
  String toString() {
    return 'DailyEmotion(date: $date, emotions: $emotions, dominantEmotion: $dominantEmotion)';
  }
}
