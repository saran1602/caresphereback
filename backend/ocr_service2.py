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
        return {"raw_text": text}

    try:

        prompt = f"""
Extract structured medical info from this:

{text}

Return JSON with:
medicines
bp
sugar
diagnosis
"""

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0
        )

        return response.choices[0].message.content

    except Exception as e:

        print("⚠ AI structuring failed → fallback")

        data = {
            "bp": "Not Found",
            "sugar": "Not Found",
            "medicines": []
        }

        lines = text.split("\n")

        for line in lines:

            if "BP" in line:
                data["bp"] = line

            if "Sugar" in line:
                data["sugar"] = line

            if "mg" in line:
                data["medicines"].append(line)

        return str(data)