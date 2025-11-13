# 🗄️ Database Schema Documentation

## Overview

The app uses **SQLite** for local data storage with two main tables: `users` and `downloads`. The database is automatically created when the app first runs.

---

## Database File Location

### File Path
```
/data/data/com.example.video_downloader/databases/user_auth.db
# (or your app's package name instead of com.example.video_downloader)
```

### How to Access the Database

#### Option 1: Android Studio Device File Explorer (Easiest for Emulator)
1. Open your app in Android Studio emulator or connected device
2. Go to **View** → **Tool Windows** → **Device File Explorer**
3. Navigate to: `/data/data/com.example.video_downloader/databases/`
4. Right-click `user_auth.db` → **Save As** to download to your computer
5. Open with SQLite browser (DB Browser for SQLite, etc.)

#### Option 2: Using ADB (Android Debug Bridge)

**For Windows PowerShell:**

```powershell
# Navigate to your project folder
cd "c:\Users\vinay\Desktop\Flutter-APP\Flutter-App"

# Pull the database file (debuggable build)
adb exec-out run-as com.example.video_downloader cat databases/user_auth.db > user_auth.db

# Alternative if exec-out fails:
adb shell "run-as com.example.video_downloader cat /data/data/com.example.video_downloader/databases/user_auth.db" > user_auth.db
```

After running, `user_auth.db` will be in your project root folder and can be opened with any SQLite tool.

**For Mac/Linux Terminal:**
```bash
adb exec-out run-as com.example.video_downloader cat databases/user_auth.db > user_auth.db
```

---

## Database Schema

### TABLE 1: `users`

Stores user account information.

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL
)
```

#### Columns:

| Column Name | Type | Constraints | Description |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique user identifier (auto-generated) |
| `name` | TEXT | NOT NULL | User's full name |
| `email` | TEXT | UNIQUE, NOT NULL | User's Gmail address (must be unique) |
| `password` | TEXT | NOT NULL | User's password (stored as plain text) |

#### Example Data:
```
id  | name              | email                | password
----|-------------------|----------------------|-----------
1   | John Doe          | john@gmail.com       | pass1234
2   | Jane Smith        | jane.smith@gmail.com | secure567
3   | Bob Johnson       | bob.j@gmail.com      | mypass999
```

#### Constraints:
- ✅ `email` must be unique (no two users can have the same email)
- ✅ `id` auto-increments starting from 1
- ✅ All fields are required (NOT NULL)

---

### TABLE 2: `downloads`

Tracks download history for each user.

```sql
CREATE TABLE downloads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userId INTEGER NOT NULL,
  filename TEXT NOT NULL,
  filepath TEXT NOT NULL,
  type TEXT NOT NULL,
  downloadedAt TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
)
```

#### Columns:

| Column Name | Type | Constraints | Description |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique download record ID |
| `userId` | INTEGER | NOT NULL, FOREIGN KEY | References `users.id` (user who downloaded) |
| `filename` | TEXT | NOT NULL | Name of downloaded file (e.g., "video.mp4") |
| `filepath` | TEXT | NOT NULL | Full path to file on device storage |
| `type` | TEXT | NOT NULL | "video" or "audio" |
| `downloadedAt` | TEXT | NOT NULL | ISO 8601 timestamp (e.g., "2025-11-13T14:30:00.000") |

#### Example Data:
```
id | userId | filename              | filepath                           | type  | downloadedAt
---|--------|----------------------|-----------------------------------|-------|---------------------------
1  | 1      | tutorial.mp4         | /storage/emulated/0/Downloads/... | video | 2025-11-13T10:15:00.000
2  | 1      | music.mp3            | /storage/emulated/0/Downloads/... | audio | 2025-11-13T11:20:00.000
3  | 2      | podcast.m4a          | /storage/emulated/0/Downloads/... | audio | 2025-11-13T12:45:00.000
4  | 1      | documentary.mkv      | /storage/emulated/0/Downloads/... | video | 2025-11-13T14:00:00.000
```

#### Constraints:
- ✅ `userId` is a **Foreign Key** pointing to `users.id`
- ✅ **ON DELETE CASCADE**: When a user is deleted, all their downloads are automatically deleted
- ✅ All fields are required (NOT NULL)

---

## Relationships

### One-to-Many Relationship

```
users (1) ──────── (Many) downloads
   ↓
