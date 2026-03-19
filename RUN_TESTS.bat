@echo off
REM ================================
REM CareSphere AI - Testing Setup (Windows)
REM ================================

echo.
echo ================================
echo CareSphere AI - Testing Setup
echo ================================
echo.

REM Step 1: Backend Setup
echo [Step 1] Setting up Backend...
cd backend
echo Installing Python dependencies...
pip install -r requirements.txt
echo (✓) Backend dependencies installed
echo.

REM Step 2: Start Backend in new terminal
echo [Step 2] Starting Backend Server...
echo Backend will run on: http://localhost:5000
start "CareSphere Backend" python app.py
echo (✓) Backend started in new window
timeout /t 3 /nobreak
echo.

REM Step 3: Frontend Setup
echo [Step 3] Setting up Frontend...
cd ..
cd frontend\caresphere
echo Installing Flutter dependencies...
call flutter pub get
echo (✓) Flutter dependencies installed
echo.

REM Step 4: Run Flutter
echo [Step 4] Starting Flutter App...
echo Make sure you have an Android Emulator or iOS Simulator running!
echo.
call flutter run

echo.
echo Testing completed!
pause
