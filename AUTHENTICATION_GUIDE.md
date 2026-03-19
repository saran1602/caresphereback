# CareSphere AI - Authentication System Implementation

## Overview

Complete authentication system implemented for all three stakeholders: Patient, Doctor, and Caregiver.

## Backend Implementation (Python/Flask)

### Database Models

Located in `backend/models.py`:

1. **User Model** - Core authentication model with role-based fields
   - Unique ID (UUID)
   - Email & Password (hashed with Werkzeug)
   - Phone & Full Name
   - Role (patient, doctor, caregiver)
   - Verification status

   **Patient-specific fields:**
   - Unique Patient ID (CS-YYYY-XXXXX format)
   - QR Code (Base64 encoded PNG)
   - Date of Birth

   **Doctor-specific fields:**
   - License Number
   - Specialization
   - Certificates (JSON array of file paths)
   - License Verification Status

   **Caregiver-specific fields:**
   - Assigned Patient ID (Link to patient)
   - Relationship to patient

2. **DoctorPatient Model** - Maps doctors to their patients
3. **Certificate Model** - Stores doctor certificate uploads for verification

### Authentication Routes (in `backend/auth.py`)

#### 1. **POST /auth/signup**

Create new user account

```json
{
  "email": "user@example.com",
  "password": "secure_password",
  "phone": "+91 XXXXXXXXXX",
  "full_name": "User Name",
  "role": "patient|doctor|caregiver",

  // For patients:
  "date_of_birth": "1990-01-01",

  // For doctors:
  "license_number": "DL12345",
  "specialization": "General Practice",

  // For caregivers:
  "relationship": "Family Member"
}
```

**Response:**

- Patient: Returns unique patient ID & QR code
- Doctor: Marked as pending verification until certificates uploaded
- Caregiver: Can immediately use app

#### 2. **POST /auth/login**

Login existing user

```json
{
  "email": "user@example.com",
  "password": "secure_password"
}
```

**Response:**

- Returns JWT token (valid for 30 days)
- User details including role and verification status

#### 3. **GET /auth/verify-token**

Verify JWT token validity (requires Authorization header with Bearer token)

#### 4. **GET /auth/user/<user_id>**

Get user profile details (requires valid token)

#### 5. **POST /auth/doctor/upload-certificate**

upload doctor license documents for background verification

- Accepts PDF, JPG, PNG, DOC, DOCX
- Files stored in `uploads/certificates/`
- Status: pending_verification until admin verifies

#### 6. **POST /auth/caregiver/assign-patient**

Caregiver assigns themselves to a patient using patient ID

## Frontend Implementation (Flutter)

### New Files Created

1. **auth_service.dart** - Authentication service
   - Handles all API calls to backend
   - Token management (save/retrieve/delete)
   - Methods: signup, login, verify, uploadCertificate, assignPatient

2. **login_screen.dart** - Login UI
   - Email and password input
   - Form validation
   - Error handling and feedback

3. **patient_signup_screen.dart** - Patient registration
   - Full name, email, phone, DOB
   - Displays QR code and patient ID after signup
   - Date picker for DOB

4. **doctor_signup_screen.dart** - Doctor registration
   - License number and specialization
   - File picker for certificate upload
   - Shows pending verification status

5. **caregiver_signup_screen.dart** - Caregiver registration
   - Relationship to patient field
   - Optional patient ID assignment
   - Can assign after account creation

### Authentication Flow

```
Landing Screen
    ↓
Continue Button
    ↓
Role Selection Screen
    ├─ Patient → Patient Signup → QR Code Display
    ├─ Doctor → Doctor Signup → Certificate Upload → Pending Verification
    └─ Caregiver → Caregiver Signup → Patient Assignment (Optional)

OR
    ↓
Login Screen (Existing Users)
```

### Token Storage

- Tokens stored securely using `flutter_secure_storage`
- Automatic verification on app launch
- Auto-login if valid token exists
- Token cleared on logout

### Dependencies Added to pubspec.yaml

- `flutter_secure_storage`: Secure token storage
- `file_picker`: Certificate upload for doctors
- `qr_flutter`: QR code generation/display
- `jwt_decoder`: JWT token decoding

## Security Features

1. **Password Security**
   - Passwords hashed using Werkzeug (PBKDF2)
   - Never stored in plain text
   - Only sent over HTTPS (production)

2. **Token Security**
   - JWT tokens with 30-day expiration
   - Tokens stored in secure storage
   - Token verified on app launch

