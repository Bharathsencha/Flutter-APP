import yt_dlp
import os

url = 'https://www.youtube.com/watch?v=fclPhO1FsOY'

# Create downloads directory
DOWNLOAD_DIR = os.path.join(os.getcwd(), 'downloads')
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

ydl_opts = {
    'outtmpl': os.path.join(DOWNLOAD_DIR, '%(title)s.%(ext)s'),
    'quiet': False,
    'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'nocheckcertificate': True,
    'format': 'best[ext=mp4][protocol^=http]/best[protocol^=http]/bestvideo[ext=mp4][protocol^=http]+bestaudio[ext=m4a][protocol^=http]/best',
    'ffmpeg_location': 'C:\\ProgramData\\chocolatey\\lib\\ffmpeg\\tools\\ffmpeg\\bin',
}

try:
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        print(f"Testing URL: {url}")
        print("Extracting info...")
        info = ydl.extract_info(url, download=False)
        print(f"✅ Title: {info['title']}")
        print(f"✅ Formats available: {len(info['formats'])}")
        print(f"✅ Video ID: {info['id']}")
        
        print("\n🔽 Starting download...")
        info = ydl.extract_info(url, download=True)
        print(f"\n✅ Download complete!")
        print(f"✅ Saved to: {DOWNLOAD_DIR}")
        
        # List downloaded files
        files = os.listdir(DOWNLOAD_DIR)
        print(f"\n📁 Files in download directory:")
        for file in files:
            size = os.path.getsize(os.path.join(DOWNLOAD_DIR, file)) / (1024 * 1024)
            print(f"  - {file} ({size:.2f} MB)")
            
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
