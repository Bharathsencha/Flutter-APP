# Video Downloader - Flutter + Python Flask

A complete video downloader application with a Flutter frontend and Python Flask backend using yt-dlp and ffmpeg.

## 🎯 Features

- ✅ Download videos from 1000+ websites (YouTube, TikTok, Instagram, Twitter, etc.)
- ✅ Audio extraction to MP3
- ✅ Multiple quality options
- ✅ Real-time download progress
- ✅ Video information preview before download
- ✅ Download history with file management
- ✅ Beautiful Material Design UI
- ✅ Cross-platform support (Android, iOS, Web, Desktop)

## 📋 Prerequisites

### Backend Requirements
- Python 3.8 or higher
- FFmpeg installed and in PATH

### Flutter Requirements
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)

## 🚀 Quick Start

### 1. Setup Backend Server

```powershell
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac

# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

The backend will start at `http://localhost:5000`

### 2. Install FFmpeg

**Windows (Chocolatey):**
```powershell
choco install ffmpeg
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

Or download manually from: https://ffmpeg.org/download.html

### 3. Setup Flutter App

```powershell
# Navigate to Flutter app directory
cd Flutter-App

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## 🔧 Configuration

### For Physical Device Testing

1. Find your computer's local IP address:
   - Windows: `ipconfig`
   - Mac/Linux: `ifconfig`

2. Update `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP_ADDRESS:5000';
// Example: 'http://192.168.1.100:5000'
```

3. Make sure your phone and computer are on the same network

## 📱 Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

For Android 11+, also add:
```xml
<application
    android:requestLegacyExternalStorage="true"
    ...>
```

## 🏗️ Project Structure

```
Flutter-App/
├── backend/
│   ├── app.py              # Flask server
│   ├── requirements.txt    # Python dependencies
│   ├── downloads/          # Downloaded files storage
│   └── README.md           # Backend documentation
│
├── lib/
│   ├── main.dart           # App entry point
│   ├── config/
│   │   └── api_config.dart # API configuration
│   ├── models/
│   │   └── video_models.dart # Data models
│   ├── services/
│   │   └── api_service.dart # API communication
│   └── screens/
│       ├── home_screen.dart       # Download interface
│       ├── downloads_screen.dart  # Download history
│       └── settings_screen.dart   # App settings
│
└── pubspec.yaml            # Flutter dependencies
```

## 🔌 API Endpoints

### Health Check
```
GET /api/health
```

### Get Video Info
```
POST /api/info
Body: { "url": "video_url" }
```

### Get Available Formats
```
POST /api/formats
Body: { "url": "video_url" }
```

### Download Video/Audio
```
POST /api/download
Body: {
  "url": "video_url",
  "format": "video",  // or "audio"
  "quality": "best"   // or "720", "1080", etc.
}
```

### Get Downloaded File
```
GET /api/file/<filename>
```

## 📦 Dependencies

### Flutter
- `http: ^1.1.0` - HTTP requests
- `dio: ^5.3.3` - Advanced HTTP client with progress tracking
- `path_provider: ^2.1.0` - File system paths
- `permission_handler: ^11.0.0` - Storage permissions
- `url_launcher: ^6.1.0` - Open URLs

### Python
- `Flask==3.0.0` - Web framework
- `flask-cors==4.0.0` - CORS support
- `yt-dlp==2024.10.22` - Video downloader
- `Werkzeug==3.0.1` - WSGI utility

## 🎨 Supported Platforms

Thanks to yt-dlp, the app supports video downloads from:
- YouTube
- TikTok
- Instagram
- Twitter/X
- Facebook
- Vimeo
- Reddit
- Dailymotion
- Twitch
- And 1000+ more websites!

## 🐛 Troubleshooting

### Backend Issues

**Port already in use:**
```python
# Change port in app.py
app.run(debug=True, host='0.0.0.0', port=5001)  # Use different port
```

**FFmpeg not found:**
- Ensure FFmpeg is installed and in PATH
- Restart terminal after installation
- Test with: `ffmpeg -version`

**Download fails:**
- Check if URL is valid and supported
- Try updating yt-dlp: `pip install -U yt-dlp`

### Flutter Issues

**Cannot connect to backend:**
- Check if backend server is running
- Verify IP address in `api_config.dart`
- Ensure devices are on same network
- Check firewall settings

**Storage permission denied:**
- Grant storage permissions in app settings
- For Android 11+, enable "All files access"

**Build errors:**
- Run `flutter clean`
- Run `flutter pub get`
- Try `flutter pub upgrade`

## 🔒 Security Notes

- This is a development setup with debug mode enabled
- For production:
  - Disable Flask debug mode
  - Use proper WSGI server (Gunicorn, uWSGI)
  - Implement rate limiting
  - Add authentication if needed
  - Use HTTPS

## 📝 License

This project is for educational purposes. Respect copyright laws and terms of service of video platforms.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions:
1. Check the troubleshooting section
2. Review backend logs in terminal
3. Check Flutter console for errors

## 🎓 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [yt-dlp Documentation](https://github.com/yt-dlp/yt-dlp)
- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)

---

Made with ❤️ using Flutter and Python
