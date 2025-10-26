import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_info.dart';
import '../models/download_item.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://10.0.2.2:5000';

  Future<VideoInfo> getVideoInfo(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_video_info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VideoInfo.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to fetch video info');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> downloadVideo(
    String url,
    String formatId,
    String type,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/download'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'url': url,
          'format_id': formatId,
          'type': type,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to start download');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<DownloadItem>> getDownloads() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/downloads'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => DownloadItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch downloads');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}