import pytesseract
import cv2
import os
import shutil
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

# Detect tesseract automatically
tesseract_path = shutil.which("tesseract")

if tesseract_path:
    pytesseract.pytesseract.tesseract_cmd = tesseract_path
else:
    print("⚠️ Tesseract not found. OCR may fail.")

# OpenAI client
api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=api_key) if api_key else None


def extract_text(image_path):
    img = cv2.imread(image_path)
    if img is None:
        return "Image not readable"
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    text = pytesseract.image_to_string(gray)
    return text


def structure_medical_text(text):
    if not client:
        print("⚠ AI not available → fallback")
        return {"raw_text": text, "error": "AI client not initialized"}

    try:
        prompt = f"""
        You are a highly accurate medical data extraction AI.
        From the provided OCR text of a medical record (Prescription, Lab Report, or Scan), extract the following information into a structured JSON format:

        1. "patient_name": Full name if available.
        2. "date": Date of the record.
        3. "record_type": One of [PRESCRIPTION, LAB_REPORT, SCAN, OTHER].
        4. "diagnosis": Primary diagnosis or clinical finding.
        5. "medicines": List of objects with:
           - "name": Medicine name.
           - "dosage": Amount (e.g., 500mg).
           - "frequency": How often (e.g., Twice daily, 1-0-1).
           - "notes": Any specific instructions (e.g., After food).
        6. "vitals": Object with "bp", "heart_rate", "pulse_rate", "sugar" if present.
        7. "lab_results": List of objects with:
           - "parameter": Name of the test (e.g., Hemoglobin).
           - "value": The result value.
           - "unit": Measurement unit.
           - "normal_range": Reference range.
        8. "clinical_summary": A 2-sentence summary for a doctor's quick review.

        OCR TEXT:
        {text}

        RETURN ONLY THE JSON.
        """

        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "system", "content": "You are a professional medical assistant."},
                      {"role": "user", "content": prompt}],
            temperature=0,
            response_format={ "type": "json_object" }
        )

        return response.choices[0].message.content

    except Exception as e:
        print(f"⚠ AI structuring failed: {e}")
        return {"raw_text": text, "error": str(e)}