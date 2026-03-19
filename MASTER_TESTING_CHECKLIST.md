# 🎯 Master Testing Checklist

**Status:** Ready for Testing  
**Created:** March 15, 2026  
**Estimated Duration:** 45-60 minutes  
**Difficulty:** Beginner-Friendly (All steps documented)

---

## ✅ Pre-Testing Setup (5 minutes)

### Environment Requirements

- [ ] Python 3.8+ installed
- [ ] Flutter SDK installed
- [ ] Git repository cloned
- [ ] Android Studio/Xcode or Web browser ready
- [ ] Two terminals open (one for backend, one for frontend)

### Start Location

```
d:\Projects - 2\CareSphereAI - Updated\CareSphereAI - Copy\
```

---

## 🚀 Testing Execution (40-50 minutes)

### STEP 1: Start Backend (Terminal 1) - 3 minutes

```bash
# Navigate to backend directory
cd "d:\Projects - 2\CareSphereAI - Updated\CareSphereAI - Copy\backend"

# Install Python dependencies
pip install -r requirements.txt

# Start Flask server
python app.py
```

**✅ Expected Result:**

```
 * Running on http://127.0.0.1:5000
 * WARNING: This is a development server
```

**Checkpoint 1:** [ ] Backend running on port 5000

---

### STEP 2: Start Frontend (Terminal 2) - 5 minutes

```bash
# Open new terminal, navigate to frontend
cd "d:\Projects - 2\CareSphereAI - Updated\CareSphereAI - Copy\frontend\caresphere"

# Install Flutter dependencies
flutter pub get

# Clean and refresh (first time)
flutter clean
flutter pub get

# List available devices
flutter devices

# Start the app (choose one device)
flutter run -d emulator-5554  # Android emulator
# OR
flutter run -d chrome         # Web browser
# OR
flutter run -d iPhone         # iOS simulator
```

**✅ Expected Result:**

```
Launching lib/main.dart on Android SDK built for x86...
[✓] Flutter app running
```

**Checkpoint 2:** [ ] App running on emulator/simulator/web

---

## 🧪 Functional Testing (30-35 minutes)

### Test 1: App Launch & Landing Screen (2 min)

**Steps:**

1. App opens
2. Landing screen shows "CareSphere AI" title
3. "Continue" button visible
4. "Logout" link NOT visible (not logged in yet)

**✅ Expected:** Landing screen displays correctly  
**Checkpoint:** [ ] PASS

---

### Test 2: Role Selection (1 min)

**Steps:**

1. Click "Continue" button
2. Role Selection screen opens
3. Three cards visible: Patient, Doctor, Caregiver
4. "Login" link visible at bottom

**✅ Expected:** Three role options displayed  
**Checkpoint:** [ ] PASS

---

### Test 3: Patient Signup (3 min)

**Steps:**

1. Click "Patient" card
2. Patient signup form opens
3. Fields present: Full Name, Email, Phone, DOB, Password

**Fill Form:**

```
Full Name:  John Patient
Email:      john.patient@test.com
Phone:      +91 9876543210
DOB:        1990-05-15
Password:   Password@123
```

4. Click "Create Account" button
5. Loading spinner appears
6. Success message shows
7. QR Code modal displays with Patient ID (e.g., "CS-2026-A1B2C")
8. Click "Continue" in QR Code modal

**✅ Expected:**

- Patient account created
- Unique Patient ID generated
- QR code displayed
- Auto-redirect to Patient Dashboard

**Checkpoint:** [ ] PASS

---

### Test 4: Patient Dashboard - Initial Load (1 min)

**Verify:**

- [ ] Title: "Patient Dashboard"
- [ ] Button 1: "Today's Medicines 💊"
- [ ] Button 2: "Check Risk 📊"
- [ ] Button 3: "SOS Emergency 🚨"
- [ ] Logout button (🚪) visible in top-right

**✅ Expected:** Dashboard fully functional  
**Checkpoint:** [ ] PASS

---

### Test 5: Patient Dashboard - Medicine Marking (2 min)

**Steps:**

1. Click "Today's Medicines 💊"
2. Medicine list loads (or empty if none assigned)
3. If medicines exist, each shows:
   - Time (Morning/Afternoon/Night)
   - Medicine name
   - Status checkbox

