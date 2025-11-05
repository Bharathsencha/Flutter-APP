from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import yt_dlp
import os
import json
from pathlib import Path
import threading
import time

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app to communicate

# Directory to store downloaded videos
DOWNLOAD_DIR = os.path.join(os.getcwd(), 'downloads')
Path(DOWNLOAD_DIR).mkdir(exist_ok=True)

# Store download progress
download_progress = {}
download_tasks = {}

def create_progress_hook(download_id):
    """Create a progress hook for a specific download"""
    def progress_hook(d):
        """Hook to track download progress"""
        if d['status'] == 'downloading':
            if '_percent_str' in d:
                percent = d['_percent_str'].strip().replace('%', '')
                try:
                    progress_val = float(percent)
                except:
                    progress_val = 0
                download_progress[download_id] = {
                    'status': 'downloading',
                    'progress': progress_val,
                    'speed': d.get('_speed_str', 'N/A'),
                    'eta': d.get('_eta_str', 'N/A')
                }
        elif d['status'] == 'finished':
            download_progress[download_id] = {
                'status': 'processing',
                'progress': 95,
                'message': 'Processing downloaded file...'
            }
    return progress_hook

def download_video_task(download_id, url, ydl_opts):
    """Background task to download video"""
    try:
        # Update progress hook with the correct download_id
        ydl_opts['progress_hooks'] = [create_progress_hook(download_id)]
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            
            # Get the downloaded filename
            base_filename = ydl.prepare_filename(info)
            
            # Try different possible extensions
            possible_files = [
                base_filename,
                base_filename.rsplit('.', 1)[0] + '.mp3',
                base_filename.rsplit('.', 1)[0] + '.m4a',
                base_filename.rsplit('.', 1)[0] + '.mp4',
                base_filename.rsplit('.', 1)[0] + '.webm',
            ]
            
            filename = None
            for possible_file in possible_files:
                if os.path.exists(possible_file):
                    filename = possible_file
                    break
            
            # If still not found, search in downloads directory
            if not filename:
                title = info.get('title', 'video')
                for file in os.listdir(DOWNLOAD_DIR):
                    if title in file:
                        filename = os.path.join(DOWNLOAD_DIR, file)
                        break
            
            if filename and os.path.exists(filename):
                download_progress[download_id]['status'] = 'completed'
                download_progress[download_id]['filename'] = os.path.basename(filename)
                download_progress[download_id]['title'] = info.get('title', 'Unknown')
            else:
                download_progress[download_id]['status'] = 'error'
                download_progress[download_id]['error'] = 'File not found after download'
    except Exception as e:
        download_progress[download_id]['status'] = 'error'
        download_progress[download_id]['error'] = str(e)

@app.route('/')
def index():
    return jsonify({
        'message': 'Video Downloader API',
        'status': 'running',
        'endpoints': ['/api/info', '/api/download', '/api/formats']
    })

