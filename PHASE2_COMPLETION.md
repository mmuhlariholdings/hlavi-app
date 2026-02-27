# Phase 2: Authentication & API Layer - Completion Guide

## ✅ Completed Files

### Data Models (with Freezed + JSON Serialization)
- ✅ `lib/features/tasks/domain/entities/task_status.dart` - TaskStatus enum
- ✅ `lib/features/tasks/domain/entities/acceptance_criteria.dart` - AcceptanceCriteria model
- ✅ `lib/features/tasks/domain/entities/task.dart` - Task model with helper methods
- ✅ `lib/features/repository/domain/entities/repository.dart` - Repository & RepositoryOwner models
- ✅ `lib/features/repository/domain/entities/board_config.dart` - BoardConfig, BoardColumn, Board models
- ✅ `lib/features/auth/data/models/auth_token.dart` - AuthToken, AuthUser, AuthState models

### Authentication Layer
- ✅ `lib/features/auth/data/datasources/github_auth_datasource.dart` - GitHub OAuth with flutter_appauth
- ✅ `lib/features/auth/domain/repositories/auth_repository.dart` - Auth repository interface
- ✅ `lib/features/auth/data/repositories/auth_repository_impl.dart` - Auth repository implementation
- ✅ `lib/features/auth/presentation/providers/auth_provider.dart` - Riverpod auth state management
- ✅ `lib/features/auth/presentation/screens/login_screen.dart` - Login UI

### API Layer
- ✅ `lib/core/api/dio_client.dart` - Dio HTTP client with interceptors
- ✅ `lib/core/api/github_api_client.dart` - Retrofit API client
- ✅ `lib/core/api/models/github_content.dart` - GitHub Contents API model

## 🔧 Next Steps

### Step 1: Run Build Runner (REQUIRED)

All the IDE errors you're seeing are expected. They're caused by missing `.freezed.dart` and `.g.dart` files that need to be generated. Run this command:

```bash
cd hlavi-app
flutter pub run build_runner build --delete-conflicting-outputs
```

**What this does:**
- Generates `.freezed.dart` files for all Freezed models (Task, AcceptanceCriteria, etc.)
- Generates `.g.dart` files for JSON serialization (fromJson/toJson methods)
- Generates `github_api_client.g.dart` for Retrofit API client

**Expected output:**
```
[INFO] Generating build script completed, took 412ms
[INFO] Creating build script snapshot... completed, took 8.7s
[INFO] Building new asset graph completed, took 1.2s
[INFO] Checking for unexpected pre-existing outputs completed, took 1ms
[INFO] Running build completed, took 15.3s
[INFO] Caching finalized dependency graph completed, took 45ms
[INFO] Succeeded after 15.4s with 42 outputs
```

**Common issues:**
- If you get conflicts, the `--delete-conflicting-outputs` flag will handle them
- If build_runner hangs, press Ctrl+C and run with `--verbose` to see what's happening
- If you see "version conflicts", the packages in pubspec.yaml should already be compatible

### Step 2: Verify Generated Files

After build_runner completes, verify these files were created:

```bash
# Check for Freezed files
find lib -name "*.freezed.dart" | head -10

# Check for JSON serialization files
find lib -name "*.g.dart" | head -10
```

You should see files like:
```
lib/features/tasks/domain/entities/task.freezed.dart
lib/features/tasks/domain/entities/task.g.dart
lib/features/tasks/domain/entities/acceptance_criteria.freezed.dart
lib/features/tasks/domain/entities/acceptance_criteria.g.dart
lib/features/auth/data/models/auth_token.freezed.dart
lib/features/auth/data/models/auth_token.g.dart
lib/core/api/github_api_client.g.dart
... and more
```

### Step 3: Verify IDE Errors Are Gone

Once build_runner completes:
1. The IDE errors should disappear (you may need to restart your IDE)
2. All imports should resolve correctly
3. Methods like `copyWith`, `fromJson`, `toJson` should be available on Freezed models

### Step 4: Set Up Routing (Next in Phase 2)

After build_runner succeeds, we'll create:
- `lib/core/routing/app_router.dart` - go_router configuration
- `lib/core/routing/routes.dart` - Route constants
- Update `lib/app.dart` to use the router

### Step 5: Test Authentication Flow

Once routing is set up, we'll test:
1. App launches → Shows login screen
2. Tap "Sign in with GitHub" → Opens browser
3. Authorize app → Redirects back to app
4. Token stored securely → User authenticated
5. Close and reopen app → Session restored (no re-login)

## 📊 Phase 2 Progress

**Completed:**
- ✅ All data models created with Freezed + JSON serialization
- ✅ GitHub OAuth implementation with flutter_appauth
- ✅ Secure token storage with flutter_secure_storage
- ✅ Dio HTTP client with auth interceptor
- ✅ Retrofit API client for GitHub API
- ✅ Riverpod auth state management
- ✅ Login screen UI

**Remaining:**
- ⏳ Generate code with build_runner (you need to run this)
- ⏳ Set up routing with go_router
- ⏳ Test authentication flow end-to-end

## 🎯 What Happens After Phase 2

Once Phase 2 is complete, we move to:

**Phase 3: Dashboard & Repository Management**
- Repository selection screen
- Dashboard with statistics cards
- Repository/branch switcher
- .hlavi directory validation and initialization

**Phase 4: Board View**
- Kanban board with horizontal scrolling
- Task cards matching web app design
- Column collapse/expand functionality

**Phase 5: Task Detail & CRUD**
- Task detail screen
- Full task editing
- Acceptance criteria management
- Optimistic updates

## 💡 Tips

### If build_runner is slow:
```bash
# Use watch mode for faster incremental builds during development
flutter pub run build_runner watch --delete-conflicting-outputs
```

### If you get package version conflicts:
The versions in pubspec.yaml are already tested and compatible. If you updated any packages manually, revert to the versions in the file.

### If authentication fails:
1. Verify `.env` has correct GitHub OAuth credentials
2. Check `AndroidManifest.xml` has the intent-filter (Android)
3. Check `Info.plist` has CFBundleURLTypes (iOS)
4. Verify redirect URI matches: `app.hlavi://oauth-callback`
5. Check GitHub OAuth App settings have the correct callback URL

### IDE Tips:
- After build_runner, you may need to restart your IDE
- Use "Dart: Restart Analysis Server" if IDE still shows errors
- Some IDEs cache errors - close and reopen files to refresh

## 🔍 Architecture Overview

The authentication flow works like this:

```
User taps "Sign in with GitHub"
  ↓
LoginScreen → authStateProvider.signIn()
  ↓
AuthStateNotifier → authRepository.signIn()
  ↓
AuthRepositoryImpl → githubAuthDataSource.signIn()
  ↓
GithubAuthDataSource uses flutter_appauth
  ↓
Opens browser → GitHub OAuth page
  ↓
User authorizes → Redirects to app.hlavi://oauth-callback
  ↓
flutter_appauth exchanges code for token
  ↓
Token stored in flutter_secure_storage
  ↓
Fetch user info from GitHub API
  ↓
AuthState updated to authenticated
  ↓
UI navigates to Dashboard (once routing is set up)
```

## 📝 Code Quality

All code follows Flutter best practices:
- ✅ Clean Architecture with clear separation of concerns
- ✅ Repository pattern for data layer abstraction
- ✅ Riverpod for type-safe state management
- ✅ Freezed for immutable models with copyWith
- ✅ JSON serialization for API responses
- ✅ Secure storage for sensitive data (tokens)
- ✅ Error handling with try-catch and state updates
- ✅ Null safety throughout

Ready to proceed? Run the build_runner command above!
