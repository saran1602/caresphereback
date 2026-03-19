# 🚀 Quick Start - Copy & Paste Commands

**Don't read anything else - just follow these commands exactly!**

---

## Terminal 1: Start Backend (2-3 minutes)

Open **Command Prompt** or **PowerShell** and copy-paste:

```bash
cd "d:\Projects - 2\CareSphereAI - Updated\CareSphereAI - Copy\backend"
pip install -r requirements.txt
python app.py
```

**Wait until you see:**

```
 * Running on http://127.0.0.1:5000
```

✅ **Leave this terminal open and running**

---

## Terminal 2: Start Frontend (3-5 minutes)

Open a **NEW Command Prompt** or **PowerShell** and copy-paste:

```bash
cd "d:\Projects - 2\CareSphereAI - Updated\CareSphereAI - Copy\frontend\caresphere"
flutter clean
flutter pub get
flutter run -d chrome
```

**Wait until you see:**

```
[✓] Flutter app running
```

✅ **App should open in Chrome browser**

---

## 📱 If Using Android Emulator Instead

In Terminal 2, replace the last line with:

```bash
flutter run -d emulator-5554
```

**Or first list devices:**

```bash
flutter devices
flutter run -d [device-name]
```

---

## 🧪 Begin Testing

Once app opens, follow: **MASTER_TESTING_CHECKLIST.md**

### Quick Summary:

1. **Create Patient Account** (email: john.patient@test.com, pwd: Password@123)
2. **Copy Patient ID** from QR code (format: CS-2026-XXXXX)
3. **Create Doctor Account** (email: jane.doctor@test.com, pwd: Password@123)
4. **Create Caregiver Account** (email: mary.caregiver@test.com, pwd: Password@123)
5. **Test Login** with any account
6. **Test Logout** from any dashboard

---

## 🆘 Something Broke?

### Backend not starting?

```bash
# Try this
pip install -r requirements.txt --force-reinstall
python app.py
```

### App won't load?

```bash
# Try this
flutter clean
flutter pub get
flutter run -d chrome
```

### App won't connect to backend?

- Make sure Terminal 1 shows: "Running on http://127.0.0.1:5000"
- Make sure it's NOT showing any red errors
- Try restarting backend: Stop (Ctrl+C) and run again

### See different platform?

- **For Android:** `flutter run -d emulator-5554`
- **For Web:** `flutter run -d chrome`
- **For iOS:** `flutter run -d iPhone`

---

## 📚 Full Documentation

After you get it running:

- **Step-by-step guide:** STEP_BY_STEP_TESTING.md
- **Troubleshooting:** QUICK_TROUBLESHOOTING.md
- **Complete checklist:** MASTER_TESTING_CHECKLIST.md

---

## ✅ What to Expect

| Step                      | Time        | What Happens                     |
| ------------------------- | ----------- | -------------------------------- |
| Install backend packages  | 1-2 min     | Downloading ~20 files            |
| Start backend             | 10 sec      | Server starts on port 5000       |
| Install frontend packages | 1-2 min     | Downloading ~100+ packages       |
| Start flutter app         | 1-2 min     | App opens in browser or emulator |
| Total time                | **5-8 min** | Ready to test!                   |

---

That's it! Just run those commands and follow the testing checklist. 🎉
