# Flutter Project Setup Steps

Follow these steps to complete the Flutter project setup:

## Step 1: Generate Flutter Project Files

Run this command in the `hlavi-app` directory:

```bash
cd hlavi-app
flutter create . --org app.hlavi
```

This will:
- Generate iOS project files (Xcode project)
- Generate Android project files (Gradle configuration)
- Preserve your existing `lib/` directory and code
- Preserve your `pubspec.yaml`

**When prompted**: Type `y` to confirm overwriting files

## Step 2: Restore OAuth Configuration

The `flutter create` command will overwrite the platform configuration files. Run these commands to restore the OAuth setup:

### Android

```bash
cat > android/app/src/main/AndroidManifest.xml << 'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="Hlavi"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- OAuth Redirect Intent Filter -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="app.hlavi" android:host="oauth-callback" />
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
EOF
```

### iOS

Add the OAuth URL scheme to `ios/Runner/Info.plist`. Open the file and add this before the closing `</dict>` tag:

```xml
<!-- OAuth URL Scheme Configuration -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>app.hlavi</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>app.hlavi</string>
    </array>
  </dict>
</array>
```

Or run this command to append it:

```bash
# This is a bit complex - manually editing is safer
# Open ios/Runner/Info.plist and add the CFBundleURLTypes section shown above
```

## Step 3: Install Dependencies

```bash
flutter pub get
```

## Step 4: Generate Code

Run code generation for Freezed, Riverpod, and JSON serialization:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 5: Add Space Grotesk Fonts

1. Download Space Grotesk from [Google Fonts](https://fonts.google.com/specimen/Space+Grotesk)
2. Extract and copy these files to `assets/fonts/`:
   - `SpaceGrotesk-Regular.ttf`
   - `SpaceGrotesk-Medium.ttf`
   - `SpaceGrotesk-SemiBold.ttf`
   - `SpaceGrotesk-Bold.ttf`

## Step 6: Verify Configuration

Check that your `.env` file has the correct credentials:

```bash
cat .env
```

Should show:
```
GITHUB_CLIENT_ID=Ov23liWEiKTBFFt7bE8S
GITHUB_CLIENT_SECRET=7a56fa2aad4e94074cc278cf9b876bbff8386678
GITHUB_REDIRECT_URI=app.hlavi://oauth-callback
```

## Step 7: Run the App

```bash
# List available devices
flutter devices

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android

# Or just run on the first available device
flutter run
```

## Troubleshooting

### "Could not find an option named 'org'"
Your Flutter version might be old. Update Flutter:
```bash
flutter upgrade
```

### "CocoaPods not installed" (iOS only)
Install CocoaPods:
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### "Build runner fails"
Delete generated files and try again:
```bash
find . -name "*.g.dart" -delete
find . -name "*.freezed.dart" -delete
flutter pub run build_runner build --delete-conflicting-outputs
```

### "OAuth callback not working"
- Verify `AndroidManifest.xml` has the intent-filter with `app.hlavi` scheme
- Verify `Info.plist` has the CFBundleURLTypes with `app.hlavi` scheme
- Clear app data and reinstall

## Next Steps

Once the app runs successfully, you're ready to start implementing features! The foundation is complete with:

✅ Project structure
✅ Theme configuration
✅ OAuth setup
✅ Environment configuration
✅ Platform configuration

Next development phase: **Authentication & API Layer** (see the implementation plan)
