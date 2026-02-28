# Caching and UX Improvements

## Issues Fixed

### 1. ✅ Added Provider Caching
**Problem:** Data was reloaded from scratch every time (no caching)

**Solution:** Implemented `keepAlive()` with timers on all FutureProviders

**Cache Durations:**
- **Repositories:** 5 minutes
- **Branches:** 5 minutes per repository
- **Tasks:** 1 minute per repo/branch
- **.hlavi Check:** 5 minutes per repo/branch

**How it works:**
```dart
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  // Keep alive for 1 minute to cache results
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 1), link.close);

  // ... fetch data
});
```

**Benefits:**
- Switching branches quickly uses cached data
- Navigating away and back doesn't refetch
- Reduces GitHub API calls (5000/hour limit)
- Faster perceived performance

### 2. ✅ Added Shimmer Loading Effect
**Problem:** Boring loading spinners, no visual feedback like web app

**Solution:** Created `StatCardShimmer` widget with animated shimmer effect

**File:** [lib/shared/widgets/stat_card_shimmer.dart](lib/shared/widgets/stat_card_shimmer.dart)

**What it does:**
- Shows 4 animated shimmer placeholders during loading
- Matches the layout of actual stat cards
- Uses `shimmer` package (already in dependencies)
- Mimics web app's skeleton loading

**Before:**
```
Loading...
  [Spinner]
```

**After:**
```
Statistics
[Shimmer] [Shimmer]
[Shimmer] [Shimmer]
```

### 3. ✅ Updated Dashboard to Use Shimmer
**File:** [lib/features/dashboard/presentation/screens/dashboard_screen.dart](lib/features/dashboard/presentation/screens/dashboard_screen.dart)

**Changes:**
- Loading state now shows shimmer grid instead of spinner
- Maintains same layout as loaded state
- Better user experience with skeleton screens

## Files Modified

1. **[lib/features/repository/presentation/providers/repository_providers.dart](lib/features/repository/presentation/providers/repository_providers.dart)**
   - Added `dart:async` import
   - Added caching to `repositoriesProvider` (5 min)
   - Added caching to `branchesProvider` (5 min)
   - Added caching to `hasHlaviDirectoryProvider` (5 min)

2. **[lib/features/tasks/presentation/providers/task_providers.dart](lib/features/tasks/presentation/providers/task_providers.dart)**
   - Added `dart:async` import
   - Added caching to `tasksProvider` (1 min)

3. **[lib/features/dashboard/presentation/screens/dashboard_screen.dart](lib/features/dashboard/presentation/screens/dashboard_screen.dart)**
   - Added `StatCardShimmer` import
   - Updated loading state to show shimmer grid

4. **[lib/shared/widgets/stat_card_shimmer.dart](lib/shared/widgets/stat_card_shimmer.dart)** *(new file)*
   - Created shimmer loading placeholder

## How to Test

### Test Caching:
1. Select a repository and branch → wait for tasks to load
2. Switch to a different branch → data loads from scratch (expected)
3. **Switch back to original branch → data loads instantly from cache** ✨
4. Wait 1 minute → switch branches again → data refetches (cache expired)

### Test Shimmer:
1. Select a repository with `.hlavi` directory
2. While tasks are loading, you should see:
   - "Statistics" header
   - 4 animated shimmer cards in a grid
   - Smooth animation (grey → light grey → grey)
3. Once loaded, shimmer disappears and real stat cards appear

## Cache Strategy Explained

### Why Different Cache Times?

**Repositories (5 min):**
- User's repo list doesn't change frequently
- Expensive to fetch (GitHub API rate limit)
- Can be stale without major issues

**Branches (5 min):**
- Branch lists change infrequently
- Safe to cache longer
- Per-repository caching (different repos = different caches)

**Tasks (1 min):**
- Tasks change more frequently during active development
- Shorter cache ensures recent changes are visible
- Balance between freshness and performance

**.hlavi Check (5 min):**
- Directory rarely gets added/removed
- Can cache longer
- Per repo/branch combination

### Manual Cache Invalidation

Caching is **automatically invalidated** when:
- Repository changes (new repo selected)
- Branch changes (new branch selected)
- Task is created/updated/deleted (via `taskMutationsProvider`)
- User pulls to refresh

**Pull-to-refresh:**
```dart
ref.invalidate(repositoriesProvider);
ref.invalidate(tasksProvider);
```

## Architecture Benefits

### Before (No Caching):
```
User switches branch
    ↓
selectedBranchProvider updates
    ↓
tasksProvider rebuilds
    ↓
GitHub API call (EVERY TIME)
    ↓
Wait for response...
    ↓
Update UI
```

### After (With Caching):
```
User switches branch
    ↓
selectedBranchProvider updates
    ↓
tasksProvider rebuilds
    ↓
Check cache: HIT! (if within 1 min)
    ↓
Update UI INSTANTLY ✨
```

## Performance Impact

### API Calls Reduced:
- **Before:** Every branch switch = API call
- **After:** Only first access within cache window

### Example Scenario:
User switches between 3 branches checking tasks:
- **Before:** 3 API calls
- **After:** 3 API calls initially, then 0 for next minute

User returns to dashboard after 30 seconds:
- **Before:** 1 API call (refetch everything)
- **After:** 0 API calls (all cached)

## User Experience Improvements

1. **Faster Navigation:**
   - Branch switching feels instant when cached
   - No waiting for data you just saw

2. **Better Loading States:**
   - Shimmer indicates what's loading
   - Layout doesn't shift when data arrives
   - Professional skeleton screens like modern apps

3. **Reduced API Pressure:**
   - Fewer GitHub API calls
   - Less chance of hitting rate limits
   - More sustainable for active users

4. **Smart Invalidation:**
   - Cache auto-expires after reasonable time
   - Manual refresh still works (pull-to-refresh)
   - Mutations invalidate cache (always fresh after edits)

## Next Steps

Consider adding:
- **Offline caching with Hive** - Persist cache to disk for offline viewing
- **Background refresh** - Update cache in background when stale
- **Cache size limits** - Prevent unlimited memory growth
- **Cache metrics** - Track hit/miss rates for optimization

---

**Status:** ✅ All improvements implemented!

The app now provides a much better UX with instant navigation and smooth loading states.
