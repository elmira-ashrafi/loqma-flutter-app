@echo off
REM Optimized Flutter Build Script for APK and App Bundle (Windows)
REM This script creates optimized builds with maximum size reduction

echo 🚀 Starting Optimized Flutter Build Process...

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean
if exist build\app\outputs\flutter-apk\ rmdir /s /q build\app\outputs\flutter-apk\
if exist build\app\outputs\bundle\ rmdir /s /q build\app\outputs\bundle\

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build optimized App Bundle for Play Store
echo 📱 Building optimized App Bundle for Play Store...
flutter build appbundle --release --obfuscate --split-debug-info --analyze-size --tree-shake-icons --no-sound-null-safety

REM Build optimized APKs for direct distribution
echo 📱 Building optimized APKs for direct distribution...
flutter build apk --release --obfuscate --split-debug-info --analyze-size --tree-shake-icons --split-per-abi --no-sound-null-safety

REM Analyze sizes
echo 📊 Build Analysis:
echo App Bundle (Play Store):
dir build\app\outputs\bundle\release\*.aab

echo.
echo APKs (Direct Distribution):
dir build\app\outputs\flutter-apk\release\*.apk

echo.
echo ✅ Optimized build process completed!
echo.
echo 📋 Size Analysis Summary:
echo 🔍 Run 'flutter build --analyze-size' for detailed breakdown
echo 📱 Use APKs for direct distribution, App Bundle for Play Store
pause
