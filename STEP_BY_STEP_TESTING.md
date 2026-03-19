# Complete End-to-End Testing Guide - CareSphere AI

## Prerequisites Checklist

- [ ] Python 3.8+ installed
- [ ] Flutter SDK installed
- [ ] Android Studio / Xcode or Emulator running
- [ ] Git cloned repository
- [ ] VS Code or preferred editor open

## Manual Testing Steps

### Phase 1: Backend Setup (Terminal 1)

#### Step 1.1: Install Backend Dependencies

```bash
cd "d:\Projects - 2\CareSphereAI - Updated\CareSphereAI - Copy\backend"
pip install -r requirements.txt
```

**Expected Output:**

```
Successfully installed Flask==2.3.0 Flask-CORS==4.0.0 ... (all packages)
```

#### Step 1.2: Start Backend Server

```bash
python app.py
```

**Expected Output:**

```
 * Running on http://127.0.0.1:5000
 * WARNING: This is a development server. Do not use it in production.
```

✅ **Backend is now running on http://localhost:5000**

---

### Phase 2: Frontend Setup (Terminal 2)

#### Step 2.1: Install Flutter Dependencies

```bash
cd "d:\Projects - 2\CareSphereAI - Updated\CareSphereAI - Copy\frontend\caresphere"
flutter pub get
```

**Expected Output:**

```
Running pub get...
Process finished with exit code 0
```

#### Step 2.2: Clean Flutter Cache (First Time Only)

```bash
flutter clean
flutter pub get
```

#### Step 2.3: List Available Devices

```bash
flutter devices
```

**Expected Output:**

```
2 connected devices:

Android SDK built for x86 (mobile)    • emulator-5554                     • android-x86    • Android 11 (API 30)
Chrome (web)                           • chrome                            • web-javascript • Chrome 90.0.0
```

Choose one device (e.g., emulator-5554 or chrome)

#### Step 2.4: Start Flutter App

```bash
flutter run -d emulator-5554
REM OR for web
flutter run -d chrome
```

**Expected Output:**

```
Launching lib/main.dart on Android SDK built for x86...
✓ Built build/app/outputs/flutter-app-release.apk
Installing and launching...
[✓] Flutter app running on device
```

✅ **App should now load on your emulator/web**

---

## Testing Scenarios

### Scenario 1: Patient Signup & Login

#### Test Steps:

1. **App Launches**
   - Landing screen appears with "CareSphere AI" title
   - "Continue" button visible
   - Expected: ✅

2. **Click Continue**
   - Opens Role Selection screen
   - 3 cards: Patient, Doctor, Caregiver
   - Login link at bottom
   - Expected: ✅

3. **Select Patient**
   - Patient Signup form opens
   - Fields: Full Name, Email, Phone, DOB, Password
   - Expected: ✅

4. **Fill Signup Form**

   ```
   Full Name: John Patient
   Email: john.patient@test.com
   Phone: +91 9876543210
   DOB: 1990-05-15
   Password: Password@123
   ```

   - All fields fill correctly
   - Expected: ✅

5. **Create Account**
   - Click "Create Account"
   - Loading indicator appears
   - Success message: "✅ Account created! Your Patient ID: CS-2026-XXXXX"
   - QR Code modal shows
   - Patient ID displayed: e.g., "CS-2026-A1B2C"
   - QR code displayed as image
   - Expected: ✅

6. **Continue from QR Screen**
   - Click "Continue" button
   - Redirects to Patient Dashboard
   - Expected: ✅

7. **Patient Dashboard**
   - Title: "Patient Dashboard"
   - Three buttons visible:
     - "Today's Medicines" 💊
     - "Check Risk" 📊
     - "SOS Emergency" 🚨
   - Logout button (top-right corner) 🚪
   - Expected: ✅

8. **Test Logout**
   - Click logout button
   - Confirmation dialog: "Are you sure you want to logout?"
   - Click "Logout"
   - Returns to Landing Screen
   - Expected: ✅

---

### Scenario 2: Doctor Signup & Certificate Upload

#### Test Steps:

