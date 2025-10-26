import 'package:flutter/material.dart';
import '../models/video_info.dart';

class FormatSelector extends StatelessWidget {
  final String selectedFormat;
  final Function(String) onFormatChanged;
  final List<VideoFormat> formats;
  final String? selectedQuality;
  final Function(String) onQualityChanged;

  const FormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
    required this.formats,
    required this.selectedQuality,
    required this.onQualityChanged,
  });

  List<VideoFormat> get _filteredFormats {
    return formats.where((f) => f.type == selectedFormat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Download Format',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormatButton(
                  'video',
                  Icons.videocam,
                  'Video',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormatButton(
                  'audio',
                  Icons.music_note,
                  'Audio',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quality Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showQualityOptions(context);
                },
                child: const Text('Show Options'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Selected:',
                style: TextStyle(color: Colors.black54),
              ),
              Text(
                selectedQuality != null
                    ? _filteredFormats
                            .firstWhere((f) => f.formatId == selectedQuality)
                            .quality
                        : 'None',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton(String format, IconData icon, String label) {
    final isSelected = selectedFormat == format;
    return GestureDetector(
      onTap: () => onFormatChanged(format),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black54,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Quality',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (_filteredFormats.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No formats available for this type',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredFormats.length,
                  itemBuilder: (context, index) {
                    final format = _filteredFormats[index];
                    final isSelected = selectedQuality == format.formatId;
                    return ListTile(
                      leading: Icon(
                        selectedFormat == 'video'
                            ? Icons.videocam
                            : Icons.music_note,
                        color: isSelected ? Colors.blue : Colors.black54,
                      ),
                      title: Text(
                        format.quality,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        '${format.ext.toUpperCase()} • ${format.filesize}',
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.black54,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () {
                        onQualityChanged(format.formatId);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}