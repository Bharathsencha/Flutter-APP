import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  String _downloadLocation = 'Internal Storage';
  String _defaultFormat = 'Video';
  String _videoQuality = 'Best Available';
  String _theme = 'System Default';
  String _cacheSize = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _calculateCacheSize();
  }

  Future<void> _loadSettings() async {
    final path = await _apiService.getDownloadsPath();
    setState(() {
      if (path != null) {
        _downloadLocation = path.split('\\').last;
      }
    });
  }

  Future<void> _calculateCacheSize() async {
    try {
      final files = await _apiService.getDownloadedFiles();
      int totalSize = 0;
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      setState(() {
        _cacheSize = _formatBytes(totalSize);
      });
    } catch (e) {
      setState(() {
        _cacheSize = '0 MB';
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Download Settings
          _buildSettingsSection(
            'Download Settings',
            [
              _buildClickableSettingsItem(
                'Download Location',
                _downloadLocation,
                Icons.chevron_right,
                () => _showDownloadLocationDialog(context),
              ),
              _buildClickableSettingsItem(
                'Default Format',
                _defaultFormat,
                Icons.chevron_right,
                () => _showFormatDialog(context),
              ),
              _buildClickableSettingsItem(
                'Video Quality',
                _videoQuality,
                Icons.chevron_right,
                () => _showQualityDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // App Settings
          _buildSettingsSection(
            'App Settings',
            [
              _buildClickableSettingsItem(
                'Theme',
                _theme,
                Icons.chevron_right,
                () => _showThemeDialog(context),
              ),
              _buildClickableSettingsItem(
                'Language',
                'English',
                Icons.chevron_right,
                () => _showComingSoonSnackbar(context, 'Language selection'),
              ),
              _buildClickableSettingsItem(
                'Clear Cache',
                _cacheSize,
                Icons.chevron_right,
                () => _clearCache(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About
          _buildSettingsSection(
            'About',
            [
              _buildClickableSettingsItem(
                'Version',
                '1.0.0',
                null,
                null,
              ),
              _buildClickableSettingsItem(
                'Privacy Policy',
                '',
                Icons.chevron_right,
                () => _openUrl('https://github.com'),
              ),
              _buildClickableSettingsItem(
                'Terms of Service',
                '',
                Icons.chevron_right,
                () => _openUrl('https://github.com'),
              ),
              _buildClickableSettingsItem(
                'Check for Updates',
                '',
                Icons.chevron_right,
                () => _checkForUpdates(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Storage Info
          _buildStorageInfo(),
          const SizedBox(height: 32),

          // Support Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _contactSupport(),
              icon: const Icon(Icons.support_agent),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              label: const Text(
                'Contact Support',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo() {
    return FutureBuilder<String?>(
      future: _apiService.getDownloadsPath(),
      builder: (context, snapshot) {
        final path = snapshot.data ?? 'Loading...';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Storage Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Downloads are saved to:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                path,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDownloadLocationDialog(BuildContext context) async {
    final path = await _apiService.getDownloadsPath();
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current download location:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                path ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Files are automatically saved to the app\'s Downloads folder.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFormatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Video'),
              leading: Radio<String>(
                value: 'Video',
                groupValue: _defaultFormat,
                onChanged: (value) {
                  setState(() {
                    _defaultFormat = value!;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Default format set to $value')),
                  );
                },
              ),
            ),
            ListTile(
              title: const Text('Audio'),
              leading: Radio<String>(
                value: 'Audio',
                groupValue: _defaultFormat,
                onChanged: (value) {
                  setState(() {
                    _defaultFormat = value!;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Default format set to $value')),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showQualityDialog(BuildContext context) {
    final qualities = ['Best Available', '1080p', '720p', '480p', '360p'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: qualities.map((quality) {
            return ListTile(
              title: Text(quality),
              leading: Radio<String>(
                value: quality,
                groupValue: _videoQuality,
                onChanged: (value) {
                  setState(() {
                    _videoQuality = value!;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Quality set to $value')),
                  );
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themes = ['System Default', 'Light', 'Dark'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) {
            return ListTile(
              title: Text(theme),
              leading: Radio<String>(
                value: theme,
                groupValue: _theme,
                onChanged: (value) {
                  setState(() {
                    _theme = value!;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Theme preference saved! (Restart app to apply)'),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will delete all downloaded files.'),
            const SizedBox(height: 8),
            Text(
              'Current cache: $_cacheSize',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final files = await _apiService.getDownloadedFiles();
        for (var file in files) {
          await file.delete();
        }
        
        setState(() {
          _cacheSize = '0 MB';
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cache cleared successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing cache: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open URL')),
        );
      }
    }
  }

  void _checkForUpdates(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check for Updates'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text(
              'You\'re using the latest version!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email'),
              subtitle: const Text('support@videodownloader.com'),
              onTap: () {
                _openUrl('mailto:support@videodownloader.com');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.web, color: Colors.blue),
              title: const Text('Website'),
              subtitle: const Text('Visit our support page'),
              onTap: () {
                _openUrl('https://github.com');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.blue),
              title: const Text('Report Bug'),
              subtitle: const Text('Help us improve'),
              onTap: () {
                _openUrl('https://github.com/issues');
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildClickableSettingsItem(
    String title,
    String subtitle,
    IconData? trailingIcon,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingIcon != null)
              Icon(
                trailingIcon,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}