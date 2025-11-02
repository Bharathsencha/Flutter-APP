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

def progress_hook(d):
    """Hook to track download progress"""
    if d['status'] == 'downloading':
        download_id = d.get('info_dict', {}).get('id', 'unknown')
        if '_percent_str' in d:
            percent = d['_percent_str'].strip().replace('%', '')
            download_progress[download_id] = {
                'status': 'downloading',
                'progress': float(percent) if percent != 'Unknown' else 0,
                'speed': d.get('_speed_str', 'N/A'),
                'eta': d.get('_eta_str', 'N/A')
            }
    elif d['status'] == 'finished':
        download_id = d.get('info_dict', {}).get('id', 'unknown')
        download_progress[download_id] = {
            'status': 'finished',
            'progress': 100,
            'filename': d.get('filename', '')
        }

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
        url = data.get('url')
        format_type = data.get('format', 'video')  # 'video' or 'audio'
        quality = data.get('quality', 'best')
        
        if not url:
            return jsonify({'error': 'URL is required'}), 400
        
        # Configure yt-dlp options
        ydl_opts = {
            'outtmpl': os.path.join(DOWNLOAD_DIR, '%(title)s.%(ext)s'),
            'progress_hooks': [progress_hook],
            'quiet': False,
        }
        
        if format_type == 'audio':
            ydl_opts.update({
                'format': 'bestaudio/best',
                'postprocessors': [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192',
                }],
            })
        else:
            if quality == 'best':
                ydl_opts['format'] = 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'
            else:
                ydl_opts['format'] = f'bestvideo[height<={quality}][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'
        
        # Download the video
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            
            # Get the downloaded filename
            if format_type == 'audio':
                filename = ydl.prepare_filename(info).rsplit('.', 1)[0] + '.mp3'
            else:
                filename = ydl.prepare_filename(info)
            
            if not os.path.exists(filename):
                # Try to find the file in downloads directory
                title = info.get('title', 'video')
                for file in os.listdir(DOWNLOAD_DIR):
                    if title in file:
                        filename = os.path.join(DOWNLOAD_DIR, file)
                        break
            
            if os.path.exists(filename):
                return jsonify({
                    'success': True,
                    'filename': os.path.basename(filename),
                    'title': info.get('title', 'Unknown'),
                    'download_url': f'/api/file/{os.path.basename(filename)}'
                })
            else:
                return jsonify({'error': 'File not found after download'}), 500
                
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/file/<filename>', methods=['GET'])
def get_file(filename):
    """Serve the downloaded file"""
    try:
        filepath = os.path.join(DOWNLOAD_DIR, filename)
        if os.path.exists(filepath):
            return send_file(
                filepath,
                as_attachment=True,
                download_name=filename
            )
        else:
            return jsonify({'error': 'File not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/progress/<video_id>', methods=['GET'])
def get_progress(video_id):
    """Get download progress for a specific video"""
    if video_id in download_progress:
        return jsonify(download_progress[video_id])
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
