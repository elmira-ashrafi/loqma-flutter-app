#!/bin/bash

# Optimized Flutter Build Script for APK and App Bundle
# This script creates optimized builds with maximum size reduction

echo "🚀 Starting Optimized Flutter Build Process..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf build/app/outputs/flutter-apk/
rm -rf build/app/outputs/bundle/

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build optimized App Bundle for Play Store
echo "📱 Building optimized App Bundle for Play Store..."
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info \
  --analyze-size \
  --tree-shake-icons \
  --no-sound-null-safety

# Build optimized APKs for direct distribution
echo "📱 Building optimized APKs for direct distribution..."
flutter build apk \
  --release \
  --obfuscate \
  --split-debug-info \
  --analyze-size \
  --tree-shake-icons \
  --split-per-abi \
  --no-sound-null-safety

# Analyze sizes
echo "📊 Build Analysis:"
echo "App Bundle (Play Store):"
find build/app/outputs/bundle/release -name "*.aab" -exec ls -lh {} \;

echo ""
echo "APKs (Direct Distribution):"
find build/app/outputs/flutter-apk/release -name "*.apk" -exec ls -lh {} \;

echo ""
echo "✅ Optimized build process completed!"
echo ""
echo "📋 Size Analysis Summary:"
echo "🔍 Run 'flutter build --analyze-size' for detailed breakdown"
echo "📱 Use APKs for direct distribution, App Bundle for Play Store"