3. **Role-Based Access**
   - Doctor certificates require verification
   - Patients get instant access
   - Caregivers verified by assignment

4. **Patient Privacy**
   - Unique QR code per patient
   - Encrypted patient ID format
   - Caregiver access limited to assigned patients

## Database Setup

Run migrations after adding models:

```python
from app import app, db
with app.app_context():
    db.create_all()
```

## API Testing

Use Postman or similar tool:

### Sign up as Patient

```
POST /auth/signup
{
  "email": "patient@example.com",
  "password": "password123",
  "phone": "+91 9876543210",
  "full_name": "Rajesh Kumar",
  "role": "patient",
  "date_of_birth": "1990-05-15"
}
```

### Sign up as Doctor

```
POST /auth/signup
{
  "email": "doctor@example.com",
  "password": "password123",
  "phone": "+91 9876543210",
  "full_name": "Dr. Priya Sharma",
  "role": "doctor",
  "license_number": "DL12345",
  "specialization": "General Practice"
}
```

### Upload Certificate (Doctor)

```
POST /auth/doctor/upload-certificate
Header: Authorization: Bearer <token>
Form-data:
  - file: [certificate PDF/image]
  - certificate_type: "license"
```

## Next Steps / TODO

1. **Authentication UI Polish**
   - [ ] Add form validation with detailed error messages
   - [ ] Implement password strength indicator
   - [ ] Add "Remember me" checkbox for login

2. **Token Handling**
   - [ ] Decode JWT to get role and userId
   - [ ] Implement token refresh before expiration
   - [ ] Add logout functionality to all dashboards

3. **Doctor Verification**
   - [ ] Create admin dashboard to verify certificates
   - [ ] Send email notifications on verification status
   - [ ] Create pending verification screen for doctors

4. **Patient-Doctor Connection**
   - [ ] Allow doctors to search and add patients by QR/patient ID
   - [ ] Create approval request system
   - [ ] Show patient's assigned doctors in dashboard

5. **Caregiver Features**
   - [ ] Display caregiver dashboard with assigned patient
   - [ ] Allow caregiver to view patient vitals/medications
   - [ ] Caregiver can remind patient to take medicines

6. **Security Enhancements**
   - [ ] Add email verification
   - [ ] Implement 2FA for doctors
   - [ ] Rate limiting on login attempts
   - [ ] HTTPS enforcement in production

7. **Error Handling**
   - [ ] Comprehensive error messages
   - [ ] Network error handling
   - [ ] Offline mode support

8. **Navigation**
   - [ ] Complete role-based dashboard routing
   - [ ] Bottom navigation with logout
   - [ ] Profile edit screens for all roles

## Configuration

### Backend (.env)

```
JWT_SECRET=your_secret_key_here
FLASK_ENV=development
DATABASE_URL=sqlite:///caresphere.db
```

### Frontend

- Base URL: `http://10.32.250.87:5000` (update based on server IP)
- Can be moved to config file

## File Structure

```
Backend:
├── auth.py (NEW - Authentication routes)
├── models.py (UPDATED - User models)
├── app.py (UPDATED - Register auth routes)
└── requirements.txt (UPDATED - New dependencies)

Frontend:
├── auth_service.dart (NEW - Auth service)
├── login_screen.dart (NEW - Login UI)
├── patient_signup_screen.dart (NEW - Patient signup)
├── doctor_signup_screen.dart (NEW - Doctor signup)
├── caregiver_signup_screen.dart (NEW - Caregiver signup)
├── main.dart (UPDATED - Auth wrapper)
├── role_screen.dart (UPDATED - Auth flow)
└── pubspec.yaml (UPDATED - Dependencies)
```

## Testing Credentials

After creating accounts, use these to test:

- Email: [as created]
- Password: [as created]
- Role-based features will be different per user type

## Support & Troubleshooting

1. **App not connecting to backend?**
   - Check IP address in `auth_service.dart`
   - Ensure backend is running on port 5000
   - Check firewall settings

2. **QR code not displaying?**
   - Ensure `qr_flutter` package is properly installed
   - Run `flutter pub get`

3. **File upload not working?**
   - Check `UPLOAD_FOLDER` path exists
   - Verify `ALLOWED_EXTENSIONS` in auth.py
   - Check file permissions

---

**Last Updated:** March 2026
**Status:** Core authentication ready, role-based features in development
