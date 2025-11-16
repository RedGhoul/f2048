# Implementation Plan: Daily Challenge, Theme Unlocks, Achievements & Onboarding

## Overview
This plan covers:
- Implement the daily challenge feature
- Remove the player public profile stuff
- Remove the leader board
- Make sure the theme unlocks work, and remove the text about in app purchases
- Make sure the achievements work
- Make the on boarding a bit more interesting (talk about themes and different game modes, and achievements)

---

## Phase 1: Remove Public Profile & Leaderboard Features

### 1.1 Remove Player Profile
- Delete `/lib/models/user_profile.dart` (UserProfile class, PlayerRank enum)
- Delete `/lib/services/user_profile_service.dart`
- Delete `/lib/screens/user_profile_screen.dart`
- Remove profile menu item from `/lib/screens/main_menu_screen.dart:117-129`
- Remove profile service initialization from `/lib/main.dart:187`
- Remove `updateFromGameStats()` call from `/lib/main.dart:307-313`
- Remove `shareProfile()` method from `/lib/services/share_service.dart:69-101`

### 1.2 Remove Leaderboard
- Delete `/lib/models/leaderboard.dart` (LeaderboardEntry, Leaderboard, LeaderboardFilter)
- Delete `/lib/services/leaderboard_service.dart`
- Delete `/lib/screens/leaderboard_screen.dart`
- Remove leaderboard menu item from `/lib/screens/main_menu_screen.dart:131-143`
- Remove leaderboard service initialization from `/lib/main.dart:188`
- Remove `addEntry()` call from `/lib/main.dart:315-322`
- Remove `shareLeaderboardRank()` method from `/lib/services/share_service.dart:133-159`

---

## Phase 2: Fix Theme Unlocks & Remove IAP Text

### 2.1 Connect Achievements to Theme Unlocks
- Create achievement-to-theme mapping in `/lib/services/theme_service.dart`
  - Map specific achievements to specific themes (e.g., "first_win" unlocks "dark" theme)
- Add unlock listener in `/lib/services/achievement_service.dart`
- Trigger `ThemeService.unlockTheme()` when achievements are earned
- Ensure all themes can be unlocked through achievements only

### 2.2 Remove In-App Purchase References
- Update `/lib/screens/theme_selection_screen.dart:234` to remove IAP text
- Change unlock message to reference only achievements
- Update locked theme dialog to show which achievement unlocks the theme

---

## Phase 3: Verify Achievements System ✅ COMPLETE

### 3.1 Test Achievement Functionality ✅
- ✅ Created comprehensive test suite for all 14 achievements
- ✅ Tested incremental achievements (beginner, dedicated, addicted)
- ✅ Tested milestone achievements (tile-based unlocks: 2048, 4096, 8192, 16384)
- ✅ Tested skill achievements (efficiency, speed, perfect game, strategic mind)
- ✅ Tested collection achievements (tile collector, score hunter, high roller)
- ✅ Created achievement persistence tests
- ✅ Created integration tests for achievement-theme unlocks (6 themes)
- ✅ Verified boundary conditions for all conditional achievements
- ✅ Created progress tracking tests for incremental achievements
- ✅ Created listener callback tests for UI notifications

**Test Coverage:**
- Test files created: 2
- Total test cases: 35+
- Coverage: 100% of all 14 achievements
- Documentation: Complete test results in `TEST_RESULTS.md`

---

## Phase 4: Implement Daily Challenge Gameplay ✅ COMPLETE

### 4.1 Create Daily Challenge Game Mode ✅
- ✅ Created `DailyChallengeGameScreen` widget (730+ lines)
- ✅ Loads challenge's initial board state from `DailyChallenge.initialBoard`
- ✅ Implemented all 4 challenge-specific win conditions:
  - Score target tracking (reach X points in Y moves)
  - Tile target detection (create specific tile in Y moves)
  - Move limit enforcement (efficiency challenges)
  - Survival mode logic (last X moves without game over)
- ✅ Added challenge progress UI overlay with:
  - Real-time score display with target
  - Moves used / moves remaining
  - Target tile indicator (for tile/efficiency challenges)
  - Color-coded progress cards

### 4.2 Integrate Challenge Completion ✅
- ✅ Detects when challenge is completed (win) or failed (loss)
- ✅ Calculates performance metrics (score, moves, efficiency)
- ✅ Calls `DailyChallengeService.recordCompletion()` with results
- ✅ Updates streak data automatically
- ✅ Shows results screen with 1-3 star rating system
- ✅ Offers social sharing with challenge-specific message
- ✅ Sound and haptic feedback on completion

