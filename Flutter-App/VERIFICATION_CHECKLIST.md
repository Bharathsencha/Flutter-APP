# 📋 Setup Verification Checklist

Use this checklist to verify everything is working correctly.

## ✅ Backend Setup

- [ ] Python 3.8+ installed (`python --version`)
- [ ] FFmpeg installed (`ffmpeg -version`)
- [ ] Virtual environment created (`venv` folder exists)
- [ ] Dependencies installed (run `pip list` in venv)
- [ ] Backend server starts without errors
- [ ] Can access http://localhost:5000 in browser
- [ ] Health endpoint returns healthy status: http://localhost:5000/api/health

## ✅ Flutter Setup

- [ ] Flutter SDK installed (`flutter --version`)
- [ ] Dependencies installed (`flutter pub get` runs successfully)
- [ ] No compilation errors (`flutter analyze`)
- [ ] App builds successfully (`flutter build apk` or `flutter run`)

## ✅ Network Configuration

**If using emulator:**
- [ ] Backend running on localhost:5000
- [ ] `api_config.dart` uses `http://localhost:5000`

**If using physical device:**
- [ ] Computer and phone on same WiFi network
- [ ] Found computer's local IP address
- [ ] Updated `api_config.dart` with `http://YOUR_IP:5000`
- [ ] Can access backend from phone browser (test: http://YOUR_IP:5000/api/health)
- [ ] Windows Firewall allows Python/Flask (if on Windows)

## ✅ Permissions

**Android:**
- [ ] Permissions declared in AndroidManifest.xml
- [ ] Storage permission granted in app settings
- [ ] For Android 11+: "All files access" permission granted

**iOS:**
- [ ] Info.plist has required permissions
- [ ] Privacy settings configured

## ✅ Functional Testing

### Test 1: Backend API
```powershell
# Test video info endpoint
curl -X POST http://localhost:5000/api/info -H "Content-Type: application/json" -d "{\"url\":\"https://www.youtube.com/watch?v=dQw4w9WgXcQ\"}"
```
- [ ] Returns video information (title, thumbnail, etc.)

### Test 2: Flutter App Connection
- [ ] App launches without crashes
- [ ] Home screen loads
- [ ] No "Backend not running" warning (or warning appears if backend is off)

### Test 3: Download Flow
- [ ] Paste a video URL
- [ ] Click "Download Now"
- [ ] Video info appears with thumbnail
- [ ] Confirmation dialog shows
- [ ] Download progress shows
- [ ] Success message appears
- [ ] File appears in Downloads tab
- [ ] File can be played

### Test 4: Downloads Screen
- [ ] Downloads tab shows downloaded files
- [ ] File size displayed correctly
- [ ] Video/Audio icons show correctly
- [ ] Can delete files
- [ ] Category filters work (All/Videos/Audio)
- [ ] Refresh button works

## ✅ Platform-Specific Tests

### YouTube
- [ ] Can download YouTube videos
- [ ] Both video and audio formats work
- [ ] Different qualities work

### Other Platforms (test at least 2)
- [ ] TikTok: _____
- [ ] Instagram: _____
- [ ] Twitter: _____

## 🔧 Troubleshooting Quick Fixes

If something doesn't work:

### Backend Issues
```powershell
# Restart backend
cd backend
.\venv\Scripts\activate
python app.py
```

### Flutter Issues
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Connection Issues
```powershell
# Test backend is accessible
curl http://localhost:5000/api/health

# For physical device, test from phone browser
# http://YOUR_IP:5000/api/health
```

### Permission Issues (Android)
1. Uninstall app
2. Reinstall
3. Grant all permissions when prompted
4. Or go to Settings → Apps → Video Downloader → Permissions

## 📊 Expected Results

### Backend Terminal
```
================================================
Video Downloader Backend Server
================================================
Download directory: C:\...\downloads
Server running on http://localhost:5000
================================================
* Serving Flask app 'app'
* Debug mode: on
```

### Flutter App
- Clean UI with blue theme
- Bottom navigation with 3 tabs
- No error messages or crashes
- Smooth animations and transitions

### After Download
- Success snackbar appears
- File saved in device storage
- File appears in Downloads tab
- File can be opened/played

## ✅ Production Readiness (Optional)

If deploying to production:
- [ ] Disable Flask debug mode
- [ ] Use production WSGI server (Gunicorn)
- [ ] Set up HTTPS
- [ ] Implement rate limiting
- [ ] Add authentication
- [ ] Set up proper logging
- [ ] Configure CORS properly
- [ ] Use environment variables for config
- [ ] Set up monitoring
- [ ] Create backup system

## 🎯 Final Check

Everything working? Test this complete flow:

1. ✅ Start backend server
2. ✅ Launch Flutter app
3. ✅ Paste YouTube URL
4. ✅ Download as video
5. ✅ Check Downloads tab
6. ✅ Delete file
7. ✅ Download same URL as audio
8. ✅ Verify MP3 file created

## 📝 Notes

Document any issues you encountered and how you solved them:

---

Issue: ___________________________________
Solution: ___________________________________

---

Issue: ___________________________________
Solution: ___________________________________

---

## 🎉 All Done!

If all items are checked, your video downloader is fully functional!

**Enjoy downloading! 🚀**