@app.route('/api/info', methods=['POST'])
def get_video_info():
    """Get video information without downloading"""
    try:
        data = request.get_json()
        url = data.get('url')
        
        if not url:
            return jsonify({'error': 'URL is required'}), 400
        
        ydl_opts = {
            'quiet': True,
            'no_warnings': True,
            'extract_flat': False,
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            
            # Extract relevant information
            video_info = {
                'id': info.get('id', ''),
                'title': info.get('title', 'Unknown'),
                'thumbnail': info.get('thumbnail', ''),
                'duration': info.get('duration', 0),
                'uploader': info.get('uploader', 'Unknown'),
                'view_count': info.get('view_count', 0),
                'description': info.get('description', '')[:200],  # First 200 chars
            }
            
            return jsonify(video_info)
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/formats', methods=['POST'])
def get_formats():
    """Get available formats for a video"""
    try:
        data = request.get_json()
        url = data.get('url')
        
        if not url:
            return jsonify({'error': 'URL is required'}), 400
        
        ydl_opts = {
            'quiet': True,
            'no_warnings': True,
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            
            formats = []
            seen_qualities = set()
            
            for f in info.get('formats', []):
                # Video formats
                if f.get('vcodec') != 'none' and f.get('acodec') != 'none':
                    quality = f.get('format_note', f.get('height', 'unknown'))
                    if quality not in seen_qualities:
                        formats.append({
                            'format_id': f.get('format_id'),
                            'ext': f.get('ext', 'mp4'),
                            'quality': str(quality),
                            'resolution': f"{f.get('width', 0)}x{f.get('height', 0)}",
                            'filesize': f.get('filesize', 0),
                            'type': 'video'
                        })
                        seen_qualities.add(quality)
                
                # Audio-only formats
                elif f.get('acodec') != 'none' and f.get('vcodec') == 'none':
                    quality = f.get('abr', 'unknown')
                    formats.append({
                        'format_id': f.get('format_id'),
                        'ext': f.get('ext', 'm4a'),
                        'quality': f"{quality}kbps" if quality != 'unknown' else 'audio',
                        'filesize': f.get('filesize', 0),
                        'type': 'audio'
                    })
            
            return jsonify({
                'title': info.get('title', 'Unknown'),
                'formats': formats[:10]  # Return top 10 formats
            })
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/download', methods=['POST'])
def download_video():
    """Download video/audio and return the file"""
    try:
        data = request.get_json()
        url = data.get('url', '').strip()
        format_type = data.get('format', 'video')  # 'video' or 'audio'
        quality = data.get('quality', 'best')
        duration = data.get('duration', None)  # Optional: duration in seconds
        
        if not url:
            return jsonify({'error': 'URL is required'}), 400
        
        # Ensure URL has protocol
        if not url.startswith(('http://', 'https://')):
            url = 'https://' + url
        
        # Check if FFmpeg is available
        ffmpeg_available = False
        ffmpeg_location = None
        ffmpeg_paths = [
            'ffmpeg',  # System PATH
            'C:\\ProgramData\\chocolatey\\lib\\ffmpeg\\tools\\ffmpeg\\bin\\ffmpeg.exe',  # Chocolatey
        ]
        
        for ffmpeg_path in ffmpeg_paths:
            try:
                import subprocess
                subprocess.run([ffmpeg_path, '-version'], capture_output=True, check=True)
                ffmpeg_available = True
                ffmpeg_location = ffmpeg_path if ffmpeg_path != 'ffmpeg' else None
                break
            except (FileNotFoundError, subprocess.CalledProcessError):
                continue
        
        # Configure yt-dlp options
        ydl_opts = {
            'outtmpl': os.path.join(DOWNLOAD_DIR, '%(title)s.%(ext)s'),
            'quiet': False,
            'no_warnings': False,
            'extractor_retries': 3,
            'fragment_retries': 10,
            'retries': 10,
            'nocheckcertificate': True,
            'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        }
        
        # Add duration limit if specified (for testing with short clips)
        if duration:
            ydl_opts['download_ranges'] = lambda info_dict, ydl: [{'start_time': 0, 'end_time': int(duration)}]
        
        # Add FFmpeg location if found
        if ffmpeg_location:
            ydl_opts['ffmpeg_location'] = os.path.dirname(ffmpeg_location)
        
        if format_type == 'audio':
            if ffmpeg_available:
                # Use FFmpeg to convert to MP3
                ydl_opts.update({
                    'format': 'bestaudio/best',
                    'postprocessors': [{
                        'key': 'FFmpegExtractAudio',
                        'preferredcodec': 'mp3',
                        'preferredquality': '192',
                    }],
                })
            else:
                # Download audio-only format without conversion
                ydl_opts['format'] = 'bestaudio[ext=m4a]/bestaudio/best'
        else:
            # For video formats - avoid HLS/DASH fragmented formats, prefer progressive
            if ffmpeg_available:
                # Can merge video+audio with FFmpeg, but prefer progressive formats first
                if quality == 'best':
                    ydl_opts['format'] = 'best[ext=mp4][protocol^=http]/best[protocol^=http]/bestvideo[ext=mp4][protocol^=http]+bestaudio[ext=m4a][protocol^=http]/best'
                else:
                    ydl_opts['format'] = f'best[height<={quality}][ext=mp4][protocol^=http]/best[height<={quality}][protocol^=http]/bestvideo[height<={quality}][ext=mp4][protocol^=http]+bestaudio[ext=m4a][protocol^=http]/best'
            else:
                # Download pre-merged formats only (no FFmpeg needed)
                if quality == 'best':
                    ydl_opts['format'] = 'best[ext=mp4][protocol^=http]/best[protocol^=http]/best'
                else:
                    ydl_opts['format'] = f'best[height<={quality}][ext=mp4][protocol^=http]/best[height<={quality}][protocol^=http]/best'
        
        # Get video info to generate download ID
        with yt_dlp.YoutubeDL({'quiet': True}) as ydl:
            info = ydl.extract_info(url, download=False)
            download_id = info.get('id', str(time.time()))
        
        # Initialize progress tracking
        download_progress[download_id] = {
            'status': 'starting',
            'progress': 0
        }
        
        # Start download in background thread
        thread = threading.Thread(target=download_video_task, args=(download_id, url, ydl_opts))
        thread.daemon = True
        thread.start()
        download_tasks[download_id] = thread
        
        # Return immediately with download ID
        return jsonify({
            'success': True,
            'download_id': download_id,
            'message': 'Download started'
        })
                
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/file/<filename>', methods=['GET'])
def get_file(filename):
    """Serve the downloaded file with streaming support"""
    try:
        filepath = os.path.join(DOWNLOAD_DIR, filename)
        if os.path.exists(filepath):
            # Enable streaming for large files
            return send_file(
                filepath,
                as_attachment=True,
                download_name=filename,
                conditional=True,
                max_age=0
            )
        else:
            return jsonify({'error': 'File not found'}), 404
    except Exception as e:
        print(f"Error serving file: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/progress/<video_id>', methods=['GET'])
def get_progress(video_id):
    """Get download progress for a specific video"""
    if video_id in download_progress:
        progress_data = download_progress[video_id].copy()
        # Add download URL if completed
        if progress_data.get('status') == 'completed' and 'filename' in progress_data:
            progress_data['download_url'] = f'/api/file/{progress_data["filename"]}'
        return jsonify(progress_data)
    else:
        return jsonify({'status': 'not_found'}), 404

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'downloads_dir': DOWNLOAD_DIR,
        'active_downloads': len(download_progress)
    })

if __name__ == '__main__':
    print("=" * 50)
    print("Video Downloader Backend Server")
    print("=" * 50)
    print(f"Download directory: {DOWNLOAD_DIR}")
    print("Server running on http://localhost:5000")
    print("=" * 50)
    app.run(debug=True, host='0.0.0.0', port=5000)