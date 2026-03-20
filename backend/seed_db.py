from app import app
from models import db, User, Reminder, Medication
from werkzeug.security import generate_password_hash
import uuid

def seed():
    with app.app_context():
        print("Cleaning database...")
        db.drop_all()
        db.create_all()

        print("Seeding users...")
        
        # 1. Doctors
        doctors = [
            {"email": "doctor1@test.com", "name": "Dr. Ramesh", "spec": "Cardiology"},
            {"email": "doctor2@test.com", "name": "Dr. Priya", "spec": "General Physician"},
            {"email": "doctor3@test.com", "name": "Dr. Anitha", "spec": "Pediatrics"},
        ]
        
        for d in doctors:
            user = User(
                email=d["email"],
                full_name=d["name"],
                phone="9876543210",
                role="doctor",
                specialization=d["spec"],
                is_verified=True,
                is_active=True
            )
            user.set_password("password123")
            user.generate_unique_id()
            db.session.add(user)

        # 2. Patients
        patients = [
            {"email": f"patient{i}@test.com", "name": f"Patient {i}", "id": f"CS-2024-P{i:03d}"}
            for i in range(1, 21)
        ]
        
        for p in patients:
            user = User(
                email=p["email"],
                full_name=p["name"],
                phone="9123456780",
                role="patient",
                patient_id=p["id"],
                is_verified=True,
                is_active=True
            )
            user.set_password("password123")
            user.generate_unique_id()
            db.session.add(user)

        # 3. Caregivers
        caregivers = [
            {"email": "caregiver1@test.com", "name": "Suresh (Caregiver)", "patient": "CS-2024-P001"},
            {"email": "caregiver2@test.com", "name": "Meena (Caregiver)", "patient": "CS-2024-P002"},
        ]
        
        for c in caregivers:
            user = User(
                email=c["email"],
                full_name=c["name"],
                phone="9555555555",
                role="caregiver",
                assigned_patient_id=c["patient"],
                is_verified=True,
                is_active=True
            )
            user.set_password("password123")
            user.generate_unique_id()
            db.session.add(user)

        # 4. Some Sample Reminders
        reminders = [
            {"patient": "Patient 1", "med": "Metformin", "time": "08:00 AM"},
            {"patient": "Patient 1", "med": "Atorvastatin", "time": "09:00 PM"},
            {"patient": "Patient 2", "med": "Amlodipine", "time": "08:00 AM"},
        ]
        
        for r in reminders:
            rem = Reminder(
                patient=r["patient"],
                medicine=r["med"],
                time=r["time"],
                taken=False
            )
            db.session.add(rem)

        db.session.commit()
        print("Database seeded successfully!")

if __name__ == "__main__":
    seed()
