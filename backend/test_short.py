import requests

# Test downloading just 30 seconds
url = "https://www.youtube.com/watch?v=SBmKOYNo5qI"

print("Starting 30-second clip download...")
response = requests.post('http://localhost:5000/api/download', json={
    'url': url,
    'format': 'video',
    'quality': 'best',
    'duration': 30  # Download only 30 seconds
})

print(f"Response: {response.json()}")

if response.status_code == 200:
    download_id = response.json()['download_id']
    print(f"Download started with ID: {download_id}")
    print("Check progress at: http://localhost:5000/api/progress/" + download_id)
else:
    print(f"Error: {response.json()}")