1. **Back to Role Selection**
   - Click "Continue" from Landing
   - Role Selection screen

2. **Select Doctor**
   - Doctor Signup form opens
   - Fields: Full Name, Email, Phone, License#, Specialization, Password, Certificate

3. **Fill Doctor Form**

   ```
   Full Name: Dr. Jane Smith
   Email: jane.doctor@test.com
   Phone: +91 9876543211
   License Number: DL12345
   Specialization: Cardiology
   Password: Password@123
   ```

4. **Upload Certificate**
   - Click "Select File" button
   - PDF/JPG picker opens
   - Select a test image/PDF
   - File name shows: "doctor_certificate.pdf"
   - Expected: ✅

5. **Create Account**
   - Click "Create Account"
   - Loading...
   - Success: "✅ Account created! Pending license verification"
   - Certificate upload message: "✅ Certificate uploaded for verification"
   - Redirects to Doctor Dashboard
   - Expected: ✅

6. **Doctor Dashboard**
   - Title: "Doctor Clinical Dashboard"
   - Sections:
     - 📋 Medical Records (Upload button)
     - 🤖 AI Analysis (Generate AI Summary button)
     - 💊 Prescription Suggestion
     - ⏰ Assign Medicine Reminder
   - Logout button visible
   - Expected: ✅

---

### Scenario 3: Caregiver Signup & Patient Assignment

#### Test Steps:

1. **Role Selection → Caregiver**
   - Caregiver Signup form opens

2. **Fill Caregiver Form**

   ```
   Full Name: Mary Johnson
   Email: mary.caregiver@test.com
   Phone: +91 9876543212
   Relationship: Family Member (Mother)
   Patient ID: CS-2026-XXXXX (from patient signup)
   Password: Password@123
   ```

3. **Create Account**
   - Click "Create Account"
   - Success: "✅ Account created successfully!"
   - Patient assignment: "✅ Patient assigned successfully"
   - Redirects to Caregiver Dashboard
   - Expected: ✅

4. **Caregiver Dashboard**
   - Title: "Caregiver Dashboard"
   - Buttons:
     - "Upload Prescription" 📷
     - "Enter Patient Vitals" ❤️
     - "SOS Emergency" ⚠️
   - Caregiver Info card showing User ID
   - Logout button visible
   - Expected: ✅

---

### Scenario 4: Login with Existing Account

#### Test Steps:

1. **Restart App**
   - App should auto-login (token exists)
   - Should directly go to Patient Dashboard
   - Expected: ✅

2. **Or Manual Login**
   - Click "Login" from Role Selection
   - Login form: Email, Password
   - Enter: john.patient@test.com / Password@123
   - Click Login
   - Loading...
   - Auto-redirect to Patient Dashboard
   - Expected: ✅

---

### Scenario 5: Patient Dashboard Features

#### Test Steps:

1. **Today's Medicines**
   - Click "Today's Medicines"
   - Loads medicine list from backend (if medicines assigned)
   - Each medicine shows:
     - Time (Morning/Afternoon/Night)
     - Medicine name
     - Checkbox to mark taken
   - Can mark medicines as taken
   - Success message: "✅ Medicine marked as taken"
   - Expected: ✅

2. **Check Risk**
   - Click "Check Risk"
   - Goes to Vitals Screen
   - Can enter vitals for risk assessment
   - Expected: ✅

3. **SOS Emergency**
   - Click "SOS Emergency"
   - Opens SOS screen
   - Can trigger emergency
   - Expected: ✅

---

### Scenario 6: Doctor Dashboard Features

#### Test Steps:

1. **Upload Medical Record**
   - Click "Upload Medical Record"
   - Image picker opens
   - Select image/PDF
   - File uploads to backend
   - Response: "✅ Record Uploaded & Processed"
   - Expected: ✅

2. **Generate AI Summary**
   - Click "Generate AI Summary"
   - Loading indicator
   - AI summary displays
   - Expected: ✅

---

## Expected Results Summary

