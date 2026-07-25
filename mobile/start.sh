#!/bin/bash

# KLIMA Flutter App - Quick Start Script
# This script helps you get the app running quickly

echo "🌏 KLIMA - The People's DRRM App"
echo "=================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Navigate to project directory
cd "$(dirname "$0")"

echo "📦 Installing dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed"
echo ""

echo "🔍 Checking for connected devices..."
flutter devices

echo ""
echo "🚀 Ready to run!"
echo ""
echo "Choose an option:"
echo "  1) Run on connected device"
echo "  2) Run on Android emulator"
echo "  3) Run on iOS simulator"
echo "  4) Just install dependencies (done)"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo "🚀 Running on connected device..."
        flutter run
        ;;
    2)
        echo "🚀 Running on Android emulator..."
        flutter run -d android
        ;;
    3)
        echo "🚀 Running on iOS simulator..."
        flutter run -d ios
        ;;
    4)
        echo "✅ Setup complete! Run 'flutter run' to start the app."
        ;;
    *)
        echo "Invalid choice. Run 'flutter run' manually."
        ;;
esac
