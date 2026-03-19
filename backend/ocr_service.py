import pytesseract
import cv2
import shutil

# Auto detect tesseract path in cloud / linux / mac / windows
tesseract_path = shutil.which("tesseract")

if tesseract_path:
    pytesseract.pytesseract.tesseract_cmd = tesseract_path
else:
    print("⚠️ Tesseract not found. OCR may fail.")

def extract_text(image_path):

    img = cv2.imread(image_path)

    if img is None:
        return "Image not readable"

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    text = pytesseract.image_to_string(gray)

    return text