User John (id=1) has multiple downloads:
  ├─ tutorial.mp4 (id=1)
  ├─ music.mp3 (id=2)
  └─ documentary.mkv (id=4)

User Jane (id=2) has one download:
  └─ podcast.m4a (id=3)
```

### Foreign Key Constraint

- **Users and Downloads are linked by `userId`**
- If a user is deleted → all their downloads are automatically deleted (CASCADE)
- Cannot create a download record with a non-existent `userId`

---

## How Data Works in the App

### When User Signs Up:
```
1. User enters: name, email, password (must be @gmail.com, min 8 chars)
2. App validates: email format, password length, email uniqueness
3. INSERT into users table:
   INSERT INTO users (name, email, password) 
   VALUES ('John Doe', 'john@gmail.com', 'password123')
4. User gets auto-generated `id` (e.g., 1)
5. User is logged in
```

### When User Downloads a File:
```
1. User downloads video/audio from backend API
2. File is saved to device storage: /storage/emulated/0/Downloads/...
3. App records in downloads table:
   INSERT INTO downloads (userId, filename, filepath, type, downloadedAt)
   VALUES (1, 'video.mp4', '/path/to/video.mp4', 'video', '2025-11-13T14:30:00')
4. Download appears in Downloads screen
5. Only visible to that user (filtered by userId)
```

### When User Logs In:
```
1. User enters email + password
2. App queries:
   SELECT * FROM users WHERE email = ? AND password = ?
3. If found → user is logged in
4. Downloads screen shows only their downloads:
   SELECT * FROM downloads WHERE userId = ? ORDER BY downloadedAt DESC
```

### When User Deletes Account:
```
1. User clicks "Delete Account" button
2. App shows confirmation dialogs
3. App deletes:
   - All download records: DELETE FROM downloads WHERE userId = ?
   - User account: DELETE FROM users WHERE id = ?
4. Due to CASCADE delete, step 3a also happens automatically
5. User is logged out → redirected to login screen
```

---

## Manually Deleting Data

### Option 1: Using SQLite Browser

1. Download database file (see "How to Access the Database" above)
2. Open with **DB Browser for SQLite** (free tool: https://sqlitebrowser.org/)
3. Click **Browse Data** tab
4. Select table: `users` or `downloads`
5. Right-click row → **Delete record**
6. Click **Write changes** to save

### Option 2: Using SQL Commands in DB Browser

**Delete a specific user and all their downloads:**
```sql
DELETE FROM users WHERE id = 1;
-- Downloads are auto-deleted due to CASCADE constraint
```

**Delete all downloads for a user without deleting the user:**
```sql
DELETE FROM downloads WHERE userId = 1;
```

**Delete a specific download record:**
```sql
DELETE FROM downloads WHERE id = 3;
```

**View all users:**
```sql
SELECT * FROM users;
```

**View all downloads for a user:**
```sql
SELECT * FROM downloads WHERE userId = 1;
```

### Option 3: Using ADB Shell (Advanced)

```bash
# Push database back after editing
adb push user_auth.db /data/data/com.example.video_downloader/databases/user_auth.db

