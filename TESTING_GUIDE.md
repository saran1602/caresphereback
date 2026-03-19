# Quick Start Testing Guide

## Pre-requisites

### Backend

```bash
cd backend
pip install -r requirements.txt
python app.py  # Runs on http://localhost:5000
```

### Frontend

```bash
cd frontend/caresphere
flutter pub get
flutter run  # Install all dependencies first
```

## Testing Scenarios

### 1. Sign Up as Patient

**Steps:**

1. App launches → Landing Screen
2. Click "Continue"
3. Select "PATIENT" Role
4. Fill patient signup form:
   - Full Name: "John Patient"
   - Email: "john@patient.com"
   - Phone: "+91 9876543210"
   - Date of Birth: "1990-01-15"
   - Password: "password123"
5. Click "Create Account"

**Expected Results:**

- ✅ Account created
- ✅ Patient ID displayed (CS-2026-XXXXX)
- ✅ QR code shown in dialog
- ✅ Auto-redirect to Patient Dashboard
- ✅ Token saved in secure storage

### 2. Sign Up as Doctor

**Steps:**

1. App launches → Landing Screen
2. Click "Continue"
3. Select "DOCTOR" Role
4. Fill doctor signup form:
   - Full Name: "Dr. Jane Doctor"
   - Email: "jane@doctor.com"
   - Phone: "+91 9876543211"
   - License Number: "DL12345"
   - Specialization: "Cardiology"
   - Password: "password123"
5. Select certificate file
6. Click "Create Account"

**Expected Results:**

- ✅ Account created
- ✅ License marked as pending verification
- ✅ Certificate uploaded
- ✅ Auto-redirect to Doctor Dashboard
- ✅ Dashboard shows clinical features

### 3. Sign Up as Caregiver

**Steps:**

1. App launches → Landing Screen
2. Click "Continue"
3. Select "CAREGIVER" Role
4. Fill caregiver signup form:
   - Full Name: "Mary Caregiver"
   - Email: "mary@care.com"
   - Phone: "+91 9876543212"
   - Relationship: "Family Member"
   - Patient ID: (Leave empty or enter CS-2026-XXXXX)
   - Password: "password123"
5. Click "Create Account"

**Expected Results:**

- ✅ Account created
- ✅ If patient ID provided, linked automatically
- ✅ Auto-redirect to Caregiver Dashboard
- ✅ Dashboard ready for patient monitoring

### 4. Login with Existing Account

**Prerequisites:**

- Already created an account

**Steps:**

1. App with signed-up account
2. Token should auto-restore on app launch
3. Should bypass login and go directly to dashboard

**OR (Manual Login):**

1. Kill and restart app
2. Landing Screen should not appear (unless token expired/deleted)
3. If needed, clear app data to simulate first launch
4. Click "Login"
5. Enter email and password
6. Click "Login"

**Expected Results:**

- ✅ Token verified
- ✅ JWT decoded
- ✅ Role extracted
- ✅ Auto-redirect to correct dashboard

### 5. Logout Test

**Prerequisites:**

- Logged into any dashboard

**Steps:**

1. Click logout button (top-right corner)
2. Confirm logout in dialog
3. Click "Logout"

**Expected Results:**

- ✅ Confirmation dialog appears
- ✅ Token deleted from secure storage
- ✅ Redirect to Landing Screen
- ✅ Next app launch shows Landing Screen (token expired)

### 6. Dashboard Features

#### Patient Dashboard

- [ ] Today's Medicines button works
- [ ] Check Risk button works
- [ ] SOS Emergency button works
- [ ] Medicines load from backend
- [ ] Can mark medicines as taken
- [ ] Notifications schedule properly

#### Doctor Dashboard

- [ ] Upload Medical Record works
- [ ] Generate AI Summary works
- [ ] Prescription suggestion works
- [ ] Assign Reminder to Patient works
- [ ] All clinical features functional

#### Caregiver Dashboard

- [ ] Upload Prescription works
- [ ] Enter Patient Vitals works
- [ ] SOS Emergency works
- [ ] Can switch between features

## Debugging Tips

### Token Not Working

```dart
// Check token in console
AuthService authService = AuthService();
String? token = await authService.getToken();
print(token); // Should print long JWT string
```

### Can't Connect to Backend

```
1. Check IP address in auth_service.dart
2. Ensure backend running: python app.py
3. Check firewall settings
4. Try: http://localhost:5000 (if testing locally)
```

### UI Issues

```
Run: flutter clean
Then: flutter pub get
Then: flutter run
```

### Database Reset

```bash
# Backend
rm instance/caresphere.db  # This will recreate on next run
python app.py
```

## API Endpoints for Testing

### Create Patient

```bash
POST /auth/signup
{
  "email": "test@patient.com",
  "password": "test123",
  "phone": "+91 9876543210",
  "full_name": "Test Patient",
  "role": "patient",
  "date_of_birth": "1990-01-01"
}
```

### Create Doctor

```bash
POST /auth/signup
{
  "email": "test@doctor.com",
  "password": "test123",
  "phone": "+91 9876543210",
  "full_name": "Test Doctor",
  "role": "doctor",
  "license_number": "DL12345",
  "specialization": "General Practice"
}
```

### Login

```bash
POST /auth/login
{
  "email": "test@patient.com",
  "password": "test123"
}
```

### Verify Token

```bash
GET /auth/verify-token
Headers:
  Authorization: Bearer <token>
```

## Expected Behavior Summary

| Action                     | Expected Result          |
| -------------------------- | ------------------------ |
| First App Launch           | Landing Screen           |
| Click Continue             | Role Selection           |
| Select Role                | Role-Specific Signup     |
| Complete Signup            | Dashboard for that role  |
| Restart App                | Auto-login to dashboard  |
| Click Logout               | Return to Landing Screen |
| Restart App (after logout) | Landing Screen           |
| Login as Different Role    | Correct dashboard loads  |

## Performance Metrics

- Signup: < 2 seconds (with file upload for doctors)
- Login: < 1 second
- Dashboard Load: < 1 second (after cached)
- Logout: Instant
- Token Decode: < 100ms

## Known Limitations

1. Patient Name still hardcoded as "Lakshmi" in patient_reminder_screen.dart
   - TODO: Get from patient profile after login

2. Doctor verification admin panel not yet implemented
   - TODO: Create admin dashboard

3. Patient-Doctor connection UI not yet implemented
   - TODO: Create patient search/approval flow

## Success Criteria Checklist

- [ ] All 3 roles can sign up successfully
- [ ] Passwords are hashed (not visible in DB)
- [ ] Patient gets unique ID and QR code
- [ ] Doctor certificate upload works
- [ ] JWT tokens valid for 30 days
- [ ] Token stored securely
- [ ] Auto-login on app restart
- [ ] Logout clears session
- [ ] Each role sees correct dashboard
- [ ] All dashboard buttons navigate correctly
- [ ] Can mark medicines as taken
- [ ] Can upload doctor records
- [ ] Can enter vitals

---

**Created:** March 2026
**Last Updated:** March 2026
**Status:** Ready for End-to-End Testing ✅
