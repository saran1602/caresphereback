from flask import Flask, request, jsonify
from flask_cors import CORS
from models import db, Medication, Vitals, Reminder, User
from auth import register_auth_routes
from risk_model import predict_risk
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

client = Client(account_sid, auth_token)

TWILIO_NUMBER = os.getenv("TWILIO_PHONE")
HOSPITAL_NUMBER = os.getenv("HOSPITAL_NUMBER")
AMBULANCE_NUMBER = os.getenv("AMBULANCE_NUMBER")
# ================= EMERGENCY FUNCTION =================

def trigger_emergency(patient, sugar, bp):

    msg = f"""
🚨 CRITICAL PATIENT ALERT
Patient: {patient}
Sugar Level: {sugar}
BP: {bp}
Immediate Attention Required
"""

    try:
        sms = client.messages.create(
            body=msg,
            from_=TWILIO_NUMBER,
            to=HOSPITAL_NUMBER
        )
        print("✅ SMS SENT:", sms.sid)

    except Exception as e:
        print("❌ SMS ERROR:", e)

    try:
        call = client.calls.create(
            twiml='<Response><Say>Emergency patient alert. Please respond immediately.</Say></Response>',
            from_=TWILIO_NUMBER,
            to=AMBULANCE_NUMBER
        )
        print("✅ CALL SENT:", call.sid)

    except Exception as e:
        print("❌ CALL ERROR:", e)

# ================= ROUTES =================
@app.route("/emergency", methods=["POST"])
def emergency():

    data = request.form or request.json

    patient = data.get("patient_name", "Unknown")
    sugar = data.get("sugar", "NA")
    bp = data.get("bp", "NA")

    trigger_emergency(patient, sugar, bp)

    return jsonify({"status": "Emergency Triggered"})

@app.route("/")
def home():
    return jsonify({"message": "CareSphere AI Backend Running"})

@app.route("/upload_prescription", methods=["POST"])
def upload_prescription():

    file = request.files["file"]
    path = "temp.jpg"
    file.save(path)

    # Dummy text extraction - OCR disabled for now
    text = "Prescription: Paracetamol 500mg - 2 tablets twice daily.\nAmoxicillin 500mg - 1 capsule thrice daily.\nRest and hydration for 3 days."

    return jsonify({"extracted_text": text})

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
        medications = Medication.query.filter_by(patient=patient).all()

        output = []

        for med in medications:
            output.append({
                "id": med.id,
                "medicine": med.medicine,
                "time": med.timing,
                "taken": getattr(med, 'taken', False)  # Default to False if column missing
            })

        return jsonify(output)
    except Exception as e:
        print(f"❌ Error fetching reminders: {e}")
        return jsonify({"reminders": [], "error": str(e)}), 500

@app.route("/mark_medicine_taken", methods=["POST"])
def mark_medicine_taken():
    try:
        data = request.json
        med_id = data.get("id")
        taken = data.get("taken")

        med = Medication.query.get(med_id)
        if med:
            # Only set taken if the column exists
            if hasattr(med, 'taken'):
                med.taken = taken
                db.session.commit()
                return jsonify({"message": "Medicine status updated"})
            else:
                return jsonify({"message": "Medicine found but taken column not available"}), 200
        
        return jsonify({"error": "Medicine not found"}), 404
    except Exception as e:
        print(f"❌ Error updating medicine status: {e}")
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route("/doctor_upload_record", methods=["POST"])
def doctor_upload_record():

    file = request.files["file"]
    path = "doctor_temp.jpg"
    file.save(path)

    # Dummy text extraction and structuring
    raw_text = "Patient Diagnosis: Type 2 Diabetes\nMedications: Metformin 500mg twice daily, Lisinopril 10mg once daily\nVitals: BP 130/85, Blood Sugar 145 mg/dL\nNotes: Monitor glucose levels regularly"

    structured = {
        "diagnosis": ["Type 2 Diabetes"],
        "medications": [
            {"name": "Metformin", "dose": "500mg", "frequency": "twice daily"},
            {"name": "Lisinopril", "dose": "10mg", "frequency": "once daily"}
        ],
        "vitals": {
            "bp": "130/85",
            "blood_sugar": "145 mg/dL"
        },
        "notes": "Monitor glucose levels regularly"
    }

    return jsonify({
        "raw_text": raw_text,
        "structured_data": structured
    })

@app.route("/doctor_ai_summary", methods=["POST"])
def doctor_ai_summary():

    data = request.json

    patient = {
        "name": data.get("name", "Unknown"),
        "age": data.get("age", "Unknown"),
        "conditions": data.get("conditions", [])
    }

    allergies = data.get("allergies", [])
    symptoms = data.get("symptoms", [])
    vitals = data.get("vitals", {})
    prescriptions = data.get("prescriptions", [])
    scans = data.get("scans", [])

    # Dummy AI summary generation
    result = {
        "patient_summary": f"Patient {patient['name']}, Age {patient['age']}, with conditions: {', '.join(patient['conditions']) or 'None reported'}",
        "allergies": allergies,
        "current_symptoms": symptoms,
        "vital_signs": vitals,
        "current_medications": prescriptions,
        "imaging_reports": scans,
        "clinical_recommendation": "Continue current treatment plan. Schedule follow-up in 2 weeks. Monitor blood glucose levels.",
        "risk_assessment": "Low to moderate risk. Maintain current medication adherence."
    }

    return jsonify(result)

@app.route("/chat", methods=["POST"])
def chat():
    data = request.json
    user_message = data.get("message", "")

    if not user_message:
        return jsonify({"response": "வார்த்தைகள் கிடைக்கவில்லை."}), 400

    try:
        # DUMMY RESPONSES - No dependency on OpenAI API
        dummy_responses = {
            "hello": "வணக்கம்! நீங்கள் எப்படி உள்ளீர்கள்?",
            "hi": "வணக்கம்! உங்களுக்கு சாயம் உள்ளதா?",
            "help": "நான் உங்களுக்கு உதவ முடியும். நோய், மருந்து அல்லது உணவு பற்றி கேட்கவும்.",
            "health": "ஆரோக்கியம் என்பது முக்கியமானது. தினமும் சிறிது நடைப்பயிற்சி செய்யுங்கள்.",
            "medicine": "மருந்தை எடுக்கும் முன் மருத்துவரை கலந்தாலோசிக்கவும்.",
            "food": "ஆரோக்கியமான உணவை சாப்பிடுங்கள். பச்சை காய்கறிகள் மற்றும் பழங்கள் முக்கியம்.",
            "water": "தினமும் போதுமான தண்ணீர் குடிக்கவும்.",
            "pain": "வலி இருந்தால் மருத்துவரை பார்க்கவும் அல்லது ஆரம்ப மருத்துவத்தை உயோகப்படுத்தவும்.",
        }
        
        # Convert to lowercase for matching
        message_lower = user_message.lower()
        
        # Find matching response
        response_text = dummy_responses.get(message_lower, "நன்றி. உங்கள் கேள்வியை மீண்டும் கேட்கவும் அல்லது வேறு কேள்வியைக் கேட்கவும்.")
        
        return jsonify({"response": response_text})

    except Exception as e:
        print(f"❌ Chat Error: {e}")
        return jsonify({"response": "மன்னிக்கவும், என்னால் இப்போது பதில் அளிக்க முடியவில்லை."}), 500

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

# ================= MAIN =================

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(host="0.0.0.0", port=port, debug=True)