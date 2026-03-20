# Build Production APK for CareSphere AI

Write-Host "Starting Flutter Build Process..." -ForegroundColor Cyan

# Navigate to frontend directory
cd frontend/caresphere

# Clean previous builds
Write-Host "Cleaning previous builds..."
flutter clean

# Get dependencies
Write-Host "Fetching packages..."
flutter pub get

# Build Release APK
Write-Host "Building APK (this may take a few minutes)..."
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: APK Built Successfully!" -ForegroundColor Green
    Write-Host "LOCATION: You can find your APK at: frontend\caresphere\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
} else {
    Write-Host "ERROR: Build Failed. Please check errors above." -ForegroundColor Red
}
