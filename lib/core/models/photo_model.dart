import 'package:hive/hive.dart';

part 'photo_model.g.dart';

/// Media type enum for PhotoModel
/// Represents whether the media is a photo or video
enum MediaType { photo, video }

/// PhotoModel - Supports both photos and videos
/// Can be renamed to MediaModel in the future for clarity
@HiveType(typeId: 0)
class PhotoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String filePath;

  @HiveField(2)
  final String fileName;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? takenAt;

  @HiveField(5)
  final String? caption;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final String? emotion;

  @HiveField(8)
  final bool isFirstMoment;

  @HiveField(9)
  final String? albumId;

  @HiveField(10)
  final double? latitude;

  @HiveField(11)
  final double? longitude;

  @HiveField(12)
  final int fileSize;

  @HiveField(13)
  final String? thumbnailPath;

  /// Media type: 'photo' or 'video' (default: 'photo' for backward compatibility)
  @HiveField(14)
  final String mediaType;

  /// Video duration in seconds (only for videos)
  @HiveField(15)
  final int? durationInSeconds;

  /// Video codec information (e.g., 'h264', 'hevc')
  @HiveField(16)
  final String? videoCodec;

  /// Video aspect ratio (e.g., 16:9 = 1.777, 9:16 = 0.5625)
  @HiveField(17)
  final double? aspectRatio;

  PhotoModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.createdAt,
    this.takenAt,
    this.caption,
    this.tags = const [],
    this.emotion,
    this.isFirstMoment = false,
    this.albumId,
    this.latitude,
    this.longitude,
    required this.fileSize,
    this.thumbnailPath,
    this.mediaType = 'photo',
    this.durationInSeconds,
    this.videoCodec,
    this.aspectRatio,
  });

  /// Check if this media is a video
  bool get isVideo => mediaType == 'video';

  /// Check if this media is a photo
  bool get isPhoto => mediaType == 'photo';

  /// Get formatted duration string (e.g., "1:23", "10:05")
  String? get formattedDuration {
    if (durationInSeconds == null) return null;
    final minutes = durationInSeconds! ~/ 60;
    final seconds = durationInSeconds! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  PhotoModel copyWith({
    String? id,
    String? filePath,
    String? fileName,
    DateTime? createdAt,
    DateTime? takenAt,
    String? caption,
    List<String>? tags,
    String? emotion,
    bool? isFirstMoment,
    String? albumId,
    double? latitude,
    double? longitude,
    int? fileSize,
    String? thumbnailPath,
    String? mediaType,
    int? durationInSeconds,
    String? videoCodec,
    double? aspectRatio,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      takenAt: takenAt ?? this.takenAt,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      emotion: emotion ?? this.emotion,
      isFirstMoment: isFirstMoment ?? this.isFirstMoment,
      albumId: albumId ?? this.albumId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fileSize: fileSize ?? this.fileSize,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      mediaType: mediaType ?? this.mediaType,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      videoCodec: videoCodec ?? this.videoCodec,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'takenAt': takenAt?.toIso8601String(),
      'caption': caption,
      'tags': tags,
      'emotion': emotion,
      'isFirstMoment': isFirstMoment,
      'albumId': albumId,
      'latitude': latitude,
      'longitude': longitude,
      'fileSize': fileSize,
      'thumbnailPath': thumbnailPath,
      'mediaType': mediaType,
      'durationInSeconds': durationInSeconds,
      'videoCodec': videoCodec,
      'aspectRatio': aspectRatio,
    };
  }

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      takenAt: json['takenAt'] != null
          ? DateTime.parse(json['takenAt'] as String)
          : null,
      caption: json['caption'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      emotion: json['emotion'] as String?,
      isFirstMoment: json['isFirstMoment'] as bool? ?? false,
      albumId: json['albumId'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      fileSize: json['fileSize'] as int,
      thumbnailPath: json['thumbnailPath'] as String?,
      mediaType: json['mediaType'] as String? ?? 'photo',
      durationInSeconds: json['durationInSeconds'] as int?,
      videoCodec: json['videoCodec'] as String?,
      aspectRatio: json['aspectRatio'] as double?,
    );
  }
}
