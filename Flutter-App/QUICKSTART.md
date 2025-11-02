# 🚀 Quick Start Guide

## Step 1: Install FFmpeg

### Windows (using Chocolatey)
```powershell
choco install ffmpeg
```

### Or download manually
Download from https://ffmpeg.org/download.html and add to PATH

### Verify installation
```powershell
ffmpeg -version
```

## Step 2: Start Backend Server

### Windows
```powershell
cd backend
.\start_server.bat
```

### Linux/Mac
```bash
cd backend
chmod +x start_server.sh
./start_server.sh
```

The script will:
- Create virtual environment
- Install all dependencies
- Start the Flask server at http://localhost:5000

## Step 3: Configure Flutter App

### For Emulator (Android/iOS)
No changes needed - uses `localhost:5000`

### For Physical Device
1. Find your computer's IP address:
   ```powershell
   ipconfig  # Windows
   ifconfig  # Mac/Linux
   ```

2. Open `lib/config/api_config.dart`

3. Update the baseUrl:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:5000';
   // Example: 'http://192.168.1.100:5000'
   ```

4. Make sure phone and computer are on same WiFi network

## Step 4: Run Flutter App

```powershell
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Or build APK for Android
flutter build apk --release
```

## 🎯 Testing the App

1. **Start backend server** (must be running!)
2. **Open the app**
3. **Paste a video URL** (e.g., YouTube link)
4. **Select format** (Video or Audio)
5. **Click "Download Now"**
6. **Check Downloads tab** to see downloaded files

## 📱 Test URLs

Try these to test:
- YouTube: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
- Any other supported platform URL

## ⚠️ Common Issues

### Backend not starting
- Make sure Python 3.8+ is installed
- Check if port 5000 is available
- Try: `python app.py` manually

### App can't connect
- Backend server must be running
- Check IP address is correct (for physical device)
- Disable firewall temporarily to test

### Downloads fail
- Check FFmpeg is installed: `ffmpeg -version`
- URL must be supported by yt-dlp
- Check backend terminal for error messages

### Permission errors (Android)
- Go to App Settings → Permissions
- Enable Storage permission
- For Android 11+: Enable "All files access"

## 📊 Check Backend Status

Open browser and visit:
```
http://localhost:5000/api/health
```

Should see:
```json
{
  "status": "healthy",
  "downloads_dir": "...",
  "active_downloads": 0
}
```

## 🎉 You're Ready!

Now you can download videos from 1000+ platforms directly to your phone!

## 📝 Next Steps

- Customize the UI in `lib/screens/`
- Add more features in `backend/app.py`
- Configure quality presets
- Add download scheduling
- Implement user accounts

---

**Need help?** Check `SETUP_GUIDE.md` for detailed instructions.
