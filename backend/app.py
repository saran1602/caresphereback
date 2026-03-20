from flask import Flask, request, jsonify
from flask_cors import CORS
from models import db, Medication, Vitals, Reminder, User, DoctorPatient
from auth import register_auth_routes
from risk_model import predict_risk
try:
    from ocr_service2 import extract_text, structure_medical_text
except ImportError:
    print("⚠️ OCR service unavailable (tesseract not installed)")
    def extract_text(path): return "OCR unavailable on this server"
    def structure_medical_text(text): return {"patient_name": "Unknown", "diagnosis": "N/A", "medicines": [], "vitals": {}, "lab_results": []}
from twilio.rest import Client
import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize OpenAI client globally if key exists
openai_client = None
if os.getenv("OPENAI_API_KEY"):
    openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///caresphere.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

with app.app_context():
    db.create_all()

# Register authentication routes
register_auth_routes(app)

# ================= TWILIO CONFIG =================

account_sid = os.getenv("TWILIO_ACCOUNT_SID")
auth_token = os.getenv("TWILIO_AUTH_TOKEN")

twilio_client = None
try:
    if account_sid and auth_token:
        twilio_client = Client(account_sid, auth_token)
except Exception as e:
    print(f"⚠️ Twilio init failed (non-fatal): {e}")

TWILIO_NUMBER = os.getenv("TWILIO_PHONE")
HOSPITAL_NUMBER = os.getenv("HOSPITAL_NUMBER")
AMBULANCE_NUMBER = os.getenv("AMBULANCE_NUMBER")
# ================= EMERGENCY FUNCTION =================

def trigger_emergency(patient_unique_id, sugar, bp, heart_rate=None, pulse=None):
    # Fetch patient and their emergency contacts
    patient = User.query.filter_by(unique_id=patient_unique_id).first()
    if not patient:
        print(f"❌ Emergency Error: Patient {patient_unique_id} not found")
        return

    hospital_number = patient.assigned_hospital_phone or HOSPITAL_NUMBER
    emergency_contact = patient.emergency_contact_phone
    
    msg = f"""
🚨 CRITICAL PATIENT ALERT
Patient: {patient.full_name} ({patient.patient_id})
Sugar Level: {sugar}
BP: {bp}
Heart Rate: {heart_rate or 'NA'}
Pulse: {pulse or 'NA'}
Immediate Attention Required
"""

    # Send SMS to Hospital
    try:
        if twilio_client:
            sms = twilio_client.messages.create(
            body=msg,
            from_=TWILIO_NUMBER,
            to=hospital_number
        )
        print(f"✅ SMS SENT TO HOSPITAL ({hospital_number}):", sms.sid)
    except Exception as e:
        print("❌ HOSPITAL SMS ERROR:", e)

    # Send SMS to Emergency Contact if exists
    if emergency_contact:
        try:
            sms = twilio_client.messages.create(
                body=f"🚨 EMERGENCY: {patient.full_name} needs help. {msg}",
                from_=TWILIO_NUMBER,
                to=emergency_contact
            )
            print(f"✅ SMS SENT TO CONTACT ({emergency_contact}):", sms.sid)
        except Exception as e:
            print("❌ CONTACT SMS ERROR:", e)

    # Trigger Call to Ambulance/Hospital
    try:
        call = twilio_client.calls.create(
            twiml=f'<Response><Say>Emergency alert for patient {patient.full_name}. Immediate response requested.</Say></Response>',
            from_=TWILIO_NUMBER,
            to=hospital_number
        )
        print("✅ CALL SENT:", call.sid)
    except Exception as e:
        print("❌ CALL ERROR:", e)

# ================= ROUTES =================
@app.route("/", methods=["GET"])
def health_check():
    return jsonify({"status": "live", "message": "CareSphere AI Backend is running"}), 200

@app.route("/emergency", methods=["POST"])
def emergency():
    data = request.form or request.json
    
    patient_id = data.get("patient_unique_id")
    sugar = data.get("sugar", "NA")
    bp = data.get("bp", "NA")
    heart_rate = data.get("heart_rate")
    pulse = data.get("pulse")

    if not patient_id:
        # Fallback for old clients or manual triggers
        patient_name = data.get("patient_name", "Unknown")
        trigger_emergency_legacy(patient_name, sugar, bp)
        return jsonify({"status": "Emergency Triggered (Legacy Mode)"})

    trigger_emergency(patient_id, sugar, bp, heart_rate, pulse)
    return jsonify({"status": "Emergency Triggered"})

def trigger_emergency_legacy(patient_name, sugar, bp):
    msg = f"🚨 LEGACY ALERT: Patient {patient_name}, Sugar {sugar}, BP {bp}"
    try:
        if twilio_client:
            twilio_client.messages.create(body=msg, from_=TWILIO_NUMBER, to=HOSPITAL_NUMBER)
    except: pass



@app.route("/upload_prescription", methods=["POST"])
def upload_prescription():
    file = request.files.get("file")
    if not file:
        return jsonify({"error": "No file uploaded"}), 400
    path = "temp_upload.jpg"
    file.save(path)
    text = extract_text(path)
    return jsonify({"extracted_text": text})


