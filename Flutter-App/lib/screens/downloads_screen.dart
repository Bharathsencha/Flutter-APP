import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  String _selectedCategory = 'All';
  final ApiService _apiService = ApiService();
  List<FileSystemEntity> _downloadedFiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _apiService.getDownloadedFiles();
      setState(() {
        _downloadedFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<FileSystemEntity> _getFilteredFiles() {
    if (_selectedCategory == 'All') {
      return _downloadedFiles;
    } else if (_selectedCategory == 'Videos') {
      return _downloadedFiles.where((file) {
        final path = file.path.toLowerCase();
        return path.endsWith('.mp4') || path.endsWith('.mkv') || 
               path.endsWith('.avi') || path.endsWith('.webm');
      }).toList();
    } else {
      return _downloadedFiles.where((file) {
        final path = file.path.toLowerCase();
        return path.endsWith('.mp3') || path.endsWith('.m4a') || 
               path.endsWith('.wav') || path.endsWith('.aac');
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Downloader'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Download videos and audio from any platform',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                // Category Tabs
                Row(
                  children: [
                    _buildCategoryTab('All', 'All'),
                    const SizedBox(width: 16),
                    _buildCategoryTab('Videos', 'Videos'),
                    const SizedBox(width: 16),
                    _buildCategoryTab('Audio', 'Audio'),
                  ],
                ),
              ],
            ),
          ),

          // Download History Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Download History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadDownloadedFiles,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // File List or Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _getFilteredFiles().isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Downloads Yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your download history will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _getFilteredFiles().length,
                        itemBuilder: (context, index) {
                          final file = _getFilteredFiles()[index];
                          final filename = file.path.split('/').last;
                          final isVideo = filename.toLowerCase().endsWith('.mp4') ||
                              filename.toLowerCase().endsWith('.mkv') ||
                              filename.toLowerCase().endsWith('.avi') ||
                              filename.toLowerCase().endsWith('.webm');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isVideo 
                                    ? Colors.blue.shade100 
                                    : Colors.orange.shade100,
                                child: Icon(
                                  isVideo ? Icons.video_library : Icons.music_note,
                                  color: isVideo ? Colors.blue : Colors.orange,
                                ),
                              ),
                              title: Text(
                                filename,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                _getFileSize(file),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _deleteFile(file);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red, size: 20),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _getFileSize(FileSystemEntity file) {
    try {
      final fileSize = File(file.path).lengthSync();
      if (fileSize < 1024) {
        return '$fileSize B';
      } else if (fileSize < 1024 * 1024) {
        return '${(fileSize / 1024).toStringAsFixed(1)} KB';
      } else if (fileSize < 1024 * 1024 * 1024) {
        return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete ${file.path.split('/').last}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await file.delete();
        _loadDownloadedFiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting file: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildCategoryTab(String text, String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedCategory == category ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedCategory == category ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _selectedCategory == category ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}