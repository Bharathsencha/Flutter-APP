class DownloadItem {
  final String id;
  final String title;
  final String type;
  final String date;
  final String path;

  DownloadItem({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.path,
  });

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      path: json['path'] ?? '',
    );
  }
}