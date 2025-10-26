import yt_dlp
import os
from datetime import datetime
from database.db_manager import DatabaseManager

class DownloadService:
    def __init__(self):
        self.download_dir = os.path.join(os.getcwd(), 'downloads')
        os.makedirs(self.download_dir, exist_ok=True)
        self.db = DatabaseManager()
    
    def start_download(self, url, format_id, download_type):
        try:
            # Configure yt-dlp options based on type
            if download_type == 'audio':
                ydl_opts = {
                    'format': format_id,
                    'outtmpl': os.path.join(self.download_dir, '%(title)s.%(ext)s'),
                    'postprocessors': [{
                        'key': 'FFmpegExtractAudio',
                        'preferredcodec': 'mp3',
                        'preferredquality': '192',
                    }],
                }
            else:
                ydl_opts = {
                    'format': format_id,
                    'outtmpl': os.path.join(self.download_dir, '%(title)s.%(ext)s'),
                }
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=True)
                title = info.get('title', 'Unknown')
                
                # Save to database
                self.db.add_download({
                    'title': title,
                    'type': download_type,
                    'url': url,
                    'format_id': format_id,
                    'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                })
                
                return {
                    'success': True,
                    'message': 'Download started successfully',
                    'title': title
                }
        except Exception as e:
            raise Exception(f"Download failed: {str(e)}")
    
    def get_download_history(self):
        return self.db.get_all_downloads()