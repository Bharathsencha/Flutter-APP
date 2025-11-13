class Download {
  final int? id;
  final int userId;
  final String filename;
  final String filepath;
  final String type; // 'video' or 'audio'
  final DateTime downloadedAt;

  Download({
    this.id,
    required this.userId,
    required this.filename,
    required this.filepath,
    required this.type,
    required this.downloadedAt,
  });

  // Convert Download to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'filename': filename,
      'filepath': filepath,
      'type': type,
      'downloadedAt': downloadedAt.toIso8601String(),
    };
  }

  // Create Download from Map (from database)
  factory Download.fromMap(Map<String, dynamic> map) {
    return Download(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      filename: map['filename'] as String,
      filepath: map['filepath'] as String,
      type: map['type'] as String,
      downloadedAt: DateTime.parse(map['downloadedAt'] as String),
    );
  }

  // Copy with method
  Download copyWith({
    int? id,
    int? userId,
    String? filename,
    String? filepath,
    String? type,
    DateTime? downloadedAt,
  }) {
    return Download(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      filename: filename ?? this.filename,
      filepath: filepath ?? this.filepath,
      type: type ?? this.type,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  String toString() =>
      'Download(id: $id, userId: $userId, filename: $filename, type: $type)';
}
