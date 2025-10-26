import sqlite3
import os
from datetime import datetime
import uuid

class DatabaseManager:
    def __init__(self):
        self.db_path = os.path.join(os.getcwd(), 'database', 'downloads.db')
        os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
        self._initialize_db()
    
    def _initialize_db(self):
        """Create tables if they don't exist"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS downloads (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                type TEXT NOT NULL,
                url TEXT NOT NULL,
                format_id TEXT NOT NULL,
                date TEXT NOT NULL,
                path TEXT
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def add_download(self, download_data):
        """Add a new download to the database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        download_id = str(uuid.uuid4())
        
        cursor.execute('''
            INSERT INTO downloads (id, title, type, url, format_id, date, path)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            download_id,
            download_data['title'],
            download_data['type'],
            download_data['url'],
            download_data['format_id'],
            download_data['date'],
            download_data.get('path', '')
        ))
        
        conn.commit()
        conn.close()
        
        return download_id
    
    def get_all_downloads(self):
        """Get all downloads from the database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, title, type, date, path
            FROM downloads
            ORDER BY date DESC
        ''')
        
        downloads = []
        for row in cursor.fetchall():
            downloads.append({
                'id': row[0],
                'title': row[1],
                'type': row[2],
                'date': row[3],
                'path': row[4]
            })
        
        conn.close()
        return downloads
    
    def delete_download(self, download_id):
        """Delete a download from the database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('DELETE FROM downloads WHERE id = ?', (download_id,))
        
        conn.commit()
        conn.close()