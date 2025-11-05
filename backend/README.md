# Video Downloader Backend

Flask backend server for downloading videos using yt-dlp and ffmpeg.

## 🚀 Quick Start

### Option 1: Use the startup script (Recommended)
```powershell
.\start_server.bat
```

### Option 2: Manual setup
```powershell
# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

## 📋 Prerequisites

1. **Python 3.8+** installed
2. **FFmpeg** installed and added to PATH

### Installing FFmpeg

**Windows (using Chocolatey):**
```powershell
choco install ffmpeg
```

**Or download manually from:** https://ffmpeg.org/download.html

**Verify installation:**
```powershell
ffmpeg -version
```

## 🔌 API Endpoints

### 1. Health Check
```
GET /api/health
```
Returns server status and active downloads count.

### 2. Get Video Info
```
POST /api/info
Content-Type: application/json

Body:
{
  "url": "https://www.youtube.com/watch?v=VIDEO_ID"
}
```
Returns video title, thumbnail, duration, uploader, view count.

### 3. Get Available Formats
```
POST /api/formats
Content-Type: application/json

Body:
{
  "url": "https://www.youtube.com/watch?v=VIDEO_ID"
}
```
Returns available video and audio formats with quality options.

### 4. Download Video/Audio
```
POST /api/download
Content-Type: application/json

Body:
{
  "url": "https://www.youtube.com/watch?v=VIDEO_ID",
  "format": "video",    // or "audio"
  "quality": "best"     // or "720", "1080", etc.
}
```
Downloads the video/audio and returns download URL.

### 5. Get Downloaded File
```
GET /api/file/<filename>
```
Serves the downloaded file for streaming or download.

## 🧪 Testing

Test all endpoints:
```powershell
python test_api.py
```

Or test manually:
```powershell
# Health check
curl http://localhost:5000/api/health

# Get video info
curl -X POST http://localhost:5000/api/info -H "Content-Type: application/json" -d "{\"url\":\"https://www.youtube.com/watch?v=dQw4w9WgXcQ\"}"
```

## 📁 Project Structure

```
backend/
├── app.py              # Main Flask application
├── requirements.txt    # Python dependencies
├── start_server.bat    # Startup script (Windows)
├── test_api.py         # API testing script
├── downloads/          # Downloaded files storage
└── README.md          # This file
```

## 🎯 Features

- ✅ Download videos from 1000+ platforms (YouTube, TikTok, Instagram, Twitter, etc.)
- ✅ Multiple quality options
- ✅ Audio extraction to MP3
- ✅ Progress tracking
- ✅ CORS enabled for Flutter app
- ✅ File serving for mobile download

## 🌐 Supported Platforms

Thanks to yt-dlp, this backend supports:
- YouTube
- TikTok
- Instagram
- Twitter/X
- Facebook
- Vimeo
- Reddit
- Twitch
- Dailymotion
- And 1000+ more websites!

## 🔧 Configuration

### Default Settings
- **Port:** 5000
- **Host:** 0.0.0.0 (accessible from network)
- **Download Directory:** `./downloads`

### For Production
1. Disable debug mode in `app.py`
2. Use a production WSGI server (Gunicorn, uWSGI)
3. Set up proper logging
4. Configure firewall rules
5. Use environment variables for sensitive config

## 🐛 Troubleshooting

### Server won't start
- **Issue:** Python not found
  - **Solution:** Make sure Python 3.8+ is installed and in PATH
  
- **Issue:** Port 5000 already in use
  - **Solution:** Change port in `app.py` or kill the process using port 5000

### FFmpeg not found
- **Issue:** FFmpeg error during audio extraction
  - **Solution:** Install FFmpeg and add to PATH, then restart terminal

### Download fails
- **Issue:** yt-dlp can't download video
  - **Solution:** Update yt-dlp: `pip install -U yt-dlp`
  - Check if URL is supported
  - Check internet connection

### CORS errors from Flutter app
- **Issue:** CORS policy blocking requests
  - **Solution:** Make sure flask-cors is installed and CORS(app) is called

## 📊 Server Logs

The server outputs detailed logs including:
- Incoming requests
- Download progress
- Errors and exceptions
- File operations

Watch the terminal for real-time information.

## 🔒 Security Notes

- This is a development setup
- For production, implement:
  - Rate limiting
  - Authentication
  - Input validation
  - HTTPS/SSL
  - Request timeout limits

## 📝 Notes

- Downloaded files are stored in the `downloads` directory
- The server runs in debug mode by default
- Videos are automatically cleaned up (you may want to implement cleanup)
- Large files may take time to download and transfer

## 🆘 Support

If you encounter issues:
1. Check the server terminal logs
2. Run `python test_api.py` to diagnose
3. Verify FFmpeg is installed: `ffmpeg -version`
4. Check Python version: `python --version` (should be 3.8+)

## 📚 Dependencies

- **Flask 3.0.0** - Web framework
- **flask-cors 4.0.0** - CORS support
- **yt-dlp 2024.10.22** - Video downloader
- **Werkzeug 3.0.1** - WSGI utilities
- **requests 2.31.0** - HTTP library (for testing)

---

**Server URL:** http://localhost:5000  
**Made with ❤️ using Flask and yt-dlp**
