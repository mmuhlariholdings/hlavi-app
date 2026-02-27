# Hlavi Mobile App

A sleek, modern Flutter mobile application for task management with GitHub integration. Inspired by Shopify and Shop app design.

## Features

- **GitHub OAuth Authentication** - Sign in securely with your GitHub account
- **Repository & Branch Management** - Select repositories and switch branches
- **Dashboard View** - Overview with task statistics
- **Kanban Board View** - Visual task management with collapsible columns
- **Timeline View** - Custom Gantt chart for task visualization
- **Agenda View** - Date-filtered task organization
- **Task CRUD Operations** - Create, read, update tasks with optimistic UI updates
- **Acceptance Criteria** - Manage task acceptance criteria with progress tracking
- **Offline Support** - Multi-level caching for offline viewing
- **Material Design 3** - Modern, clean UI with Space Grotesk font

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Project Structure](#project-structure)
- [Development](#development)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- iOS development: Xcode (Mac only)
- Android development: Android Studio

## Setup Instructions

### 1. Install Flutter

Follow the official Flutter installation guide: https://docs.flutter.dev/get-started/install

### 2. Clone the Repository

```bash
git clone https://github.com/mmuhlariholdings/hlavi.git
cd hlavi/hlavi-app
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Download Space Grotesk Font

1. Download Space Grotesk font from [Google Fonts](https://fonts.google.com/specimen/Space+Grotesk)
2. Extract the font files
3. Copy the following files to `assets/fonts/`:
   - `SpaceGrotesk-Regular.ttf`
   - `SpaceGrotesk-Medium.ttf`
   - `SpaceGrotesk-SemiBold.ttf`
   - `SpaceGrotesk-Bold.ttf`

### 5. Configure GitHub OAuth

1. Create a GitHub OAuth App:
   - Go to https://github.com/settings/developers
   - Click "New OAuth App"
   - Set **Application name**: "Hlavi Mobile"
   - Set **Homepage URL**: `https://your-domain.com` (or any URL)
   - Set **Authorization callback URL**: `app.hlavi://oauth-callback`
   - Click "Register application"

2. Copy the `.env.example` file to `.env`:
   ```bash
   cp .env.example .env
   ```

3. Update `.env` with your OAuth credentials:
   ```env
   GITHUB_CLIENT_ID=your_github_client_id_here
   GITHUB_CLIENT_SECRET=your_github_client_secret_here
   GITHUB_REDIRECT_URI=app.hlavi://oauth-callback
   ```

### 6. Generate Code

Run the build runner to generate necessary code (Freezed, Riverpod, JSON serialization):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 7. Platform-Specific Setup

#### Android

1. Open `android/app/src/main/AndroidManifest.xml`
2. The OAuth redirect intent-filter should already be configured:

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="app.hlavi" android:host="oauth-callback" />
</intent-filter>
```

#### iOS

1. Open `ios/Runner/Info.plist`
2. The URL scheme should already be configured:

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

### 8. Run the App

```bash
# For iOS (Mac only)
flutter run -d ios

# For Android
flutter run -d android

# For a specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Root widget with providers
├── core/                     # Shared infrastructure
│   ├── api/                 # HTTP client, API client
│   ├── cache/               # Hive configuration
│   ├── routing/             # go_router configuration
│   ├── theme/               # App theme and colors
│   ├── config/              # Environment configuration
│   └── utils/               # Utilities and extensions
├── features/                # Feature modules (Clean Architecture)
│   ├── auth/                # Authentication
│   ├── dashboard/           # Dashboard view
│   ├── board/               # Kanban board
│   ├── timeline/            # Gantt chart timeline
│   ├── agenda/              # Date-filtered view
│   ├── tasks/               # Task management
│   └── repository/          # Repository selection
└── shared/                  # Shared widgets and providers
```

## Development

### Code Generation

Whenever you modify Freezed models, Riverpod providers, or JSON serialization:

```bash
# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/task_test.dart
```

## Architecture

The app follows **Clean Architecture** principles with feature-first organization:

- **Data Layer**: API clients, data sources, models (DTOs)
- **Domain Layer**: Entities, repositories (interfaces), use cases
- **Presentation Layer**: Screens, widgets, Riverpod providers

**State Management**: Riverpod 2.x with code generation

**Offline Support**: Multi-level caching:
- In-memory cache (1 minute)
- Hive persistent storage
- SharedPreferences for preferences

**Optimistic Updates**: UI updates immediately, rolls back on error

## Troubleshooting

### "GitHub OAuth not working"
- Verify `.env` file has correct credentials
- Check that callback URL in GitHub OAuth App matches `app.hlavi://oauth-callback`
- Ensure AndroidManifest.xml (Android) or Info.plist (iOS) has correct intent-filter/URL scheme

### "Space Grotesk font not displaying"
- Ensure font files are in `assets/fonts/` directory
- Verify `pubspec.yaml` has correct font configuration
- Run `flutter clean && flutter pub get`

### "Build runner errors"
- Delete generated files: `find . -name "*.g.dart" -delete && find . -name "*.freezed.dart" -delete`
- Run: `flutter pub run build_runner build --delete-conflicting-outputs`

### "Hive errors"
- Clear app data or uninstall/reinstall the app
- Hive version conflicts can occur if box structure changes

## Contributing

Take a moment to review our [contribution guide](../CONTRIBUTING.md) before submitting your first pull request.

Make sure that you check for open issues and pull requests to see if someone else is working on something similar.

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Run tests: `flutter test`
4. Format code: `flutter format lib/`
5. Analyze: `flutter analyze`
6. Commit: `git commit -m "Add your feature"`
7. Push: `git push origin feature/your-feature`
8. Create a Pull Request

## Contact

For feedback, requests or enquiries:

🌐 [http://www.mmuhlariholdings.co.za](http://www.mmuhlariholdings.co.za)
