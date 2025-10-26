from flask import Flask
from flask_cors import CORS
from routes.video_routes import video_bp
from routes.download_routes import download_bp

app = Flask(__name__)
CORS(app)

# Register blueprints
app.register_blueprint(video_bp)
app.register_blueprint(download_bp)

@app.route('/')
def home():
    return {'message': 'Video Downloader API is running'}

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)