# Or execute SQL directly
adb shell sqlite3 /data/data/com.example.video_downloader/databases/user_auth.db "DELETE FROM users WHERE id = 1;"
```

---

## SQL Queries Reference

### User Operations

**Create user (app does this):**
```sql
INSERT INTO users (name, email, password) 
VALUES ('John Doe', 'john@gmail.com', 'password123');
```

**Login user:**
```sql
SELECT * FROM users WHERE email = 'john@gmail.com' AND password = 'password123';
```

**Check if email exists:**
```sql
SELECT COUNT(*) FROM users WHERE email = 'john@gmail.com';
-- Returns 1 if exists, 0 if not
```

**Update user profile:**
```sql
UPDATE users SET name = 'Jane Doe' WHERE id = 1;
```

**Delete user (and all downloads due to CASCADE):**
```sql
DELETE FROM users WHERE id = 1;
```

---

### Download Operations

**Add download record (app does this):**
```sql
INSERT INTO downloads (userId, filename, filepath, type, downloadedAt)
VALUES (1, 'video.mp4', '/path/to/video.mp4', 'video', '2025-11-13T14:30:00');
```

**Get all downloads for user (app does this):**
```sql
SELECT * FROM downloads WHERE userId = 1 ORDER BY downloadedAt DESC;
```

**Get videos only:**
```sql
SELECT * FROM downloads WHERE userId = 1 AND type = 'video';
```

**Get audio only:**
```sql
SELECT * FROM downloads WHERE userId = 1 AND type = 'audio';
```

**Delete a download:**
```sql
DELETE FROM downloads WHERE id = 5;
```

**Delete all downloads for a user:**
```sql
DELETE FROM downloads WHERE userId = 1;
```

---

## Data Privacy & Security Notes

### Current State (Development)
⚠️ **Passwords are stored in PLAIN TEXT** - suitable only for learning/development

### For Production:
1. **Hash passwords**: Use `bcrypt` or `argon2`
   ```python
   # Example: Python backend should hash
   from werkzeug.security import generate_password_hash
   hashed = generate_password_hash('password123')
   ```

2. **Encrypt database**: Use encrypted SQLite or Flutter's secure storage
3. **Validate emails**: Send verification code before storing
4. **Use HTTPS**: For API communication
5. **Rate limiting**: Prevent brute force attacks
6. **Activity logging**: Track logins and deletions

---

## Backup & Recovery

### Backup Database
```bash
# Pull backup to your computer
adb pull /data/data/com.example.video_downloader/databases/user_auth.db ./backup_user_auth.db
```

### Restore Database
```bash
# Push backup back to device
adb push ./backup_user_auth.db /data/data/com.example.video_downloader/databases/user_auth.db

# Restart app to load restored database
```

---

## Common Issues & Solutions

### Issue: "No such table: downloads"
**Cause**: App was installed before downloads table was added
**Solution**: 
1. Uninstall app: `adb uninstall com.example.video_downloader`
2. Delete build cache: `flutter clean`
3. Rebuild: `flutter run`

### Issue: "database is locked"
**Cause**: App is accessing database while you're trying to edit it
**Solution**: 
1. Close app
2. Edit database
3. Reopen app

### Issue: Foreign key constraint fails
**Cause**: Trying to add download with non-existent userId
**Solution**: Ensure userId exists in users table first

---

## Tools for Viewing/Editing Database

### Recommended (Free & Easy):
- **DB Browser for SQLite** (Windows/Mac/Linux)
  - Download: https://sqlitebrowser.org/
  - UI-based, no SQL knowledge needed
  - Can edit directly in the app

### Command Line:
- **sqlite3** CLI (comes with most systems)
  ```bash
  sqlite3 user_auth.db
  sqlite> SELECT * FROM users;
  sqlite> .quit
  ```

### Android Studio Built-in:
- **Database Inspector** (Android Studio 4.1+)
- View real-time database changes while app is running

---

## Summary

| Aspect | Details |
|--------|---------|
| **Database Type** | SQLite |
| **File Name** | `user_auth.db` |
| **Tables** | 2 (users, downloads) |
| **Max Users** | Unlimited |
| **Max Downloads per User** | Unlimited |
| **Auto-Delete** | Users → Downloads (CASCADE) |
| **Password Encryption** | None (plain text) ⚠️ |
| **Backup** | Use adb pull/push |

---

## Next Steps

1. ✅ Implement per-user downloads (DONE)
2. ✅ Delete user account feature (DONE)
3. 📋 Future: Add password hashing
4. 📋 Future: Add email verification
5. 📋 Future: Sync with backend database

---

**Last Updated**: November 13, 2025
**Status**: ✅ Ready for Development & Testing
