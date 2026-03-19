# Quick Troubleshooting Reference

## 🚨 Critical Issues & Instant Fixes

### 1. Backend Won't Start

```
Error: ModuleNotFoundError: No module named 'flask'
```

**FIX (1 min):**

```bash
cd backend
pip install -r requirements.txt
python app.py
```

### 2. Frontend Won't Compile

```
Error: Could not resolve 'flutter_secure_storage'
```

**FIX (2 min):**

```bash
cd frontend/caresphere
flutter clean
flutter pub get
flutter run
```

### 3. Can't Connect to Backend

```
Connection refused at http://localhost:5000
```

**FIX (1 min):**

- Make sure Python server is running: `python app.py` in another terminal
- Check if backend port is correct in `auth_service.dart` (line 11)
- If using emulator, use `10.0.2.2:5000` instead of `localhost:5000`

### 4. QR Code Not Showing

```
❌ QR code displays as blank/error
```

**FIX (2 min):**

```bash
cd frontend/caresphere
flutter pub add qr_flutter
flutter pub get
flutter run
```

### 5. Token Not Persisting

```
App doesn't auto-login after restart
```

**FIX (1 min):**

- Make sure `flutter_secure_storage` is installed:

```bash
flutter pub add flutter_secure_storage
```

- For Android, rebuild: `flutter clean && flutter pub get && flutter run`
- For iOS: `cd ios && pod install && cd ..`

### 6. Can't Login - Always Gets Error

```
Error: "Invalid email or password"
```

**FIX:**

1. Make sure you signed up with that email first
2. Check backend console for error details
3. Restart backend: `python app.py`

### 7. Database Locked Error

```
Error: database is locked
```

**FIX:**

```bash
# Delete corrupted database
rm backend/instance/caresphere.db
# Restart backend (new DB auto-created)
python app.py
```

### 8. Certificates/Images Not Uploading

```
Error: 400 Bad Request on certificate upload
```

**FIX:**

1. Make sure file is JPG/PNG/PDF
2. File size is < 10MB
3. Restart backend and try again
4. Check backend console for details

### 9. Medicines Not Loading

```
Empty medicine list in patient app
```

**FIX:**

1. Doctor must first assign medicines for patient
2. Patient needs assigned doctor-to-patient mapping
3. Restart backend: `python app.py`
4. Clear app cache: `flutter clean`

### 10. App Crashes on Launch

```
Unhandled Exception: type 'Null' is not a type of 'String'
```

**FIX:**

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## ⚙️ Configuration Quick Fixes

### For Running on Emulator (Android)

```bash
# If backend is on your PC, use this IP in auth_service.dart:
10.0.2.2:5000  # NOT localhost or 127.0.0.1

# File: lib/services/auth_service.dart (line 10-12)
static const String baseUrl = 'http://10.0.2.2:5000';
```

### For Running on Physical Device

```bash
# Get your PC IP address (Windows):
ipconfig

# Use this in auth_service.dart:
http://YOUR_PC_IP:5000  # Example: 192.168.1.100:5000
```

### For Web (Flutter Web)

```bash
# Make sure backend CORS is enabled (already done in app.py)
# Backend baseUrl should work as-is: http://localhost:5000
```

---

## 📱 Device-Specific Fixes

### Android Emulator Issues

```
Emulator not connecting?
1. List emulators: flutter emulators
2. Start emulator: flutter emulators --launch Pixel_API_31
3. Wait 30 seconds, then: flutter run -d emulator-5554
```

### iOS Simulator Issues

```
Pod install fails?
1. cd ios
2. pod install --repo-update
3. cd ..
4. flutter run
```

### Web Issues

```
Hot reload not working?
1. Make sure using: flutter run -d chrome
2. Try: flutter run -d chrome --web-renderer html
```

---

## 🔍 Debug Commands

### See All Errors

```bash
# Frontend
flutter run -v

# Backend
python app.py  # Errors show in real-time
```

### Check Logs

```bash
# Android
flutter logs

# See database state
cd backend
python
>>> from models import db, User
>>> users = User.query.all()
>>> for u in users: print(u.email, u.role)
```

### Validate Backend API

```bash
# Test login endpoint
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "test123"}'
```

---

## 🆘 Nuclear Options (Last Resort)

### Complete Reset - Frontend

```bash
# This deletes ALL cached data
cd frontend/caresphere
rm -r build/
rm -r .dart_tool/
flutter clean
flutter pub get
flutter run
```

### Complete Reset - Backend

```bash
# This resets database
cd backend
rm -r instance/
rm -r __pycache__/
pip install -r requirements.txt --force-reinstall
python app.py
```

### Factory Reset - Everything

```bash
# DO THIS ONLY IF NOTHING ELSE WORKS
cd frontend/caresphere
flutter clean
rm pubspec.lock
flutter pub get

cd ../../backend
rm -r __pycache__/
rm -r instance/
pip install -r requirements.txt --force-reinstall

# Restart both
python app.py  # Terminal 1
flutter run    # Terminal 2 (wait for backend to start first)
```

---

## 🎯 Testing Verification Checklist

### Before You Start

- [ ] Python 3.8+ installed: `python --version`
- [ ] Flutter installed: `flutter --version`
- [ ] Git project cloned
- [ ] VS Code open with project

### After Backend Setup

- [ ] Show: `pip install -r requirements.txt` succeeded
- [ ] Show: `python app.py` running on port 5000
- [ ] Show: No red errors in terminal

### After Frontend Setup

- [ ] Show: `flutter pub get` succeeded
- [ ] Show: `flutter run` app launching
- [ ] Show: App appears on emulator/web

### During Testing

- [ ] Successfully created patient account
- [ ] QR code displayed
- [ ] Successfully created doctor account
- [ ] Logged in successfully
- [ ] Dashboard shows correct role
- [ ] Logout works
- [ ] Token persists on restart

---

## 📊 Performance Checklist

| Component        | Should Take | Status |
| ---------------- | ----------- | ------ |
| Backend startup  | < 2s        | ✅     |
| Frontend pub get | < 1 min     | ✅     |
| App launch       | < 3s        | ✅     |
| Signup           | < 2s        | ✅     |
| Login            | < 1s        | ✅     |
| Dashboard load   | < 1s        | ✅     |
| File upload      | < 3s        | ✅     |

---

## 🔐 Security Testing

### Verify Passwords Are Hashed

```bash
cd backend
python
>>> from models import User, db
>>> user = User.query.first()
>>> print(user.password_hash)  # Should NOT be plain text
```

### Verify JWT Tokens Work

```bash
# Check token in app
# Should see decoded info like:
# {"user_id": "xyz", "role": "patient", ...}
```

---

## 💡 Pro Tips

1. **Run everything in separate terminals** - Don't try to run backend and frontend together
2. **Check backend logs first** - 90% of frontend issues are backend connection
3. **Clear Flutter cache frequently** - Saves hours of debugging
4. **Use verbose mode** - `flutter run -v` shows EVERYTHING
5. **Check email format** - Must be valid email for signup
6. **Passwords need complexity** - At least 8 chars, 1 uppercase, 1 number

---

## 📞 When All Else Fails

1. Check error message in red text
2. Copy error and search in STEP_BY_STEP_TESTING.md
3. If not found, try "Nuclear Options"
4. If still fails, save:
   - Terminal output (screenshot)
   - Error message (copy-paste)
   - Last action performed
   - Device/platform (Android/iOS/Web)

---

**Last Updated:** March 15, 2026
**Estimated Fix Time:** Most issues < 5 minutes
