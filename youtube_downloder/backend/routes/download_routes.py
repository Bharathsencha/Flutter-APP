from flask import Blueprint, request, jsonify
from services.download_service import DownloadService

download_bp = Blueprint('download', __name__)
download_service = DownloadService()

@download_bp.route('/download', methods=['POST'])
def download_video():
    try:
        data = request.get_json()
        url = data.get('url')
        format_id = data.get('format_id')
        download_type = data.get('type', 'video')
        
        if not url or not format_id:
            return jsonify({'error': 'URL and format_id are required'}), 400
        
        result = download_service.start_download(url, format_id, download_type)
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@download_bp.route('/downloads', methods=['GET'])
def get_downloads():
    try:
        downloads = download_service.get_download_history()
        return jsonify(downloads), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500