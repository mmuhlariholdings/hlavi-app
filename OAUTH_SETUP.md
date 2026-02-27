# GitHub OAuth Setup Guide

This guide walks you through setting up GitHub OAuth authentication for the Hlavi mobile app.

## URL Scheme Configuration

Since your website is **hlavi.app**, the mobile app uses:

- **URL Scheme**: `app.hlavi` (reverse domain notation: hlavi.app → app.hlavi)
- **OAuth Callback URL**: `app.hlavi://oauth-callback`

This follows the standard reverse domain notation for mobile apps, which provides:
- Unique identifier for your app
- Platform consistency (iOS and Android)
- Prevents conflicts with other apps

## Step 1: Create GitHub OAuth App

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)

2. Click **"OAuth Apps"** in the left sidebar

3. Click **"New OAuth App"** button

4. Fill in the application details:
   - **Application name**: `Hlavi Mobile`
   - **Homepage URL**: `https://hlavi.app`
   - **Application description** (optional): `Task management with GitHub integration`
   - **Authorization callback URL**: `app.hlavi://oauth-callback` ⚠️ **IMPORTANT**

5. Click **"Register application"**

6. On the next page, you'll see:
   - **Client ID** (looks like: `Iv1.1234567890abcdef`)
   - Click **"Generate a new client secret"** to get your **Client Secret**

7. **Save these credentials securely** - you'll need them in the next step

## Step 2: Configure Environment Variables

1. Open the `.env` file in the root of the `hlavi-app` directory

2. Replace the placeholder values with your actual credentials:

```env
GITHUB_CLIENT_ID=Iv1.1234567890abcdef  # Your actual Client ID
GITHUB_CLIENT_SECRET=your_actual_secret_here  # Your actual Client Secret
GITHUB_REDIRECT_URI=app.hlavi://oauth-callback  # Keep this as-is
```

3. **Never commit the `.env` file to version control** - it's already in `.gitignore`

## Step 3: Verify Platform Configuration

The platform-specific configuration is already set up for you:

### Android ([AndroidManifest.xml](android/app/src/main/AndroidManifest.xml))

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="app.hlavi" android:host="oauth-callback" />
</intent-filter>
```

This tells Android to open your app when `app.hlavi://oauth-callback` is triggered.

### iOS ([Info.plist](ios/Runner/Info.plist))

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>app.hlavi</string>
    </array>
  </dict>
</array>
```

This tells iOS to open your app when `app.hlavi://` URLs are triggered.

## Step 4: Test OAuth Flow

1. Run the app:
   ```bash
   flutter run
   ```

2. Tap the "Sign in with GitHub" button

3. You should be redirected to GitHub in your browser

4. Authorize the app

5. You should be redirected back to the Hlavi app

6. The app should now show your authenticated state

## Troubleshooting

### "OAuth callback not working"

**Android:**
- Verify `AndroidManifest.xml` has the correct `<intent-filter>` (already configured)
- Check that the scheme is exactly `app.hlavi` (no typos)
- Try clearing app data: Settings → Apps → Hlavi → Storage → Clear Data

**iOS:**
- Verify `Info.plist` has the correct `CFBundleURLSchemes` (already configured)
- Check that the scheme is exactly `app.hlavi` (no typos)
- Try deleting the app and reinstalling

### "Invalid client_id or client_secret"

- Double-check your `.env` file has the correct credentials
- Make sure there are no extra spaces or quotes in the `.env` file
- Verify the Client ID and Secret match exactly what's shown in GitHub

### "Redirect URI mismatch"

- The callback URL in GitHub OAuth App **must** be exactly: `app.hlavi://oauth-callback`
- Check for typos in the GitHub OAuth App settings
- The callback URL is case-sensitive

### "App doesn't open after authorization"

- Verify the URL scheme is set up correctly for your platform
- On iOS: Check that the scheme in Info.plist is `app.hlavi`
- On Android: Check that AndroidManifest.xml has the intent-filter with scheme `app.hlavi`

## OAuth Scopes

The app requests the following GitHub scopes:

- `repo` - Full access to repositories (required to read/write `.hlavi` tasks)
- `read:user` - Read user profile information
- `user:email` - Access user email addresses

These scopes are necessary for the app to:
- Access your repositories
- Read and write task files in `.hlavi/` directory
- Display your profile information

## Security Notes

- Your GitHub token is stored securely using `flutter_secure_storage`
- The token is never transmitted except to GitHub's API
- The `.env` file is excluded from version control
- Never share your Client Secret publicly

## Alternative: Web OAuth Flow

If mobile OAuth doesn't work (e.g., in simulator/emulator), you can alternatively:

1. Use the web version at `https://hlavi.app` to authenticate
2. The mobile app can detect and use the same session (future feature)

## Reference

- [GitHub OAuth Documentation](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps)
- [flutter_appauth Documentation](https://pub.dev/packages/flutter_appauth)
- [Deep Linking in Flutter](https://docs.flutter.dev/ui/navigation/deep-linking)
