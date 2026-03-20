import sqlite3
import uuid
from werkzeug.security import generate_password_hash
from datetime import datetime

DB_PATH = "backend/instance/caresphere.db"

def seed():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    print("Cleaning database...")
    cursor.execute("DELETE FROM user")
    cursor.execute("DELETE FROM reminder")
    cursor.execute("DELETE FROM medication")
    
    password_hash = generate_password_hash("password123")
    now = datetime.utcnow().isoformat()

    print("Seeding users...")
    
    # 1. Doctors
    doctors = [
        ("doctor1@test.com", "Dr. Ramesh", "Cardiology"),
        ("doctor2@test.com", "Dr. Priya", "General Physician"),
        ("doctor3@test.com", "Dr. Anitha", "Pediatrics"),
    ]
    
    for email, name, spec in doctors:
        unique_id = str(uuid.uuid4())
        cursor.execute("""
            INSERT INTO user (unique_id, email, password_hash, phone, full_name, role, specialization, is_verified, is_active, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (unique_id, email, password_hash, "9876543210", name, "doctor", spec, 1, 1, now))

    # 2. Patients
    for i in range(1, 21):
        email = f"patient{i}@test.com"
        name = f"Patient {i}"
        patient_id = f"CS-2024-P{i:03d}"
        unique_id = str(uuid.uuid4())
        cursor.execute("""
            INSERT INTO user (unique_id, email, password_hash, phone, full_name, role, patient_id, is_verified, is_active, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (unique_id, email, password_hash, "9123456780", name, "patient", patient_id, 1, 1, now))

    # 3. Caregivers
    caregivers = [
        ("caregiver1@test.com", "Suresh (Caregiver)", "CS-2024-P001"),
        ("caregiver2@test.com", "Meena (Caregiver)", "CS-2024-P002"),
    ]
    
    for email, name, p_id in caregivers:
        unique_id = str(uuid.uuid4())
        cursor.execute("""
            INSERT INTO user (unique_id, email, password_hash, phone, full_name, role, assigned_patient_id, is_verified, is_active, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (unique_id, email, password_hash, "9555555555", name, "caregiver", p_id, 1, 1, now))

    print("Seeding internal reminders...")
    # Add some reminders for Patient 1
    cursor.execute("INSERT INTO reminder (patient, medicine, time, taken) VALUES (?, ?, ?, ?)", ("Patient 1", "Metformin", "08:00 AM", 0))
    cursor.execute("INSERT INTO reminder (patient, medicine, time, taken) VALUES (?, ?, ?, ?)", ("Patient 1", "Atorvastatin", "09:00 PM", 0))
    
    conn.commit()
    conn.close()
    print("Database seeded successfully via Direct SQL!")

if __name__ == "__main__":
    seed()
