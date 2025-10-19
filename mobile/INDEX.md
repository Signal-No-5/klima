# KLIMA Flutter Mobile App

This directory contains the complete Flutter mobile application for KLIMA - The People's DRRM App.

## 📱 What's Included

✅ **Complete Flutter Project Structure**
- Models (Hazard, Report, Risk, SafeZone, GoBagItem, UserLocation, CommunityPost)
- Services (API, Location, Notification, Storage)
- Providers (State Management)
- Screens (All 9 main screens)
- Widgets (Reusable components)
- Constants (Theme, App configuration, Mock data)

✅ **All Core Features Implemented**
- Dynamic Hazard Dashboard (3 tabs: For You, My Location, Official)
- Participatory Reporting System (Report, Help, Safe)
- Evacuation Route & Shelter Finder with Maps
- Go-Bag Checklist with Progress Tracking
- Gamified DRRM Learning Module
- Community Hub for LGU posts
- Smart Notifications System
- Profile & Badge System

✅ **Ready for Development**
- Mock data for Calumpit, Bulacan barangays
- Offline-capable with local storage
- Backend API integration ready
- Material 3 UI with light/dark mode support
- Filipino-first UX (Taglish interface)

## 🚀 Quick Start

1. **Install Flutter** (if not already installed)
   ```bash
   # Check if Flutter is installed
   flutter doctor
   ```

2. **Navigate to the mobile directory**
   ```bash
   cd /Users/adrielmagalona/Desktop/klima/mobile
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   # List available devices
   flutter devices
   
   # Run on connected device
   flutter run
   ```

## 📖 Documentation

- **README.md** - Full project documentation
- **SETUP.md** - Detailed setup instructions and troubleshooting

## 🔧 Configuration Needed

Before running:
1. Update API URL in `lib/constants/app_constants.dart`
2. (Optional) Add app icons to `assets/icons/`
3. (Optional) Configure Firebase for notifications
4. Add permissions to Android/iOS manifests (already done)

## 📁 File Structure

```
mobile/
├── lib/
│   ├── constants/          # App-wide constants
│   ├── models/             # Data models
│   ├── providers/          # State management
│   ├── screens/            # All app screens
│   ├── services/           # API, location, notifications
│   ├── widgets/            # Reusable UI components
│   └── main.dart           # App entry point
├── android/                # Android configuration
├── ios/                    # iOS configuration
├── assets/                 # Images, icons, data
├── pubspec.yaml            # Dependencies
├── README.md               # Documentation
└── SETUP.md                # Setup guide
```

## 🎯 Features Status

| Feature | Status |
|---------|--------|
| Home Feed (3 tabs) | ✅ Complete |
| Report System | ✅ Complete |
| Help Request | ✅ Complete |
| Safe Status | ✅ Complete |
| Evacuation Routes | ✅ Complete |
| Go-Bag Checklist | ✅ Complete |
| DRRM Learning | ✅ Complete |
| Community Hub | ✅ Complete |
| Profile & Badges | ✅ Complete |
| Notifications | ✅ Complete |
| Offline Support | ✅ Complete |
| API Integration | ✅ Ready |

## 🧪 Testing the App

The app includes mock data and will work immediately without a backend. You can:
- Browse hazard reports
- Submit reports (stored locally)
- Use the evacuation map
- Complete the go-bag checklist
- Take DRRM quizzes
- View community posts
- Earn badges

## 🔗 Backend Integration

To connect to your backend API (from `web/api/`):
1. Make sure the FastAPI backend is running
2. Update the API URL in constants
3. The app will automatically switch from mock data to real API data

## 💡 Next Steps

1. Run `flutter pub get`
2. Run `flutter run`
3. Test all features
4. Connect to backend API
5. Add app icons
6. Build for production

## 📞 Need Help?

See the detailed documentation in README.md and SETUP.md for:
- Installation instructions
- Configuration guide
- Troubleshooting
- API integration
- Building for production

---

**Built with ❤️ for Filipino communities**
