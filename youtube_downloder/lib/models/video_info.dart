class VideoInfo {
  final String title;
  final String thumbnail;
  final String duration;
  final List<VideoFormat> formats;

  VideoInfo({
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.formats,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? '',
      formats: (json['formats'] as List<dynamic>?)
              ?.map((f) => VideoFormat.fromJson(f))
              .toList() ??
          [],
    );
  }
}

class VideoFormat {
  final String formatId;
  final String quality;
  final String type;
  final String filesize;
  final String ext;

  VideoFormat({
    required this.formatId,
    required this.quality,
    required this.type,
    required this.filesize,
    required this.ext,
  });

  factory VideoFormat.fromJson(Map<String, dynamic> json) {
    return VideoFormat(
      formatId: json['format_id'] ?? '',
      quality: json['quality'] ?? '',
      type: json['type'] ?? '',
      filesize: json['filesize'] ?? 'Unknown',
      ext: json['ext'] ?? '',
    );
  }
}