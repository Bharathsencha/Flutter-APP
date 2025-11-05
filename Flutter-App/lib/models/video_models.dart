class VideoInfo {
  final String id;
  final String title;
  final String thumbnail;
  final int duration;
  final String uploader;
  final int viewCount;
  final String description;

  VideoInfo({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.uploader,
    required this.viewCount,
    required this.description,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? 0,
      uploader: json['uploader'] ?? 'Unknown',
      viewCount: json['view_count'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}

class VideoFormat {
  final String formatId;
  final String ext;
  final String quality;
  final String resolution;
  final int filesize;
  final String type;

  VideoFormat({
    required this.formatId,
    required this.ext,
    required this.quality,
    required this.resolution,
    required this.filesize,
    required this.type,
  });

  factory VideoFormat.fromJson(Map<String, dynamic> json) {
    return VideoFormat(
      formatId: json['format_id'] ?? '',
      ext: json['ext'] ?? '',
      quality: json['quality'] ?? '',
      resolution: json['resolution'] ?? '',
      filesize: json['filesize'] ?? 0,
      type: json['type'] ?? 'video',
    );
  }
}

class DownloadResult {
  final bool success;
  final String filename;
  final String title;
  final String downloadUrl;
  final String? error;

  DownloadResult({
    required this.success,
    required this.filename,
    required this.title,
    required this.downloadUrl,
    this.error,
  });

  factory DownloadResult.fromJson(Map<String, dynamic> json) {
    return DownloadResult(
      success: json['success'] ?? false,
      filename: json['filename'] ?? '',
      title: json['title'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      error: json['error'],
    );
  }
}
