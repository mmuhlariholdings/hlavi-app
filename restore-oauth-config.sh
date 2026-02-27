#!/bin/bash

# Restore OAuth Configuration Script
# Run this after "flutter create ." to restore OAuth settings

echo "🔧 Restoring OAuth configuration..."

# Restore Android OAuth configuration
echo "📱 Updating AndroidManifest.xml..."

# Check if the OAuth intent-filter already exists
if grep -q "app.hlavi" android/app/src/main/AndroidManifest.xml 2>/dev/null; then
    echo "   ✅ OAuth configuration already exists in AndroidManifest.xml"
else
    # Add the OAuth intent-filter before the closing </activity> tag
    # Using a more reliable approach with perl
    perl -i -pe 's|(\s*</activity>)|
            <!-- OAuth Redirect Intent Filter -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="app.hlavi" android:host="oauth-callback" />
            </intent-filter>\1|' android/app/src/main/AndroidManifest.xml 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "   ✅ Added OAuth configuration to AndroidManifest.xml"
    else
        echo "   ⚠️  Please manually add OAuth intent-filter to AndroidManifest.xml"
        echo "   See OAUTH_SETUP.md for details"
    fi
fi

# Restore iOS OAuth configuration
echo "🍎 Updating Info.plist..."

if grep -q "app.hlavi" ios/Runner/Info.plist 2>/dev/null; then
    echo "   ✅ OAuth configuration already exists in Info.plist"
else
    # Add CFBundleURLTypes before the closing </dict> tag
    perl -i -pe 's|(^\s*</dict>\s*$)|	<!-- OAuth URL Scheme Configuration -->
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
\1|' ios/Runner/Info.plist 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "   ✅ Added OAuth configuration to Info.plist"
    else
        echo "   ⚠️  Please manually add OAuth URL scheme to Info.plist"
        echo "   See OAUTH_SETUP.md for details"
    fi
fi

echo ""
echo "✅ OAuth configuration restored!"
echo ""
echo "Next steps:"
echo "1. Run: flutter pub get"
echo "2. Run: flutter pub run build_runner build --delete-conflicting-outputs"
echo "3. Add Space Grotesk fonts to assets/fonts/ (see FONTS.md)"
echo "4. Run: flutter run"
