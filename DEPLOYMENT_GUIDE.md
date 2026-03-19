# CareSphereAI Deployment & Submission Guide

This guide will walk you through the steps to host your code on GitHub, deploy the backend to a public server, and prepare your app for the Google Play Store.

## 1. Hosting on GitHub

Your project is already initialized with Git. Follow these steps to push it to a new repository:

1.  **Create a new repository** on [GitHub](https://github.com/new). Name it `CareSphereAI`.
2.  **Open a terminal** in your project root (`d:\Projects - 2\CareSphereAI - Updated\CareSphereAI - Copy`) and run:
    ```bash
    git add .
    git commit -m "Initial commit: CareSphereAI fixed and ready for deployment"
    git branch -M main
    git remote add origin https://github.com/YOUR_USERNAME/CareSphereAI.git
    git push -u origin main
    ```
    *(Replace `YOUR_USERNAME` with your actual GitHub username)*

---

## 2. Deploying the Backend (Render.com)

To make your app work "on any internet", you need a public backend URL. Render is a great free option.

1.  **Sign up** at [Render.com](https://render.com/).
2.  **Connect your GitHub account** and select the `CareSphereAI` repository.
3.  **Create a "Web Service"**:
    *   **Name**: `caresphere-backend`
    *   **Root Directory**: `backend` (Important!)
    *   **Environment**: `Python 3`
    *   **Build Command**: `pip install -r requirements.txt`
    *   **Start Command**: `gunicorn app:app` (or `python app.py`)
4.  **Add Environment Variables**:
    *   Go to the "Environment" tab in Render.
    *   Add `OPENAI_API_KEY` with your key from the `.env` file.
5.  **Get your Public URL**: Once deployed, Render will give you a URL like `https://caresphere-backend.onrender.com`.

---

## 3. Updating Flutter with the Public URL

Once you have your Render URL:

1.  Open `frontend/caresphere/.env`.
2.  Update the `API_BASE_URL`:
    ```env
    API_BASE_URL=https://caresphere-backend.onrender.com
    ```
3.  Rebuild your app: `flutter run` or `flutter build apk`.

---

## 4. Play Store Submission Guide

To submit your app to the Play Store, you need to follow these high-level steps:

### A. Prepare for Release
1.  **App Icon**: Ensure you have high-quality icons in `android/app/src/main/res`.
2.  **App Name**: Set in `android/app/src/main/AndroidManifest.xml`.
3.  **Version Number**: Update `version` in `pubspec.yaml` (e.g., `1.0.0+1`).

### B. Sign the APK/App Bundle
1.  **Generate a Keystore**:
    ```bash
    keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    ```
2.  **Configure signing** in `android/app/build.gradle`.

### C. Build the Release Bundle
Run the following command to create an `.aab` (Android App Bundle), which is required by Google:
```bash
flutter build appbundle
```

### D. Google Play Console
1.  **Create a Developer Account** (One-time $25 fee).
2.  **Create a New App** and follow the "Initial Setup" tasks (Privacy Policy, App Content, etc.).
3.  **Upload the App Bundle** (`build/app/outputs/bundle/release/app-release.aab`).
4.  **Submit for Review**.

---

## Final Verification Checklist
- [ ] Backend is live and reachable via browser (shows "CareSphere AI Backend Running").
- [ ] Flutter `.env` has the correct `API_BASE_URL`.
- [ ] SOS button sends SMS/Call via Twilio (verify Twilio credits).
- [ ] Prescription upload correctly calls the backend OCR endpoint.
