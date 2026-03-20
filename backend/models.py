from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
import uuid
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    unique_id = db.Column(db.String(100), unique=True, nullable=False)  # UUID for internal use
    email = db.Column(db.String(100), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    phone = db.Column(db.String(20), nullable=False)
    full_name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(20), nullable=False)  # 'patient', 'doctor', 'caregiver'
    is_verified = db.Column(db.Boolean, default=False)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Patient specific
    patient_id = db.Column(db.String(50), unique=True, nullable=True)  # Unique patient identifier
    qr_code = db.Column(db.Text, nullable=True)  # Base64 encoded QR code
    date_of_birth = db.Column(db.String(20), nullable=True)
    
    # Doctor specific
    license_number = db.Column(db.String(100), unique=True, nullable=True)
    specialization = db.Column(db.String(100), nullable=True)
    certificates = db.Column(db.Text, nullable=True)  # JSON array of certificate file paths
    is_license_verified = db.Column(db.Boolean, default=False)
    
    # Caregiver specific
    assigned_patient_id = db.Column(db.String(50), nullable=True)  # Link to patient
    relationship = db.Column(db.String(100), nullable=True)  # Relation to patient
    
    # Emergency Contact specific
    emergency_contact_name = db.Column(db.String(100), nullable=True)
    emergency_contact_phone = db.Column(db.String(20), nullable=True)
    assigned_hospital_phone = db.Column(db.String(20), nullable=True)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def generate_unique_id(self):
        self.unique_id = str(uuid.uuid4())



class Medication(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    patient = db.Column(db.String(100))
    medicine = db.Column(db.String(100))
    timing = db.Column(db.String(50))
    taken = db.Column(db.Boolean, default=False)
    diagnosis = db.Column(db.String(255), nullable=True)
    notes = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Vitals(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    patient = db.Column(db.String(100))
    sugar = db.Column(db.Integer)
    bp = db.Column(db.Integer)

class Reminder(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    patient = db.Column(db.String(100))
    medicine = db.Column(db.String(100))
    time = db.Column(db.String(50))
    taken = db.Column(db.Boolean, default=False)

class DoctorPatient(db.Model):
    """Maps doctor to patients they are treating"""
    id = db.Column(db.Integer, primary_key=True)
    doctor_id = db.Column(db.String(100), db.ForeignKey('user.unique_id'), nullable=False)
    patient_id = db.Column(db.String(100), db.ForeignKey('user.unique_id'), nullable=False)
    assigned_at = db.Column(db.DateTime, default=datetime.utcnow)

class Certificate(db.Model):
    """Stores doctor certificates for verification"""
    id = db.Column(db.Integer, primary_key=True)
    doctor_id = db.Column(db.String(100), db.ForeignKey('user.unique_id'), nullable=False)
    certificate_type = db.Column(db.String(100), nullable=False)  # e.g., 'license', 'degree'
    file_path = db.Column(db.String(255), nullable=False)
    file_name = db.Column(db.String(255), nullable=False)
    upload_date = db.Column(db.DateTime, default=datetime.utcnow)
    is_verified = db.Column(db.Boolean, default=False)
    verification_notes = db.Column(db.Text, nullable=True)