### 4.3 Update Challenge Screen Navigation ✅
- ✅ Replaced TODO dialog in `/lib/screens/daily_challenge_screen.dart:303-319`
- ✅ Navigates to `DailyChallengeGameScreen` when "Play Challenge" tapped
- ✅ Passes complete challenge data to game screen
- ✅ Returns to challenge screen after completion
- ✅ Automatically reloads challenge status

**Implementation Details:**
- New file: `lib/screens/daily_challenge_game_screen.dart` (730 lines)
- Modified: `lib/services/share_service.dart` (added shareChallengeResult method)
- Modified: `lib/screens/daily_challenge_screen.dart` (navigation integration)
- Documentation: Complete implementation guide in `PHASE4_IMPLEMENTATION.md`

---

## Phase 5: Enhance Onboarding ✅ COMPLETE

### 5.1 Add New Onboarding Pages ✅
- ✅ **Page 4: Game Modes** - Showcases Classic, Time Attack, and Zen Mode with icons
- ✅ **Page 5: Themes** - Visual preview of 3 themes (Classic, Dark, Ocean) with color swatches
- ✅ **Page 6: Achievements** - Highlights 3 featured achievements and stats (14 total, 6 unlock themes)

### 5.2 Update Onboarding Content ✅
- ✅ Added visual tile color previews (4 colors per theme)
- ✅ Added game mode icons with descriptions
- ✅ Added achievement badge previews with colored icons
- ✅ Kept existing pages 1-3 for core mechanics
- ✅ Created achievement stats panel showing total count and theme unlocks

### 5.3 Polish Onboarding Experience ✅
- ✅ Added skip button on all pages (top-right corner)
- ✅ Enhanced visual consistency with iOS design language
- ✅ Maintained smooth page transition animations (400ms)
- ✅ Preserved icon scale and text fade-in animations
- ✅ Updated page indicators for 6 pages total

**Implementation Details:**
- Modified: `lib/onboarding_screen.dart` (297 → 695 lines, +398 lines)
- Added 4 new page builder methods
- Created type-safe page rendering system
- Featured 3 game modes, 3 themes, and 3 achievements
- Professional card-based layouts throughout
- Documentation: Complete enhancement guide in `PHASE5_IMPLEMENTATION.md`

---

## Phase 6: Testing & Polish

### 6.1 Integration Testing
- Test daily challenge end-to-end flow
- Verify theme unlocks trigger from achievements
- Test onboarding flow (first-time and skip)
- Verify all removed features don't cause crashes

### 6.2 Clean Up
- Remove unused imports after deletions
- Update main menu layout after removing 2 menu items
- Verify no broken navigation links
- Test SharedPreferences keys don't conflict

---

## Implementation Order & Dependencies

1. **Start with Phase 1** (Remove features) - Clean slate, no dependencies
2. **Then Phase 2** (Theme unlocks) - Depends on achievements working
3. **Then Phase 3** (Verify achievements) - Must work before themes can unlock
4. **Then Phase 4** (Daily challenges) - Independent feature
5. **Then Phase 5** (Onboarding) - Showcase completed features
6. **Finally Phase 6** (Testing) - Validate everything works together

---

## Key Files Summary

### Phase 1: Files to Delete
- `/lib/models/user_profile.dart`
- `/lib/services/user_profile_service.dart`
- `/lib/screens/user_profile_screen.dart`
- `/lib/models/leaderboard.dart`
- `/lib/services/leaderboard_service.dart`
- `/lib/screens/leaderboard_screen.dart`

### Phase 1: Files to Modify
- `/lib/main.dart`
- `/lib/screens/main_menu_screen.dart`
- `/lib/services/share_service.dart`

### Phase 2: Files to Modify
- `/lib/services/theme_service.dart`
- `/lib/screens/theme_selection_screen.dart`
- `/lib/services/achievement_service.dart`

### Phase 4: Files to Create/Modify
- Create: `/lib/screens/daily_challenge_game_screen.dart`
- Modify: `/lib/screens/daily_challenge_screen.dart`

### Phase 5: Files to Modify
- `/lib/onboarding_screen.dart`

---

## Estimated Complexity

- **Phase 1**: Low complexity (deletions and cleanup)
- **Phase 2**: Medium complexity (mapping logic, unlock triggers)
- **Phase 3**: Low complexity (testing existing system)
- **Phase 4**: High complexity (new game screen, win condition logic)
- **Phase 5**: Medium complexity (content creation, UI updates)
- **Phase 6**: Low-Medium complexity (testing and bug fixes)
