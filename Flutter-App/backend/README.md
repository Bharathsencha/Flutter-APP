# Video Downloader Backend

Flask backend server for downloading videos using yt-dlp and ffmpeg.

## Prerequisites

1. **Python 3.8+** installed
2. **FFmpeg** installed and added to PATH

### Installing FFmpeg

**Windows:**
```powershell
# Using Chocolatey
choco install ffmpeg

# Or download from: https://ffmpeg.org/download.html
```

**Linux:**
```bash
sudo apt update
sudo apt install ffmpeg
```

**macOS:**
```bash
brew install ffmpeg
```

## Setup Instructions

### 1. Create Virtual Environment

```powershell
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac
```

### 2. Install Dependencies

```powershell
pip install -r requirements.txt
```

### 3. Run the Server

```powershell
python app.py
```

The server will start on `http://localhost:5000`

## API Endpoints

### 1. Health Check
```
GET /api/health
```

### 2. Get Video Info
```
POST /api/info
Body: { "url": "video_url" }
```

### 3. Get Available Formats
```
POST /api/formats
Body: { "url": "video_url" }
```

### 4. Download Video
```
POST /api/download
Body: {
  "url": "video_url",
  "format": "video",  // or "audio"
  "quality": "best"   // or "720", "1080", etc.
}
```

### 5. Get File
```
GET /api/file/<filename>
```

## Features

- ✅ Download videos from YouTube, TikTok, Instagram, Twitter, and more
- ✅ Multiple quality options
- ✅ Audio extraction (MP3)
- ✅ Progress tracking
- ✅ CORS enabled for Flutter app
- ✅ File serving

## Supported Platforms

Thanks to yt-dlp, this backend supports 1000+ websites including:
- YouTube
- TikTok
- Instagram
- Twitter/X
- Facebook
- Vimeo
- Reddit
- And many more...

## Testing

Test the API using curl or Postman:

```powershell
# Health check
curl http://localhost:5000/api/health

# Get video info
curl -X POST http://localhost:5000/api/info -H "Content-Type: application/json" -d "{\"url\":\"https://www.youtube.com/watch?v=dQw4w9WgXcQ\"}"
```

## Troubleshooting

1. **FFmpeg not found**: Make sure FFmpeg is installed and in your PATH
2. **Port already in use**: Change the port in `app.py`
3. **Download fails**: Check the URL is valid and supported by yt-dlp

## Notes

- Downloaded files are stored in the `downloads` directory
- The server runs in debug mode by default
- For production, use a proper WSGI server like Gunicorn