4. Mark a medicine as taken (if available)
5. Verify: ✅ "Medicine marked as taken"

**✅ Expected:** Medicine screen loads and responds  
**Checkpoint:** [ ] PASS

---

### Test 6: Patient Logout (1 min)

**Steps:**

1. Click logout button (🚪)
2. Confirmation dialog: "Are you sure you want to logout?"
3. Click "Logout"
4. Token deleted from secure storage
5. Returns to Landing Screen

**✅ Expected:** Clean logout, token removed  
**Checkpoint:** [ ] PASS

---

### Test 7: Token Persistence Check (2 min)

**Steps:**

1. Close app completely
2. Restart app
3. App should **automatically** load Patient Dashboard
4. No login screen needed
5. User data persists

**✅ Expected:** Auto-login from saved token  
**Checkpoint:** [ ] PASS

---

### Test 8: Doctor Signup (3 min)

**Steps:**

1. Logout from Patient account
2. Click "Continue" on Landing
3. Role Selection → Click "Doctor"
4. Doctor signup form opens

**Fill Form:**

```
Full Name:          Dr. Jane Smith
Email:              jane.doctor@test.com
Phone:              +91 9876543211
License Number:     DL12345
Specialization:     Cardiology
Password:           Password@123
```

5. Click "Select File" (certificate field)
6. Choose any test image or PDF
7. File selected: ✅
8. Click "Create Account"
9. Loading...
10. Success: "Account created! Pending license verification"
11. Certificate uploaded: ✅

**✅ Expected:**

- Doctor account created
- Certificate uploaded for verification
- Redirect to Doctor Dashboard

**Checkpoint:** [ ] PASS

---

### Test 9: Doctor Dashboard (2 min)

**Verify:**

- [ ] Title: "Doctor Clinical Dashboard"
- [ ] Button 1: "📋 Medical Records"
- [ ] Button 2: "🤖 AI Analysis"
- [ ] Button 3: "💊 Prescription Suggestion"
- [ ] Button 4: "⏰ Assign Medicine Reminder"
- [ ] Logout button visible

**Feature Test (Optional):**

- [ ] Can upload medical record
- [ ] Can view uploaded records
- [ ] Can generate AI summary

**✅ Expected:** Doctor dashboard functional  
**Checkpoint:** [ ] PASS

---

### Test 10: Caregiver Signup (3 min)

**Steps:**

1. Logout from Doctor account
2. Landing → Continue → Role Selection
3. Click "Caregiver"
4. Caregiver signup form opens

**Fill Form:**

```
Full Name:      Mary Johnson
Email:          mary.caregiver@test.com
Phone:          +91 9876543212
Relationship:   Mother
Patient ID:     [USE PATIENT ID FROM TEST 3, e.g., CS-2026-A1B2C]
Password:       Password@123
```

5. Click "Create Account"
6. Loading...
7. Success: "Account created successfully!"
8. Patient assigned: ✅

**✅ Expected:**

- Caregiver account created
- Patient ID linked
- Redirect to Caregiver Dashboard

**Checkpoint:** [ ] PASS

---

### Test 11: Caregiver Dashboard (1 min)

**Verify:**

- [ ] Title: "Caregiver Dashboard"
- [ ] Button 1: "Upload Prescription 📷"
- [ ] Button 2: "Enter Patient Vitals ❤️"
- [ ] Button 3: "SOS Emergency ⚠️"
- [ ] Caregiver info card displayed
- [ ] Logout button visible

**✅ Expected:** Caregiver dashboard operational  
**Checkpoint:** [ ] PASS

---

### Test 12: Login Functionality (2 min)

**Steps:**

1. Logout from Caregiver
2. Landing → Continue → Role Selection
3. Click "Login" link at bottom
4. Login form opens with Email and Password fields
5. Enter credentials:
   ```
   Email:    john.patient@test.com
   Password: Password@123
   ```
6. Click "Login"
7. Loading...
8. Auto-redirect to Patient Dashboard

**✅ Expected:** Login works, correct dashboard loaded  
**Checkpoint:** [ ] PASS

---

### Test 13: Wrong Password Handling (1 min)

**Steps:**

1. Logout
2. Try login with wrong password
3. Error message displays
4. Account remains accessible after correction

**✅ Expected:** Proper error handling  
**Checkpoint:** [ ] PASS

