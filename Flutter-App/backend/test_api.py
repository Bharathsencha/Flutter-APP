"""
Test script for the Video Downloader Backend API
Run this after starting the server to verify all endpoints work
"""

import requests
import json

BASE_URL = "http://localhost:5000"
TEST_VIDEO_URL = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

def print_separator():
    print("\n" + "="*60 + "\n")

def test_health():
    """Test health check endpoint"""
    print("Testing Health Check Endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/api/health")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_video_info():
    """Test get video info endpoint"""
    print("Testing Get Video Info Endpoint...")
    try:
        response = requests.post(
            f"{BASE_URL}/api/info",
            json={"url": TEST_VIDEO_URL},
            headers={"Content-Type": "application/json"}
        )
        print(f"Status Code: {response.status_code}")
        data = response.json()
        print(f"Title: {data.get('title', 'N/A')}")
        print(f"Uploader: {data.get('uploader', 'N/A')}")
        print(f"Duration: {data.get('duration', 0)} seconds")
        print(f"View Count: {data.get('view_count', 0):,}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_formats():
    """Test get formats endpoint"""
    print("Testing Get Formats Endpoint...")
    try:
        response = requests.post(
            f"{BASE_URL}/api/formats",
            json={"url": TEST_VIDEO_URL},
            headers={"Content-Type": "application/json"}
        )
        print(f"Status Code: {response.status_code}")
        data = response.json()
        print(f"Title: {data.get('title', 'N/A')}")
        print(f"Available formats: {len(data.get('formats', []))}")
        
        # Show first 3 formats
        formats = data.get('formats', [])
        for i, fmt in enumerate(formats[:3], 1):
            print(f"  Format {i}: {fmt.get('quality')} - {fmt.get('ext')} ({fmt.get('type')})")
        
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_download():
    """Test download endpoint (without actually saving)"""
    print("Testing Download Endpoint...")
    print("⚠️  This will actually download the video!")
    print("Press Enter to continue or Ctrl+C to skip...")
    try:
        input()
    except KeyboardInterrupt:
        print("\nSkipped download test")
        return True
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/download",
            json={
                "url": TEST_VIDEO_URL,
                "format": "audio",  # Download audio to save time
                "quality": "best"
            },
            headers={"Content-Type": "application/json"},
            timeout=300  # 5 minutes timeout
        )
        print(f"Status Code: {response.status_code}")
        data = response.json()
        if data.get('success'):
            print(f"✅ Download successful!")
            print(f"Title: {data.get('title', 'N/A')}")
            print(f"Filename: {data.get('filename', 'N/A')}")
            print(f"Download URL: {data.get('download_url', 'N/A')}")
        else:
            print(f"❌ Download failed: {data.get('error', 'Unknown error')}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("="*60)
    print("Video Downloader Backend API Test Suite")
    print("="*60)
    print(f"Testing server at: {BASE_URL}")
    print(f"Test video URL: {TEST_VIDEO_URL}")
    
    results = {}
    
    print_separator()
    results['health'] = test_health()
    
    if not results['health']:
        print("\n❌ Server is not running or not accessible!")
        print("Please start the server with: python app.py")
        return
    
    print_separator()
    results['info'] = test_video_info()
    
    print_separator()
    results['formats'] = test_formats()
    
    print_separator()
    results['download'] = test_download()
    
    # Summary
    print_separator()
    print("TEST SUMMARY")
    print("-"*60)
    total = len(results)
    passed = sum(results.values())
    
    for test_name, passed_test in results.items():
        status = "✅ PASSED" if passed_test else "❌ FAILED"
        print(f"{test_name.upper()}: {status}")
    
    print("-"*60)
    print(f"Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! Backend is working correctly!")
    else:
        print("\n⚠️  Some tests failed. Check the errors above.")
    
    print_separator()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nTests interrupted by user")
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
