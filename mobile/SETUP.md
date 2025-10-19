# KLIMA Flutter App - Additional Setup Notes

## Missing Assets

The following assets need to be added to complete the app:

### 1. App Icons
Create an app icon and place it at:
- `assets/icons/app_icon.png` (512x512px)
- `assets/icons/app_icon_foreground.png` (for Android adaptive icon)

Then run:
```bash
flutter pub run flutter_launcher_icons
```

### 2. Fonts (Optional)
If you want to use Poppins font:
- Download Poppins from Google Fonts
- Place font files in `assets/fonts/`
- The pubspec.yaml is already configured for Poppins

If you don't want custom fonts, remove the fonts section from `pubspec.yaml`.

### 3. Firebase Setup (Optional)

#### For Android:
1. Go to Firebase Console
2. Create a new project or use existing
3. Add an Android app
4. Download `google-services.json`
5. Place it in `android/app/`

#### For iOS:
1. Add an iOS app in Firebase
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/`

If you're not using Firebase yet, the app will work without it (notifications won't work).

## Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <application ...>
        <!-- Add this for location services -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE" />
    </application>
</manifest>
```

## iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Location -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>KLIMA needs your location to show nearby hazards and evacuation routes.</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>KLIMA needs your location to alert you of nearby hazards.</string>
    
    <!-- Camera -->
    <key>NSCameraUsageDescription</key>
    <string>KLIMA needs camera access to take photos of hazards.</string>
    
    <!-- Photo Library -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>KLIMA needs photo library access to attach images to reports.</string>
</dict>
```

## Backend Integration

### Update API Base URL

In `lib/constants/app_constants.dart`, change:
```dart
static const String apiBaseUrl = 'http://localhost:8000';
```

To your actual backend URL:
```dart
static const String apiBaseUrl = 'https://api.yourdomain.com';
```

### API Endpoints Expected

The app expects these endpoints:
- `GET /hazard/latest` - Fetch all hazards
- `POST /reports` - Submit a report
- `GET /reports` - Fetch all reports
- `GET /risk/{barangay_id}` - Fetch risk data
- `GET /safezones` - Fetch evacuation centers
- `GET /community/posts` - Fetch community posts

## Running the App

### Development Mode
```bash
# Check for connected devices
flutter devices

# Run on connected device
flutter run

# Run with hot reload
flutter run --dart-define=ENVIRONMENT=dev
```

### Debug vs Release

Debug mode includes:
- Hot reload
- DevTools
- Verbose logging

Release mode:
- Optimized performance
- Smaller app size
- No debug info

## Troubleshooting

### Common Issues

1. **"Failed to load hazards"**
   - Check if backend API is running
   - Verify API URL in constants
   - App will use mock data if API fails

2. **Location not working**
   - Ensure permissions are granted
   - Check AndroidManifest.xml / Info.plist
   - Enable location services on device

3. **Build errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Firebase errors**
   - Verify google-services.json is in place
   - Check package name matches Firebase configuration
   - Or comment out Firebase initialization in main.dart

## Performance Tips

1. **Reduce app size**
   ```bash
   flutter build apk --split-per-abi
   ```

2. **Enable ProGuard** (Android)
   - Already configured in android/app/build.gradle

3. **Optimize images**
   - Use WebP format for assets
   - Compress images before adding

## Next Steps

1. ✅ Install dependencies: `flutter pub get`
2. ✅ Add app icon to assets
3. ✅ Configure Android & iOS permissions
4. ✅ Update API base URL
5. ✅ (Optional) Set up Firebase
6. ✅ Run the app: `flutter run`
7. ✅ Test all features
8. ✅ Build for production

## Contact

For technical support or questions about this implementation, please refer to the main README.md or open an issue.
