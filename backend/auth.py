from flask import request, jsonify
from models import db, User, Certificate, DoctorPatient
from werkzeug.utils import secure_filename
import jwt
import qrcode
from io import BytesIO
import base64
from datetime import datetime, timedelta
import os
from functools import wraps
import uuid

SECRET_KEY = os.getenv("JWT_SECRET", "caresphere_secret_key_2024")
ALLOWED_EXTENSIONS = {'pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'}
UPLOAD_FOLDER = 'uploads/certificates'

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def generate_patient_id():
    """Generate unique patient ID: CS-YYYY-XXXXX"""
    year = datetime.now().year
    random_part = str(uuid.uuid4().hex[:5]).upper()
    return f"CS-{year}-{random_part}"

def generate_qr_code(patient_id):
    """Generate QR code for patient ID"""
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(patient_id)
    qr.make(fit=True)
    
    img = qr.make_image(fill_color="black", back_color="white")
    buffered = BytesIO()
    img.save(buffered, format="PNG")
    img_str = base64.b64encode(buffered.getvalue()).decode()
    
    return img_str

def generate_token(user_id, role):
    """Generate JWT token"""
    payload = {
        'user_id': user_id,
        'role': role,
        'exp': datetime.utcnow() + timedelta(days=30)
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
    return token

def verify_token(token):
    """Verify JWT token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

def token_required(f):
    """Decorator to require valid token"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]
            except IndexError:
                return jsonify({"error": "Invalid token format"}), 401
        
        if not token:
            return jsonify({"error": "Token is missing"}), 401
        
        payload = verify_token(token)
        if not payload:
            return jsonify({"error": "Token is invalid or expired"}), 401
        
        request.user_id = payload['user_id']
        request.role = payload['role']
        return f(*args, **kwargs)
    
    return decorated

def role_required(required_role):
    """Decorator to check user role"""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not hasattr(request, 'role') or request.role != required_role:
                return jsonify({"error": f"This action requires {required_role} role"}), 403
            return f(*args, **kwargs)
        return decorated
    return decorator

# ================= AUTH ROUTES =================

def register_auth_routes(app):
    
    @app.route("/auth/signup", methods=["POST"])
    def signup():
        """Register a new user (Patient, Doctor, or Caregiver)"""
        data = request.json
        
        # Validate required fields
        required_fields = ['email', 'password', 'phone', 'full_name', 'role']
        if not all(field in data for field in required_fields):
            return jsonify({"error": "Missing required fields"}), 400
        
        role = data['role'].lower()
        if role not in ['patient', 'doctor', 'caregiver']:
            return jsonify({"error": "Invalid role. Must be 'patient', 'doctor', or 'caregiver'"}), 400
        
        # Check if email already exists
        if User.query.filter_by(email=data['email']).first():
            return jsonify({"error": "Email already registered"}), 409
        
        # Check if license number already exists (for doctors)
        if role == 'doctor' and data.get('license_number'):
            if User.query.filter_by(license_number=data.get('license_number')).first():
                return jsonify({"error": "License number already registered"}), 409
        
        try:
            # Create new user
            user = User()
            user.email = data['email']
            user.phone = data['phone']
            user.full_name = data['full_name']
            user.role = role
            user.generate_unique_id()
            user.set_password(data['password'])
            
            # Role-specific fields
            if role == 'patient':
                user.patient_id = generate_patient_id()
                user.qr_code = generate_qr_code(user.patient_id)
                user.date_of_birth = data.get('date_of_birth')
                user.is_verified = True  # Patients can use app immediately
                
            elif role == 'doctor':
                user.license_number = data.get('license_number')
                user.specialization = data.get('specialization')
                user.is_verified = False  # Doctors need certificate verification
                
            elif role == 'caregiver':
                user.relationship = data.get('relationship')
                user.is_verified = True  # Caregivers can use app immediately
            
            db.session.add(user)
            db.session.commit()
            
            # Generate token
            token = generate_token(user.unique_id, role)
            
            return jsonify({
                "message": "User registered successfully",
                "token": token,
                "user": {
                    "user_id": user.unique_id,
                    "email": user.email,
                    "full_name": user.full_name,
                    "role": user.role,
                    "patient_id": user.patient_id if role == 'patient' else None,
                    "qr_code": user.qr_code if role == 'patient' else None,
                    "is_verified": user.is_verified
                }
            }), 201
            
        except Exception as e:
            db.session.rollback()
            return jsonify({"error": f"Registration failed: {str(e)}"}), 500
    
    @app.route("/auth/login", methods=["POST"])
    def login():
        """Login user"""
        data = request.json
        
        if not data.get('email') or not data.get('password'):
            return jsonify({"error": "Email and password required"}), 400
        
        user = User.query.filter_by(email=data['email']).first()
        
        if not user or not user.check_password(data['password']):
            return jsonify({"error": "Invalid email or password"}), 401
        
        if not user.is_active:
            return jsonify({"error": "Account is inactive"}), 403
        
        token = generate_token(user.unique_id, user.role)
        
        return jsonify({
            "message": "Login successful",
            "token": token,
            "user": {
                "user_id": user.unique_id,
                "email": user.email,
                "full_name": user.full_name,
                "role": user.role,
                "patient_id": user.patient_id if user.role == 'patient' else None,
                "qr_code": user.qr_code if user.role == 'patient' else None,
                "is_verified": user.is_verified
            }
        }), 200
    
    @app.route("/auth/verify-token", methods=["GET"])
    @token_required
    def verify_user_token():
        """Verify if token is valid"""
        user = User.query.filter_by(unique_id=request.user_id).first()
        if not user:
            return jsonify({"error": "User not found"}), 404
        
        return jsonify({
            "valid": True,
            "user": {
                "user_id": user.unique_id,
                "email": user.email,
                "full_name": user.full_name,
                "role": user.role,
                "is_verified": user.is_verified
            }
        }), 200
    
    @app.route("/auth/user/<user_id>", methods=["GET"])
    @token_required
    def get_user_profile(user_id):
        """Get user profile"""
        user = User.query.filter_by(unique_id=user_id).first()
        
        if not user:
            return jsonify({"error": "User not found"}), 404
        
        user_data = {
            "user_id": user.unique_id,
            "email": user.email,
            "full_name": user.full_name,
            "phone": user.phone,
            "role": user.role,
            "is_verified": user.is_verified,
            "created_at": user.created_at.isoformat()
        }
        
        if user.role == 'patient':
            user_data.update({
                "patient_id": user.patient_id,
                "qr_code": user.qr_code,
                "date_of_birth": user.date_of_birth
            })
        elif user.role == 'doctor':
            user_data.update({
                "license_number": user.license_number,
                "specialization": user.specialization,
                "is_license_verified": user.is_license_verified
            })
        elif user.role == 'caregiver':
            user_data.update({
                "assigned_patient_id": user.assigned_patient_id,
                "relationship": user.relationship
            })
        
        return jsonify(user_data), 200
    
    @app.route("/auth/doctor/upload-certificate", methods=["POST"])
    @token_required
    @role_required('doctor')
    def upload_certificate():
        """Upload doctor certificate for verification"""
        if 'file' not in request.files:
            return jsonify({"error": "No file provided"}), 400
        
        file = request.files['file']
        certificate_type = request.form.get('certificate_type', 'license')
        
        if file.filename == '':
            return jsonify({"error": "No file selected"}), 400
        
        if not allowed_file(file.filename):
            return jsonify({"error": "File type not allowed. Allowed: pdf, jpg, jpeg, png, doc, docx"}), 400
        
        try:
            filename = secure_filename(file.filename)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_")
            filename = timestamp + filename
            
            file.save(os.path.join(UPLOAD_FOLDER, filename))
            
            # Save certificate info
            certificate = Certificate(
                doctor_id=request.user_id,
                certificate_type=certificate_type,
                file_name=file.filename,
                file_path=os.path.join(UPLOAD_FOLDER, filename)
            )
            
            db.session.add(certificate)
            db.session.commit()
            
            return jsonify({
                "message": "Certificate uploaded successfully",
                "certificate_id": certificate.id,
                "status": "pending_verification"
            }), 201
            
        except Exception as e:
            db.session.rollback()
            return jsonify({"error": f"Upload failed: {str(e)}"}), 500
    
    @app.route("/auth/caregiver/assign-patient", methods=["POST"])
    @token_required
    @role_required('caregiver')
    def assign_patient_to_caregiver():
        """Assign a patient to caregiver"""
        data = request.json
        patient_id = data.get('patient_id')
        
        if not patient_id:
            return jsonify({"error": "Patient ID required"}), 400
        
        # Check if patient exists
        patient = User.query.filter_by(patient_id=patient_id).first()
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        try:
            # Update caregiver's assigned patient
            caregiver = User.query.filter_by(unique_id=request.user_id).first()
            caregiver.assigned_patient_id = patient_id
            
            db.session.commit()
            
            return jsonify({
                "message": "Patient assigned successfully",
                "patient_id": patient_id,
                "patient_name": patient.full_name
            }), 200
            
        except Exception as e:
            db.session.rollback()
            return jsonify({"error": f"Assignment failed: {str(e)}"}), 500