---

---

## 📊 Final Results Summary

### System Functionality Check

| Feature             | Status            | Notes  |
| ------------------- | ----------------- | ------ |
| App Launch          | ✅ PASS / ❌ FAIL | **\_** |
| Role Selection      | ✅ PASS / ❌ FAIL | **\_** |
| Patient Signup      | ✅ PASS / ❌ FAIL | **\_** |
| QR Code Generation  | ✅ PASS / ❌ FAIL | **\_** |
| Patient Dashboard   | ✅ PASS / ❌ FAIL | **\_** |
| Doctor Signup       | ✅ PASS / ❌ FAIL | **\_** |
| Certificate Upload  | ✅ PASS / ❌ FAIL | **\_** |
| Doctor Dashboard    | ✅ PASS / ❌ FAIL | **\_** |
| Caregiver Signup    | ✅ PASS / ❌ FAIL | **\_** |
| Caregiver Dashboard | ✅ PASS / ❌ FAIL | **\_** |
| Login               | ✅ PASS / ❌ FAIL | **\_** |
| Logout              | ✅ PASS / ❌ FAIL | **\_** |
| Token Persistence   | ✅ PASS / ❌ FAIL | **\_** |
| Error Handling      | ✅ PASS / ❌ FAIL | **\_** |

### Overall Status

```
Total Tests: 13
Passed: _____ / 13
Failed: _____ / 13
Success Rate: _____%
```

---

## 🐛 Issues Found During Testing

### Issue #1

```
Description: _________________________________
Location:    _________________________________
Steps to Reproduce: _________________________________
Error Message: _________________________________
Fix Applied: _________________________________
Status: [ ] Resolved [ ] Pending
```

### Issue #2

```
Description: _________________________________
Location:    _________________________________
Steps to Reproduce: _________________________________
Error Message: _________________________________
Fix Applied: _________________________________
Status: [ ] Resolved [ ] Pending
```

### Issue #3

```
Description: _________________________________
Location:    _________________________________
Steps to Reproduce: _________________________________
Error Message: _________________________________
Fix Applied: _________________________________
Status: [ ] Resolved [ ] Pending
```

---

## 🔧 Troubleshooting Reference

If you encounter issues, see:

- **QUICK_TROUBLESHOOTING.md** - Fast 1-minute fixes
- **STEP_BY_STEP_TESTING.md** - Detailed testing guide with scenarios

---

## ✨ After Testing

### If All Tests Pass ✅

- [ ] Document any observations
- [ ] Note performance (fast/slow)
- [ ] Plan next features
- [ ] Deploy to testflight/play store

### If Some Tests Fail ❌

- [ ] Check QUICK_TROUBLESHOOTING.md
- [ ] Re-read STEP_BY_STEP_TESTING.md for that test
- [ ] Check backend logs: `python app.py` output
- [ ] Check frontend logs: `flutter run -v`
- [ ] Clear caches: `flutter clean`
- [ ] Restart backend: `python app.py`

---

## 📋 Quick Reference Commands

```bash
# Start Backend
cd backend
pip install -r requirements.txt
python app.py

# Start Frontend
cd frontend/caresphere
flutter clean
flutter pub get
flutter run -d emulator-5554

# Check Logs
flutter logs              # Frontend
# Backend logs auto-display in terminal

# Clear Everything (Nuclear Option)
flutter clean
rm pubspec.lock
flutter pub get
rm -r backend/instance
pip install -r requirements.txt --force-reinstall
```

---

## 📞 Support Resources

| Issue              | Resource                                               |
| ------------------ | ------------------------------------------------------ |
| Can't connect      | See "Backend Won't Start" in QUICK_TROUBLESHOOTING.md  |
| QR code broken     | See "QR Code Not Showing" in QUICK_TROUBLESHOOTING.md  |
| Token issues       | See "Token Not Persisting" in QUICK_TROUBLESHOOTING.md |
| Compilation errors | See STEP_BY_STEP_TESTING.md Phase 2                    |
| API errors         | Check backend terminal output                          |

---

**Testing Started:** ******\_******  
**Testing Completed:** ******\_******  
**Overall Result:** ✅ PASS / ❌ FAIL  
**Tester Name:** ******\_******  
**Date:** ******\_******

---

Good luck with testing! 🚀
