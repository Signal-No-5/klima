# KLIMA Flutter App - Complete File Structure

```
klima/mobile/
│
├── 📱 lib/                                    # Main application code
│   ├── 🎨 constants/                         # App-wide constants
│   │   ├── app_constants.dart                # API URLs, config values
│   │   ├── app_theme.dart                    # Colors, themes, styles
│   │   └── mock_data.dart                    # Sample data for development
│   │
│   ├── 📊 models/                            # Data models
│   │   ├── community_post.dart               # Community announcements
│   │   ├── gobag_item.dart                   # Checklist items
│   │   ├── hazard.dart                       # Hazard event data
│   │   ├── report.dart                       # User reports
│   │   ├── risk.dart                         # Barangay risk assessment
│   │   ├── safe_zone.dart                    # Evacuation centers
│   │   └── user_location.dart                # Location & user profile
│   │
│   ├── 🔄 providers/                         # State management
│   │   ├── hazard_provider.dart              # Hazard state
│   │   ├── report_provider.dart              # Report state
│   │   └── user_provider.dart                # User state
│   │
│   ├── 📱 screens/                           # App screens
│   │   ├── community_hub.dart                # Community posts feed
│   │   ├── evacuation_route.dart             # Map & evacuation routes
│   │   ├── gobag_screen.dart                 # Go-bag checklist
│   │   ├── help_screen.dart                  # Emergency help request
│   │   ├── home_feed.dart                    # Main hazard feed (3 tabs)
│   │   ├── learning_screen.dart              # DRRM quiz
│   │   ├── profile_screen.dart               # User profile & badges
│   │   ├── report_screen.dart                # Report hazard
│   │   └── safe_status_screen.dart           # Mark safe status
│   │
│   ├── 🔧 services/                          # Business logic services
│   │   ├── api_service.dart                  # Backend API calls
│   │   ├── location_service.dart             # GPS & geocoding
│   │   ├── notification_service.dart         # Push notifications
│   │   └── storage_service.dart              # Local data storage (Hive)
│   │
│   ├── 🧩 widgets/                           # Reusable UI components
│   │   ├── floating_action_buttons.dart      # Quick action buttons
│   │   └── hazard_card.dart                  # Hazard display card
│   │
│   └── 🚀 main.dart                          # App entry point
│
├── 🤖 android/                               # Android configuration
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml     # Permissions & config
│   │   ├── build.gradle                      # Build configuration
│   │   └── proguard-rules.pro                # Code optimization rules
│   └── gradle.properties                     # Gradle properties
│
├── 🍎 ios/                                   # iOS configuration
│   └── Runner/
│       ├── AppDelegate.swift                 # iOS app delegate
│       └── Info.plist                        # Permissions & config
│
├── 🖼️ assets/                                # Static assets
│   ├── images/                               # Image files
│   ├── icons/                                # App icons
│   └── data/                                 # Static data files
│
├── 📄 Documentation Files
│   ├── README.md                             # Full project documentation
│   ├── SETUP.md                              # Setup & troubleshooting
│   ├── QUICKSTART.md                         # Quick reference guide
│   ├── INDEX.md                              # Overview & feature list
│   ├── IMPLEMENTATION_SUMMARY.md             # What's been built
│   └── FILE_STRUCTURE.md                     # This file
│
├── ⚙️ Configuration Files
│   ├── pubspec.yaml                          # Dependencies & assets
│   ├── analysis_options.yaml                 # Linting rules
│   ├── .gitignore                            # Git ignore rules
│   └── start.sh                              # Quick start script
│
└── 📝 Other Files
    └── LICENSE                               # Project license

```

## 📊 Statistics

- **Total Screens**: 9
- **Total Models**: 7
- **Total Services**: 4
- **Total Providers**: 3
- **Total Widgets**: 2
- **Total Files Created**: 40+
- **Lines of Code**: ~5,000+

## 🎯 Key Features by File

### Core Screens
1. **home_feed.dart** - Main dashboard with 3 tabs
2. **report_screen.dart** - Hazard reporting with camera
3. **help_screen.dart** - Emergency SOS
4. **safe_status_screen.dart** - Safety status update
5. **evacuation_route.dart** - Map with evacuation centers
6. **gobag_screen.dart** - Preparedness checklist
7. **learning_screen.dart** - DRRM education quiz
8. **community_hub.dart** - LGU announcements
9. **profile_screen.dart** - User stats & badges

### Data Layer
- **models/** - 7 type-safe data classes
- **services/** - API, location, storage, notifications
- **providers/** - State management with Provider pattern

### Configuration
- **constants/** - Centralized configuration
- **android/** - Android-specific setup
- **ios/** - iOS-specific setup

## 🔍 Find Files Quickly

**Want to modify...**

| What | Where |
|------|-------|
| Colors/Theme | `lib/constants/app_theme.dart` |
| API URL | `lib/constants/app_constants.dart` |
| Sample Data | `lib/constants/mock_data.dart` |
| Home Screen | `lib/screens/home_feed.dart` |
| Report Form | `lib/screens/report_screen.dart` |
| Map Screen | `lib/screens/evacuation_route.dart` |
| Hazard Display | `lib/widgets/hazard_card.dart` |
| Floating Buttons | `lib/widgets/floating_action_buttons.dart` |
| API Calls | `lib/services/api_service.dart` |
| Location Logic | `lib/services/location_service.dart` |
| Notifications | `lib/services/notification_service.dart` |

## 🚀 Getting Started

1. **Read first**: `QUICKSTART.md`
2. **For setup help**: `SETUP.md`
3. **For full docs**: `README.md`
4. **For implementation details**: `IMPLEMENTATION_SUMMARY.md`

## 📱 Running the App

```bash
cd /Users/adrielmagalona/Desktop/klima/mobile
./start.sh
```

Or manually:
```bash
flutter pub get
flutter run
```

---

**KLIMA: Built for Filipino communities with ❤️** 🇵🇭
