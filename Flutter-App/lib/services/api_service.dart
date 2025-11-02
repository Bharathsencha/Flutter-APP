import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import '../models/video_models.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(minutes: 10); // 10 minutes for large files
    _dio.options.sendTimeout = const Duration(seconds: 60);
  }

  /// Health check to verify backend is running
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get(ApiConfig.apiHealth);
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  /// Get video information
  Future<VideoInfo?> getVideoInfo(String url) async {
    try {
      final response = await _dio.post(
        ApiConfig.apiInfo,
        data: {'url': url},
      );

      if (response.statusCode == 200) {
        return VideoInfo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error getting video info: $e');
      rethrow;
    }
  }

  /// Get available formats
  Future<List<VideoFormat>> getFormats(String url) async {
    try {
      final response = await _dio.post(
        ApiConfig.apiFormats,
        data: {'url': url},
      );

      if (response.statusCode == 200) {
        final List<dynamic> formats = response.data['formats'];
        return formats.map((f) => VideoFormat.fromJson(f)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting formats: $e');
      rethrow;
    }
  }

  /// Download video and save to device
  Future<String?> downloadVideo({
    required String url,
    required String format,
    String quality = 'best',
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Step 1: Start download on backend
      final response = await _dio.post(
        ApiConfig.apiDownload,
        data: {
          'url': url,
          'format': format,
          'quality': quality,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final downloadId = response.data['download_id'] as String?;
        
        if (downloadId == null) {
          throw Exception('No download ID received from server');
        }
        
        // Step 2: Poll for progress until download completes
        String? filename;
        String? downloadUrl;
        
        while (true) {
          await Future.delayed(const Duration(seconds: 2));
          
          final progressResponse = await _dio.get(
            '${ApiConfig.baseUrl}/api/progress/$downloadId',
          );
          
          if (progressResponse.statusCode == 200) {
            final status = progressResponse.data['status'] as String?;
            final progress = progressResponse.data['progress'] ?? 0.0;
            
            // Update progress callback
            if (onProgress != null) {
              onProgress(progress.toInt(), 100);
            }
            
            if (status == 'completed') {
              filename = progressResponse.data['filename'] as String?;
              final downloadPath = progressResponse.data['download_url'] as String?;
              if (downloadPath != null) {
                downloadUrl = '${ApiConfig.baseUrl}$downloadPath';
              }
              break;
            } else if (status == 'error') {
              final errorMsg = progressResponse.data['error'] as String?;
              throw Exception(errorMsg ?? 'Download failed');
            } else if (status == 'not_found') {
              throw Exception('Download not found on server');
            }
          }
        }
        
        if (filename != null && downloadUrl != null) {
          // Step 3: Download the file from backend to device
          final savedPath = await _downloadFileToDevice(
            downloadUrl,
            filename,
            onProgress: onProgress,
          );
          return savedPath;
        }
      }
      return null;
    } catch (e) {
      print('Error downloading video: $e');
      rethrow;
    }
  }

  /// Download file from backend server to device storage
  Future<String?> _downloadFileToDevice(
    String url,
    String filename, {
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Get the directory to save files
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not get storage directory');
      }

      // Create Downloads folder if it doesn't exist
      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final savePath = '${downloadsDir.path}/$filename';

      // Create a separate Dio instance for file download with better configuration
      final downloadDio = Dio(BaseOptions(
        receiveTimeout: const Duration(minutes: 30),
        sendTimeout: const Duration(minutes: 5),
        connectTimeout: const Duration(minutes: 2),
      ));

      // Retry logic for unreliable connections
      int maxRetries = 3;
      int retryCount = 0;
      
      while (retryCount < maxRetries) {
        try {
          // Download file with progress tracking
          await downloadDio.download(
            url,
            savePath,
            onReceiveProgress: (received, total) {
              if (total != -1 && onProgress != null) {
                onProgress(received, total);
              }
            },
            options: Options(
              receiveTimeout: const Duration(minutes: 30),
              sendTimeout: const Duration(minutes: 5),
              followRedirects: true,
              validateStatus: (status) => status! < 500,
            ),
            deleteOnError: true,
          );
          
          print('File saved to: $savePath');
          return savePath;
        } catch (e) {
          retryCount++;
          print('Download attempt $retryCount failed: $e');
          
          if (retryCount >= maxRetries) {
            rethrow;
          }
          
          // Wait before retrying
          await Future.delayed(Duration(seconds: 2 * retryCount));
        }
      }
      
      return savePath;
    } catch (e) {
      print('Error saving file: $e');
      rethrow;
    }
  }

  /// Get downloads directory path
  Future<String?> getDownloadsPath() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final downloadsDir = Directory('${directory.path}/Downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return downloadsDir.path;
      }
      return null;
    } catch (e) {
      print('Error getting downloads path: $e');
      return null;
    }
  }

  /// List downloaded files
  Future<List<FileSystemEntity>> getDownloadedFiles() async {
    try {
      final path = await getDownloadsPath();
      if (path != null) {
        final directory = Directory(path);
        if (await directory.exists()) {
          return directory.listSync();
        }
      }
      return [];
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }
}