@app.route("/doctor_upload_record", methods=["POST"])
def doctor_upload_record():
    """
    Full pipeline: upload image → Vision OCR → structure with GPT-4o → return JSON.
    Works on Render without Tesseract.
    """
    import os
    file = request.files.get("file")
    if not file:
        return jsonify({"error": "No file uploaded"}), 400

    path = "doctor_temp.jpg"
    try:
        file.save(path)

        # Step 1: Extract text via Vision API (or fallback)
        raw_text = extract_text(path)

        # Step 2: Structure the text into medical JSON (or fallback)
        structured = structure_medical_text(raw_text)

        # Make sure it's a dict
        if isinstance(structured, str):
            import json as _json
            try:
                structured = _json.loads(structured)
            except Exception:
                structured = {"raw_text": structured}

        return jsonify({
            "message": "Record processed successfully",
            "extracted_text": raw_text,
            "structured_data": structured
        })
    except Exception as e:
        print(f"❌ Upload record error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        try:
            if os.path.exists(path):
                os.remove(path)
        except Exception:
            pass


@app.route("/add_medication", methods=["POST"])
def add_med():

    data = request.json

    med = Medication(
        patient=data["patient"],
        medicine=data["medicine"],
        timing=data["timing"]
    )

    db.session.add(med)
    db.session.commit()

    return jsonify({"message": "Medication Added"})

@app.route("/add_vitals", methods=["POST"])
def add_vitals():

    data = request.json

    v = Vitals(
        patient=data["patient"],
        sugar=data["sugar"],
        bp=data["bp"]
    )

    db.session.add(v)
    db.session.commit()

    return jsonify({"message": "Vitals Added"})

@app.route("/predict_risk", methods=["POST"])
def risk():

    data = request.json

    result = predict_risk(
        data["sugar"],
        data["bp"],
        data["missed"]
    )

    # 🚨 AUTO EMERGENCY TRIGGER
    if result == "CRITICAL":
        trigger_emergency(
            data["patient"],
            data["sugar"],
            data["bp"]
        )

    return jsonify({"risk": result})

@app.route("/assign_reminder", methods=["POST"])
def assign_reminder():

    data = request.json

    r = Reminder(
        patient=data["patient"],
        medicine=data["medicine"],
        time=data["time"]
    )

    db.session.add(r)
    db.session.commit()

    return jsonify({"message": "Reminder Assigned"})

@app.route("/get_reminders/<patient>")
def fetch_reminders(patient):
    try:
        reminders = Reminder.query.filter_by(patient=patient).all()

        output = []
        for r in reminders:
            output.append({
                "id": r.id,
                "medicine": r.medicine,
                "time": r.time,
                "taken": r.taken
            })

        return jsonify(output)
    except Exception as e:
        print(f"❌ Error fetching reminders: {e}")
        return jsonify({"reminders": [], "error": str(e)}), 500

@app.route("/mark_medicine_taken", methods=["POST"])
def mark_medicine_taken():
    try:
        data = request.json
        rem_id = data.get("id")
        taken = data.get("taken")

        r = Reminder.query.get(rem_id)
        if r:
            r.taken = taken
            db.session.commit()
            return jsonify({"message": "Reminder status updated"})
        
        return jsonify({"error": "Reminder not found"}), 404
    except Exception as e:
        print(f"❌ Error updating reminder status: {e}")
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route("/doctor_upload_record", methods=["POST"])
def doctor_upload_record():
    try:
        if "file" not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        file = request.files["file"]
        path = "doctor_upload_temp.jpg"
        file.save(path)

        # Perform OCR
        raw_text = extract_text(path)
        
        # Structure with AI
        structured_data = structure_medical_text(raw_text)

        # Cleanup
        if os.path.exists(path):
            os.remove(path)

        return jsonify({
            "raw_text": raw_text,
            "structured_data": structured_data
        })
    except Exception as e:
        print(f"❌ Error in doctor_upload_record: {e}")
        return jsonify({"error": str(e), "message": "Backend processing failed"}), 500

@app.route("/doctor_ai_summary", methods=["POST"])
def doctor_ai_summary():
    try:
        data = request.json

        # Sync keys with frontend (patient_name vs name)
        patient_name = data.get('name') or data.get('patient_name') or 'Unknown'
        
        # Diagnosis/Conditions
        diagnosis = "N/A"
        if data.get('diagnosis'):
            diagnosis = data.get('diagnosis')
        elif data.get('conditions') and isinstance(data.get('conditions'), list) and len(data.get('conditions')) > 0:
            diagnosis = data.get('conditions')[0]

        if not openai_client:
            # Fallback demo response when OpenAI is unavailable
            return jsonify({
                "summary": f"Patient {patient_name} presents with {diagnosis}. Vitals and lab results are within observable parameters. Continued monitoring and medication adherence is recommended.",
                "recommendations": "1. Continue prescribed medications\n2. Monitor vitals daily\n3. Follow up in 2 weeks\n4. Maintain healthy diet and exercise",
                "risk_assessment": "Moderate"
            })

        prompt = f"""
        Generate a professional clinical summary for a doctor based on this patient data:
        Patient: {patient_name}
        Diagnosis/Conditions: {diagnosis}
        Vitals: {data.get('vitals', {})}
        Lab Results: {data.get('lab_results', [])}
        Medicines: {data.get('medicines', [])}
        
        Provide:
        1. "summary": A concise 3-sentence clinical summary.
        2. "recommendations": Key medical recommendations.
        3. "risk_assessment": Risk level (Low, Moderate, High).
        
        Return ONLY a JSON object with these keys.
        """
        
        response = openai_client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "system", "content": "You are a specialized medical consultant."},
                      {"role": "user", "content": prompt}],
            response_format={ "type": "json_object" }
        )
        
        # Parse the AI response to ensure it's valid JSON
        try:
            import json
            ai_data = json.loads(response.choices[0].message.content)
            return jsonify(ai_data)
        except:
            return jsonify({"summary": response.choices[0].message.content, "recommendations": "N/A", "risk_assessment": "N/A"})
        
    except Exception as e:
        print(f"❌ AI Summary Error: {e}")
        return jsonify({"error": str(e)}), 500