| Scenario            | Expected Output       | Status |
| ------------------- | --------------------- | ------ |
| App Launch          | Landing Screen        | ✅     |
| Role Selection      | 3 Role Cards          | ✅     |
| Patient Signup      | Patient ID + QR Code  | ✅     |
| Patient Dashboard   | 3 Feature Buttons     | ✅     |
| Doctor Signup       | Certificate Upload    | ✅     |
| Doctor Dashboard    | Clinical Tools        | ✅     |
| Caregiver Signup    | Patient Assignment    | ✅     |
| Caregiver Dashboard | Patient Monitoring    | ✅     |
| Login               | Auto to Dashboard     | ✅     |
| Logout              | Back to Landing       | ✅     |
| Token Persist       | Auto-login on Restart | ✅     |

---

## Common Issues & Solutions

### Issue 1: Backend Connection Error

```
❌ Error: Connection refused at http://10.32.250.87:5000
```

**Solution:**

```
1. Make sure backend is running: python app.py
2. Check IP in auth_service.dart (line 11)
3. If localhost: change to http://localhost:5000
```

### Issue 2: Flutter Pub Get Fails

```
❌ pub get: failed to verify the checksum
```

**Solution:**

```bash
flutter clean
flutter pub cache clean
flutter pub get
```

### Issue 3: QR Code Not Displaying

```
❌ QR Code blank/error
```

**Solution:**

```bash
flutter pub add qr_flutter
flutter clean
flutter pub get
```

### Issue 4: Token Decoding Error

```
❌ Error decoding token
```

**Solution:**

```
1. Verify jwt_decoder is installed: flutter pub add jwt_decoder
2. Re-run: flutter clean && flutter pub get
```

### Issue 5: Database Error

```
❌ SQLAlchemy Error: database locked
```

**Solution:**

```bash
# Delete database
rm backend/instance/caresphere.db
# Restart backend
python app.py
```

---

## Performance Metrics to Track

During testing, note these metrics:

| Operation           | Expected Time | Actual |
| ------------------- | ------------- | ------ |
| App Launch          | < 3s          | \_\_\_ |
| Role Selection Load | < 1s          | \_\_\_ |
| Signup Form Load    | < 1s          | \_\_\_ |
| Account Creation    | < 2s          | \_\_\_ |
| Login               | < 1s          | \_\_\_ |
| Dashboard Load      | < 1s          | \_\_\_ |
| Logout              | < 1s          | \_\_\_ |
| Medicine Fetch      | < 1s          | \_\_\_ |

---

## Database Testing

### Check Database After Signup

```bash
# Open SQLite browser or use terminal
sqlite3 backend/instance/caresphere.db

# Commands:
.tables                           # Show all tables
SELECT * FROM user;              # Show all users
SELECT COUNT(*) FROM user;       # Count users
SELECT unique_id, email, role FROM user;  # View user details
```

---

## API Testing (Optional - Using Postman/curl)

### Test Signup API

```bash
curl -X POST http://localhost:5000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123",
    "phone": "+91 9876543210",
    "full_name": "Test User",
    "role": "patient"
  }'
```

### Test Login API

```bash
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'
```

---

## Testing Checklist

- [ ] Backend starts without errors
- [ ] Frontend connects to backend
- [ ] App launches and shows landing screen
- [ ] Patient signup works and generates QR code
- [ ] Patient can login and see dashboard
- [ ] Doctor signup accepts certificate upload
- [ ] Caregiver can assign patient
- [ ] Logout confirmation works
- [ ] Token persists across app restart
- [ ] All buttons navigate correctly
- [ ] Error messages display properly
- [ ] Medicines load from backend
- [ ] Medical records can be uploaded
- [ ] No console errors during testing

---

## Next Steps After Successful Testing

1. ✅ All above scenarios pass
2. Create admin dashboard for doctor verification
3. Implement patient-doctor connection flow
4. Add push notifications for reminders
5. Optimize database queries
6. Add data encryption
7. Deploy to TestFlight/Play Store

---

**Created:** March 15, 2026
**Status:** Ready for Testing
**Estimated Duration:** 30-45 minutes for complete testing
