import yt_dlp
from utils.format_helper import format_filesize, format_duration

class VideoService:
    def __init__(self):
        self.ydl_opts = {
        'quiet': True,
        'no_warnings': True,
        'extract_flat': False,
        'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'extractor_args': {
            'youtube': {
                'player_client': ['android'],
                'skip': ['hls', 'dash']
            }
        }
    }
    def get_video_info(self, url):
        try:
            with yt_dlp.YoutubeDL(self.ydl_opts) as ydl:
                info = ydl.extract_info(url, download=False)
                
                # Get thumbnail
                thumbnail = ''
                if 'thumbnail' in info:
                    thumbnail = info['thumbnail']
                elif 'thumbnails' in info and len(info['thumbnails']) > 0:
                    thumbnail = info['thumbnails'][-1]['url']
                
                # Get duration
                duration = format_duration(info.get('duration', 0))
                
                # Process formats
                formats = self._process_formats(info.get('formats', []))
                
                return {
                    'title': info.get('title', 'Unknown'),
                    'thumbnail': thumbnail,
                    'duration': duration,
                    'formats': formats
                }
        except Exception as e:
            raise Exception(f"Failed to fetch video info: {str(e)}")
    
    def _process_formats(self, formats):
        processed = []
        seen_qualities = set()
        
        # Sort formats by quality
        video_formats = []
        audio_formats = []
        
        for fmt in formats:
            if fmt.get('vcodec') != 'none' and fmt.get('acodec') != 'none':
                # Video with audio
                video_formats.append(fmt)
            elif fmt.get('acodec') != 'none' and fmt.get('vcodec') == 'none':
                # Audio only
                audio_formats.append(fmt)
        
        # Process video formats
        for fmt in sorted(video_formats, key=lambda x: x.get('height', 0), reverse=True):
            height = fmt.get('height', 0)
            if height and height not in seen_qualities:
                quality_label = f"{height}p"
                if fmt.get('fps'):
                    quality_label += f" {fmt.get('fps')}fps"
                
                processed.append({
                    'format_id': fmt['format_id'],
                    'quality': quality_label,
                    'type': 'video',
                    'filesize': format_filesize(fmt.get('filesize') or fmt.get('filesize_approx', 0)),
                    'ext': fmt.get('ext', 'mp4')
                })
                seen_qualities.add(height)
        
        # Process audio formats
        seen_audio = set()
        for fmt in sorted(audio_formats, key=lambda x: x.get('abr', 0), reverse=True):
            abr = fmt.get('abr', 0)
            if abr and abr not in seen_audio:
                quality_label = f"{int(abr)}kbps"
                
                processed.append({
                    'format_id': fmt['format_id'],
                    'quality': quality_label,
                    'type': 'audio',
                    'filesize': format_filesize(fmt.get('filesize') or fmt.get('filesize_approx', 0)),
                    'ext': fmt.get('ext', 'mp3')
                })
                seen_audio.add(abr)
        
        # If no formats found, add best format
        if not processed and formats:
            best = formats[-1]
            processed.append({
                'format_id': best['format_id'],
                'quality': 'best',
                'type': 'video',
                'filesize': format_filesize(best.get('filesize') or best.get('filesize_approx', 0)),
                'ext': best.get('ext', 'mp4')
            })
        
        return processed