@app.route("/chat", methods=["POST"])
def chat():
    try:
        data = request.json
        user_message = data.get("message", "")
        if not user_message:
            return jsonify({"response": "No message provided"}), 400

        if not openai_client:
            # Fallback Tamil responses
            fallback_responses = {
                "default": "வணக்கம்! நான் CareSphere AI உதவியாளர். உங்கள் உடல்நலம் குறித்த கேள்விகளுக்கு பதிலளிக்க தயாராக இருக்கிறேன். தயவுசெய்து உங்கள் கேள்வியைக் கேளுங்கள்.",
            }
            msg_lower = user_message.lower()
            if any(w in msg_lower for w in ["தலைவலி", "headache", "head"]):
                reply = "தலைவலிக்கு ஓய்வு எடுங்கள், தண்ணீர் குடியுங்கள். தொடர்ந்தால் மருத்துவரை அணுகவும்."
            elif any(w in msg_lower for w in ["காய்ச்சல்", "fever", "sickness"]):
                reply = "காய்ச்சல் இருந்தால் நிறைய திரவங்கள் எடுத்துக் கொள்ளுங்கள். உடனடியாக மருத்துவரை அணுகவும்."
            elif any(w in msg_lower for w in ["நன்றி", "thanks", "thank"]):
                reply = "நன்றி! உங்கள் உடல்நலம் நல்லதாக இருக்க வாழ்த்துகள்."
            else:
                reply = fallback_responses["default"]
            return jsonify({"response": reply})

        response = openai_client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are a helpful Tamil medical assistant for the CareSphere AI app. Respond ONLY in Tamil. Provide concise, helpful health advice but remind them to consult a doctor for emergencies."},
                {"role": "user", "content": user_message}
            ]
        )
        
        return jsonify({"response": response.choices[0].message.content})
    except Exception as e:
        print(f"❌ Chat Error: {e}")
        return jsonify({"response": "An error occurred with our AI service."}), 500

@app.route("/ai_prescription_suggest", methods=["POST"])
def ai_prescription():
    summary = request.json.get("summary", "")

    if not openai_client:
        print("⚠ OpenAI client not initialized → Using fallback")
        return jsonify({"suggestion": """
Suggested Plan (Fallback):
- Continue current medication
- Monitor vitals twice daily
- Consultation recommended
"""})

    try:
        prompt = f"You are a clinical assistant. Suggest a safe medication plan with dosage and frequency based on this summary: {summary}"

        response = openai_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.2
        )
        suggestion = response.choices[0].message.content
    except Exception as e:
        print(f"⚠ AI Prescription failed: {e}")
        suggestion = "Could not generate suggestion at this time."

    return jsonify({"suggestion": suggestion})

@app.route("/doctor/patient_progress/<doctor_unique_id>")
def get_patient_progress(doctor_unique_id):
    try:
        # Find all patients assigned to this doctor
        assignments = DoctorPatient.query.filter_by(doctor_id=doctor_unique_id).all()
        patient_ids = [a.patient_id for a in assignments]
        
        # Get progress for each patient
        progress_report = []
        for p_id in patient_ids:
            patient = User.query.filter_by(unique_id=p_id).first()
            if not patient: continue
            
            reminders = Reminder.query.filter_by(patient=patient.full_name).all()
            total = len(reminders)
            taken = len([r for r in reminders if r.taken])
            
            progress_report.append({
                "patient_name": patient.full_name,
                "patient_id": patient.patient_id,
                "total_meds": total,
                "taken_meds": taken,
                "adherence_rate": (taken / total * 100) if total > 0 else 0
            })
            
        return jsonify(progress_report)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ================= MAIN =================

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(host="0.0.0.0", port=port, debug=True)