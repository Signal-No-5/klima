# 🚀 KLIMA Quick Start Guide

## Instant Setup (3 steps)

```bash
cd /Users/adrielmagalona/Desktop/klima/mobile
flutter pub get
flutter run
```

That's it! The app will run with mock data.

## 📱 Main Features You Can Try

| Feature | How to Access |
|---------|---------------|
| **Browse Hazards** | Bottom nav → Home (first tab) |
| **Report Hazard** | Orange FAB → 📍 Mag-report |
| **Request Help** | Orange FAB → 🆘 Kailangan ng Tulong |
| **Mark Safe** | Orange FAB → ✅ Ligtas Ako |
| **Evacuation Map** | Bottom nav → Evacuation |
| **Go-Bag Checklist** | Bottom nav → Go-Bag |
| **DRRM Quiz** | Go-Bag screen → 🎓 icon (top right) |
| **Community Posts** | Bottom nav → Community |
| **Profile & Badges** | Bottom nav → Profile |

## 🎯 Quick Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter devices                    # List devices
flutter run -d <device-id>        # Run on specific device

# Build for production
flutter build apk                  # Android APK
flutter build appbundle           # Android App Bundle
flutter build ios                 # iOS

# Clean build
flutter clean
flutter pub get
flutter run

# Check for issues
flutter doctor
```

## 🔧 Configuration Checklist

- [ ] Flutter SDK installed (`flutter doctor`)
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Device connected or emulator running
- [ ] (Optional) API URL updated in `lib/constants/app_constants.dart`
- [ ] (Optional) Firebase configured for notifications
- [ ] (Optional) App icons added to `assets/icons/`

## 📂 Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/constants/app_constants.dart` | API URL and configuration |
| `lib/constants/mock_data.dart` | Sample data for testing |
| `pubspec.yaml` | Dependencies |
| `README.md` | Full documentation |
| `SETUP.md` | Detailed setup guide |

## 🐛 Troubleshooting

**App won't start?**
```bash
flutter clean
flutter pub get
flutter run
```

**"Failed to load hazards"?**
- Normal! App uses mock data by default
- Update API URL in constants to connect to backend

**Location not working?**
- Grant location permissions when prompted
- Check device location services are enabled

**Camera not working?**
- Grant camera permissions when prompted

## 🌐 Connect to Backend

1. Open `lib/constants/app_constants.dart`
2. Change:
   ```dart
   static const String apiBaseUrl = 'http://localhost:8000';
   ```
   To:
   ```dart
   static const String apiBaseUrl = 'http://your-backend-url.com';
   ```
3. Restart the app

## 📖 More Help

- **Full documentation**: `README.md`
- **Setup guide**: `SETUP.md`
- **Implementation details**: `IMPLEMENTATION_SUMMARY.md`
- **Quick reference**: `INDEX.md`

## 💡 Tips

1. **Mock data works offline** - Perfect for testing without backend
2. **Hot reload** - Press `r` in terminal while app is running
3. **DevTools** - Press `v` for Flutter DevTools
4. **Restart** - Press `R` for full restart (capital R)

## 🎨 Customization

Want to customize?

- **Colors**: `lib/constants/app_theme.dart`
- **API endpoints**: `lib/constants/app_constants.dart`
- **Mock data**: `lib/constants/mock_data.dart`
- **Barangays**: `app_constants.dart` → `calumpitBarangays`

## ✅ Verify Installation

Run this to check everything:
```bash
flutter doctor -v
cd /Users/adrielmagalona/Desktop/klima/mobile
flutter pub get
flutter analyze
```

If all green ✅ you're ready to go!

---

**Need more help?** Check `README.md` for comprehensive documentation.
