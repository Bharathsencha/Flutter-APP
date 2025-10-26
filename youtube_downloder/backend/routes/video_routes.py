from flask import Blueprint, request, jsonify
from services.video_service import VideoService
import traceback

video_bp = Blueprint('video', __name__)
video_service = VideoService()

@video_bp.route('/get_video_info', methods=['POST'])
def get_video_info():
    try:
        data = request.get_json()
        url = data.get('url')
        
        if not url:
            return jsonify({'error': 'URL is required'}), 400
        
        video_info = video_service.get_video_info(url)
        return jsonify(video_info), 200
        
    except Exception as e:
        error_msg = str(e)
        print(f"Error in get_video_info: {error_msg}")
        print(traceback.format_exc())
        return jsonify({
            'error': error_msg,
            'details': traceback.format_exc()
        }), 500