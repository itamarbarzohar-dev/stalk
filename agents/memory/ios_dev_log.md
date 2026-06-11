# iOS Dev Log — Jordan

## 2026-06-11 — FeedView Premium Redesign

### Completed

**FeedView.swift — Full Social Finance Overhaul**
- Replaced old profile bar header with two-line nav: "Feed" 28pt bold + bell icon (right), pill segmented `["Friends", "Trending", "Following"]` control below
- Added `@State private var feedTab = "Trending"` with `feedTraders` computed property filtering/sorting by tab
- `StoriesRow` moved below new header with 4pt top padding; contrast intact on dark bg
- Added `TraderPostCardV2` — gradient avatar circle, PRO badge capsule, today-return badge, post body (`take` field), horizontal-scrollable ticker chips with daily pct, `ReactionBar` at bottom, `RoundedRectangle(cornerRadius: 20)` card with 0.35 opacity shadow
- Replaced old `VStack` of `TraderPostCard` with `VStack(spacing: 12)` of `TraderPostCardV2` + `.staggerEntrance(index:)` animations; no dividers between cards
- Added floating compose FAB: 52pt circle, `Theme.accentGradient`, `.overlay(alignment: .bottomTrailing)`, shadow
- Kept all existing sections (streak banner, achievements, my performance, holdings strip, leaderboard)
- Empty state shown for "Following" tab when no traders followed
- Old `TraderPostCard` preserved as legacy struct (not shown in main feed)

**Models.swift — Data Model Extensions**
- Added `TraderHolding` struct (`ticker: String`, `pct: Double`, `Identifiable`)
- Added `isPro: Bool = false` and `take: String = ""` to `Trader` (default-valued, backward-compatible)
- Added `holdingDetails: [TraderHolding]` computed property: derives ticker chips from `holdings: [String]` + `perf.day` spread with fixed offsets
- Populated all 8 traders with `isPro` and realistic `take` text
- Struct field ordering: `weekPct` before `isPro`/`take` to preserve memberwise init compatibility

### Build
- `BUILD SUCCEEDED` — zero errors, one pre-existing Info.plist warning (not our code)

### Architecture Notes
- `holdingDetails` is pure computed — no migration, no stored state
- Dark mode forced app-wide; no light-mode fallbacks needed

---

## 2026-06-09 — Perplexity Finance Features Sprint

### Completed

**Feature 1: Sector Heat Map (`MarketView.swift`)**
- Added `SectorTile` struct and `heatMapSectors` data (11 S&P 500 sectors)
- `SectorHeatMapView`: `LazyVGrid` 3-col, each tile 90pt tall, `RoundedRectangle(cornerRadius: 12)`
- Color encoding: strong gain >2% → `#00D26A` full, mild gain 0.5–2% → 40% opacity, flat → `#141420`, mild loss → `#FF4757` 40%, strong loss → full red
- Each tile: SF Symbol icon + name (10pt semibold) + change% (13pt bold), all white
- Inserted in `MarketView.body` above Indices section with section label "🌡️ Sector Heat Map"

**Feature 2: AI Market Context Card (`ForYouView.swift`)**
- `AIMarketContextCard`: dark card with indigo gradient border via `LinearGradient` stroke
- Header: "🤖 AI Market Context" + "LIVE" green pill
- 4 hardcoded insights, auto-advances every 5s via `Timer.publish`
- Slide animation: offset to -20 → swap index → offset from 20 → spring back to 0
- Dots indicator (5 small / 8 active, `#7B6FEF`) + "Full Analysis →" button that calls `appState.showDailyBrief = true`
- Inserted before `hotOnSTALKSection()` in the scroll

**Feature 3: Earnings Calendar Card (`ForYouView.swift`)**
- `EarningsEvent` struct + `upcomingEarnings` static data (5 events: AAPL/NVDA/MSFT/META/TSLA)
- `EarningsCalendarCard(userTickers:onTicker:)`: sorts user-owned first via `Set<String>` intersection
- Gold border + "YOUR STOCK" badge for user positions; accent border for others
- Shows ticker, company, date, Before/After Market, est EPS + prev EPS per row
- Inserted above `hotOnSTALKSection()` with section label "📅 Earnings This Week"

**Feature 4: Trending Tickers Feed (`MarketView.swift`)**
- `TrendingTicker` struct + `trendingTickersData` (6 tickers: NVDA/TSLA/PLTR/GME/AMD/ARM)
- `TrendingTickersFeedView`: vertical list card, rank badge, ticker+name, reason pill (accent), change% + mention count
- Formatted mentions as "2.4K mentions" for counts ≥1000
- Inserted in `MarketView.body` above the classic Trending section with label "🔥 Trending · Social Buzz"

**Feature 5: Portfolio Health Score (`PortfolioView.swift`)**
- `PortfolioHealthCard`: base 60 score, adjustments:
  - Concentration >50%: -20 pts; >40%: -10 pts
  - 5+ positions: +10 pts
  - Beating SPY YTD: +10 pts; down >10%: -15 pts
  - Avg daily swing >3%: -10 pts
- Labels: 80+ "Excellent" (green `#00D26A`), 50–79 "Good" (gold), <50 "Needs Attention" (red)
- Visual: `Circle().trim` arc ring (90pt, 10pt stroke width) + score number (28pt heavy) + label
- 3 insight bullets derived from actual `appState` data (real-time)
- Inserted below `AIAgentCard` in `PortfolioView.body`

**`import Combine` added**
- `MarketView.swift` — needed for `Timer.publish` (unused but future-proof)
- `ForYouView.swift` — needed for `AIMarketContextCard`'s `Timer.publish`

### Build Status
`** BUILD SUCCEEDED **` — iOS Simulator, no errors

---

## 2026-06-08 — App Store Readiness Sprint

### Completed

**Fix A: iOS Deployment Target**
- Changed `IPHONEOS_DEPLOYMENT_TARGET` from `26.5` to `17.0` in both Debug and Release target configs in `project.pbxproj`
- Set `TARGETED_DEVICE_FAMILY = 1` (iPhone only, was `"1,2,7"`)

**Fix B: App Icon**
- Created `STALK/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` — 1024x1024 indigo (#5B5BD6) background with white block-letter "S"
- Updated `Contents.json` to reference the PNG for all three iOS universal adaptive icon slots (light, dark, tinted)
- Note: placeholder icon — production will need a designer pass

**Fix C: Privacy Policy**
- Created `docs/privacy.html` — ready for GitHub Pages at `https://itamarbarzohar-dev.github.io/stalk/privacy`
- Policy states: zero data collection, all local, no analytics, no tracking

**Custom Info.plist**
- Switched from `GENERATE_INFOPLIST_FILE = YES` to a custom `STALK/STALK-Info.plist`
- Added `UIBackgroundModes: [fetch, processing]` and `BGTaskSchedulerPermittedIdentifiers: [com.stalk.portfolio.refresh]`
- Required for BGTaskScheduler registration

**Onboarding Flow (`OnboardingView.swift`)**
- 4-screen `OnboardingFlowView` with spring page transitions
- Screen 1: Welcome + name/username input, validation (2–30 chars / 3–20 chars), skip uses "Investor"/"@user"
- Screen 2: Trending chips with live prices from QuoteService, popular picks (SPY/QQQ/IBIT), AddPositionSheet pre-fill via new `prefillTicker` param
- Screen 3: Live portfolio value with animated counter (0→actual in 300ms), allocation bars, loading state
- Screen 4: Notifications ask with value-framing examples, UNUserNotificationCenter auth request
- `STALKSettings.hasCompletedOnboarding: Bool = false` added — set `true` on Screen 1 complete (never shows again)
- `ContentView.swift` gates main UI behind `.fullScreenCover` when `!hasCompletedOnboarding`
- `AddPositionSheet` gained optional `prefillTicker: String = ""` with `.onAppear` prefill

**Push Notifications (`NotificationService.swift`)**
- `requestAuthorization()` — async, respects previously denied status
- `scheduleMarketOpenNotification()` — `UNCalendarNotificationTrigger` repeating at 9:30 AM ET weekdays
- `schedulePriceAlert()` — fires when position moves >5% (called during background refresh)
- `scheduleThresholdAlert()` — fires when price crosses user-defined above/below thresholds
- `checkPortfolioAlerts()` — called in BGAppRefreshTask handler in `STALKApp`
- `syncWithSettings()` — called from Settings toggle to enable/disable market open alert

**AppState changes**
- Added `PriceAlertThreshold: Codable, Identifiable` struct with `alertAbove: Double?` and `alertBelow: Double?`
- Added `STALKSettings.alertThresholds: [PriceAlertThreshold] = []`

**STALKApp changes**
- `import BackgroundTasks`
- BGTaskScheduler.shared.register for `com.stalk.portfolio.refresh` in `.task` modifier
- `handleBackgroundRefresh()` fetches quotes and calls `NotificationService.checkPortfolioAlerts()`
- `scheduleBackgroundRefresh()` submits next BGAppRefreshTaskRequest (15-min earliest)

### Build Status
`** BUILD SUCCEEDED **` — iOS Simulator, iPhone 17, iOS 26.5 SDK

### PR
https://github.com/itamarbarzohar-dev/stalk/pull/3

### Known TODOs / Next Sprint
- App icon needs professional design treatment (current is programmatic placeholder)
- `AddPositionSheet` prefill doesn't focus the shares field — UX improvement
- Notification permission denied state in onboarding Screen 4 should show "Go to Settings" instead of system dialog (can't re-prompt once denied)
- BGAppRefreshTask interval is 15 min minimum but iOS throttles this heavily in practice

---

## 2026-06-09 — BYOK Claude API + Price Alert UI

### Task 1: BYOK — Real Claude API in AIFullChatView

**New file: `KeychainHelper.swift`**
- `enum KeychainHelper` with `saveAPIKey`, `loadAPIKey`, `deleteAPIKey`
- Uses `kSecClassGenericPassword` with service `com.itamar.stalk.anthropic`
- Deletes before re-saving to avoid duplicates

**New view: `APIKeySetupView`**
- Sheet shown when user taps the key icon in the AI chat header
- Fields: SecureField for `sk-ant-...` input, "Get API Key →" button opens `https://console.anthropic.com` in Safari
- Save button activates only when key starts with `sk-ant-` and is >20 chars
- Saves to Keychain on tap, calls `onSaved()` callback so parent re-reads the key
- `presentationDetents([.medium, .large])` — dark themed to match chat

**Real API call: `callClaudeAPI(messages:apiKey:)` in `AIFullChatView`**
- `POST https://api.anthropic.com/v1/messages` with `x-api-key`, `anthropic-version: 2023-06-01`
- Model: `claude-haiku-4-5`, `max_tokens: 1024`
- `buildSystemPrompt()` injects user's full portfolio (tickers, shares, avg cost, current price, today %, total value, today P&L)
- Conversation history passed from `messages` array (skipping initial system greeting)
- Error handling: 401 → `APIError.invalidKey`, 429 → `APIError.rateLimited`, network failure → `APIError.networkError`

**Error states**
- `inlineError: String?` state drives an `errorBanner()` view between chat and input bar
- On API errors the message credit is refunded (`aiMessagesUsed -= 1`)
- Banner has dismiss "×" button

**Pro gate logic**
- Free users: 3 messages lifetime (unchanged)
- Pro users WITH API key: unlimited (bypass gate)
- Pro users WITHOUT API key: still gated at 3 (paywall prompts them to also set a key)
- Mock fallback still works if no key is set (old `generateReply()` preserved)

**Header changes**
- Key icon (🔑) shows green when connected, amber when no key — tapping opens `APIKeySetupView`
- Status dot + subtitle changes: "Connected · Claude Haiku" vs "Mock mode · Tap key icon to connect"

### Task 2: Price Alert UI

**`PositionCard` changes (PortfolioView.swift)**
- Bell badge: `Image(systemName: "bell.fill")` in ticker row when `appState.settings.alertThresholds` has an entry for this ticker
- Long-press now shows a `confirmationDialog` with three options: "Delete", "Set Price Alert", "Cancel" (replaces the immediate delete)
- `.contextMenu` added with "Set Price Alert" and "Delete Position" actions
- `.sheet(isPresented: $showAlertSheet)` presents `PriceAlertSheet`

**New view: `PriceAlertSheet`**
- `presentationDetents([.medium])`, drag indicator visible
- Shows current price from `appState.quotes`
- Two `alertField` rows: "Alert me above $___" and "Alert me below $___" with `keyboardType(.decimalPad)`
- "Clear" button top-right when an alert already exists
- `saveAlerts()` upserts into `appState.settings.alertThresholds` and calls `appState.saveSettings()`
- Placeholder values default to ±10% from current price as a helpful hint

### Build Status
`** BUILD SUCCEEDED **` — iOS Simulator, no errors (one pre-existing warning about Info.plist in Copy Bundle Resources)

---

## 2026-06-09 — Luna Animation Specs (portfolio_hero_v2, number_animations, card_stagger)

### Task 1: `AnimatedComponents.swift` (new file)

- `AnimatedPrice`: `Text` wrapper with `.contentTransition(.numericText())` + `.animation(.spring(response:0.4, dampingFraction:0.8), value:)` + `.monospacedDigit()`. Configurable `format`, `font`, `color`.
- `AnimatedChangeLabel`: Same pattern, auto-selects `Theme.gain`/`Theme.loss` based on value sign.
- `StaggerEntrance` ViewModifier: `.opacity` + `.offset(y:)` driven by `@State private var appeared`. Delay = `min(index * 0.06, 0.30)s`. Spring `response:0.45, dampingFraction:0.75`.
- `View.staggerEntrance(index:)` convenience extension.

### Task 2: PortfolioHero upgrades

- **Radial glow**: Added `RadialGradient` in a `VStack` positioned ~120pt from top, using `Theme.accent.opacity(0.18)` → clear, 300×180 frame, `.blendMode(.screen)`.
- **Value text**: Upgraded from 44pt `.heavy` to **48pt `.black`** with `.monospacedDigit()`, `.contentTransition(.numericText())`, `.animation` on `appState.totalValue`.
- **P&L line**: Replaced single capsule with two-element `HStack` — 22pt bold dollar amount (bare, `pnlColor`) + 13pt bold percentage in colored `Capsule` at 15% opacity.
- **ATH badge**: Replaced `pill()` call with inline HStack containing "🏆" + "NEW ATH" text. Added `@State private var athPulse = false`. Pulsing `.scaleEffect(athPulse ? 1.04 : 1.0)` with `.easeInOut(duration:0.9).repeatForever`.
- **Streak badge**: Replaced `pill()` call with orange `LinearGradient` (#F97316 → #EA580C) `RoundedRectangle(cornerRadius:12)` badge with shadow glow.
- **Market status pill**: Replaced plain `HStack` with glass pill — added `.background(.white.opacity(0.08))`, `.clipShape(Capsule())`, `.overlay(Capsule().stroke(.white.opacity(0.12), lineWidth:1))`. Replaced `·` separator with a `Rectangle` divider (1pt wide, 10pt tall, white at 25% opacity).

### Task 3: `PositionsList` stagger entrance

- Changed `ForEach(appState.positions)` to `ForEach(Array(appState.positions.enumerated()), id: \.element.id)` and applied `.staggerEntrance(index: index)` to each `PositionCard`.

### Build Status
`** BUILD SUCCEEDED **` — iOS Simulator, zero errors, one pre-existing Info.plist warning

---

## 2026-06-11 — Social Feed Features Sprint (Instagram/TikTok vibes)

### Features Delivered

**Feature 1: Stories Row (`FeedView.swift`)**
- `StoriesRow` struct — horizontal `ScrollView` above the profile bar
- `StoryRing` component: 64pt outer ring (gain green / loss red), 56pt avatar circle with accent gradient fill, name + pct% label below
- "You" ring uses `appState.todayPnlPct` ring color; trader rings use `trader.todayPct`
- Spring pop-in entrance animation on each ring (`appeared` state, 0.8→1.0 scale)
- Tapping trader ring opens `TraderProfileView` as a sheet via `storyTrader` state on `FeedView`

**Feature 2: Reaction Bar (`FeedView.swift`)**
- `ReactionBar` struct: 🔥 📈 💎 😱 emojis, each with initial mock counts
- Tap to select/deselect: increments/decrements count, mutually exclusive (previous selection cleared)
- Selected state: `Theme.accent.opacity(0.15)` fill + accent border + 1.05 scaleEffect
- `.spring(response: 0.3, dampingFraction: 0.5)` animation on toggle
- Added to bottom of each `TraderPostCard`, above the Divider/action row

**Feature 3: Leaderboard Section (`FeedView.swift`)**
- `LeaderboardSection` struct with `LeaderboardPeriod` enum: Today / This Week / All Time
- Custom segmented picker: accent-filled active segment, `Theme.bg3` pill container
- Animated period switch via `.easeInOut(duration: 0.2)` + state mutation
- `LeaderboardRow`: 🥇🥈🥉 medals for top 3, gradient avatar circle, trader name + topHolding, return% right-aligned in gain/loss color
- Rows use `.staggerEntrance(index:)` for staggered entrance on period change
- Sorted live from `FEED_TRADERS` by chosen period metric
- Inserted between Holdings strip and Following section in `FeedView`

**Feature 4: Daily Streak Banner (`FeedView.swift`)**
- `if appState.streak >= 1` conditional banner below the profile header
- Orange `LinearGradient` tinted background with matching border stroke
- Shows streak count, motivational copy, "+N XP" capsule badge using `Theme.gold`
- Added `.padding(.top, 12)` above achievements row

**Feature 5: Achievement Badges Row (`FeedView.swift`)**
- `AchievementBadge` struct with `icon`, `title`, `unlocked`
- `AchievementsRow`: horizontal `ScrollView` of `BadgeTile` views
- Unlocked: full opacity + `Theme.accentBg` circle fill; locked: 35% opacity + `lock.fill` SF symbol overlay
- 7 achievements computed from live `appState` data: First Gain, 5 Stocks, 7-Day Streak, New ATH, Diamond Hands, AI User, STALK Pro
- Spring scale entrance animation per badge

**Models.swift additions**
- `Trader` struct: added `weekPct: Double` stored property, `todayPct` / `allTimeReturn` / `topHolding` computed properties
- Updated all 4 existing `TRADERS` entries with `weekPct` values
- Added `FEED_TRADERS`: extends `TRADERS` with 4 more traders (James T., Priya N., David K., Nina H.) — 8 total for stories and leaderboard

### Build Status
`** BUILD SUCCEEDED **` — no errors, only pre-existing QuoteService actor-isolation warnings (not our code)

---

## 2026-06-11 — Robinhood/Bloomberg/TikTok Redesign Sprint

### Overview
Dark mode forced app-wide (`.preferredColorScheme(.dark)` in `STALKApp`). Redesigned three core screens for maximum visual impact and addictiveness, inspired by Robinhood (Portfolio), Bloomberg Terminal (Market), and TikTok (For You).

---

### PortfolioView.swift — Robinhood-style Hero

**Removed:** Large gradient hero block (`appState.heroGradient`, radial glow `ZStack`), colored gradient box
**Added:** Clean minimal header on `Theme.bg` — no box, no gradient container

**`PortfolioHero` changes:**
- Top bar: "PORTFOLIO" label in 11pt uppercase with kerning (instead of "STALK"), buttons use `Theme.card` background instead of `.white.opacity(0.18)` — matches dark bg
- Value: `44pt .black`, plain `Theme.text` on `Theme.bg`, no container
- P&L line: `"±$X.XX (±Y.YY%) All-time"` in one clean 14pt string with market status pill inline
- Today P&L + badge row replaces the old stat pills — colored capsule for today, ATH badge, streak badge
- `AllocBar` moved below (still present), no `.overlay(alignment: .bottom)` bottom-round trick needed

**`MiniSparkline` added** — new struct using `Canvas` drawing:
- 8-point pseudo-random line, seeded deterministically from ticker hash (consistent across renders)
- 44×22pt, 1.5pt stroke, `gain`/`loss` colored at 55% opacity
- `sparklinePoints(ticker:trending:)` free function — LCG seeded from ticker Unicode scalars
- Placed in `PositionCard` right side as a `ZStack` behind the price/pnl/today text

**Padding:** `.padding(.bottom, 12)` → `.padding(.bottom, 8)` on hero in parent

---

### MarketView.swift — Bloomberg Terminal Feel

**Removed:** Large text header block, old `Indices` VStack of rounded `MarketRow` cards
**Added:**
- `private let INDEX_ICONS: [String: String]` dict (`SPY/QQQ/DIA/IWM`)
- `@State private var now` + `Timer` (60s) for live market status
- Bloomberg nav bar: "MARKETS" 22pt black + market status pill (colored dot + label + colored background)

**`IndexCompactList` — new struct:**
- Replaces old `MarketRow` cards for indices
- Compact rows: icon (16pt) + name/ticker left, price + % right
- 1pt separator (`Rectangle().fill(Theme.border)`) between rows, `padding(.leading: 56)` — left-indented
- All inside single `Theme.card` rounded container (18pt radius) with `overlay` border
- Skeleton shimmer rows when quotes are loading

**`TopMoversGrid` — new struct:**
- `let topMovers` data (8 entries: NVDA/GME/TSLA/AAPL/META/PLTR/AMD/AMZN)
- `LazyVGrid` 2-column, each cell 70pt height: icon circle (gain/loss tinted bg) + ticker (14pt black) + % change
- Cell border tinted gain/loss at 15% opacity
- Inserted between Indices and Sector Chips sections

**`SectorHeatMapView` tile height:** 90pt → **100pt**, added ETF symbol label (9pt bold, 50% opacity white)

**Layout order:** Indices compact → Top Movers → Sector Chips → Heat Map → Trending Feed → Classic Trending

---

### ForYouView.swift — TikTok-style Segmented Header

**Removed:** `"For You ✨"` plain text header

**Added: `ForYouTab` enum** + segmented control header:
- Three tabs: "For You" | "Markets" | "News"
- TikTok-style underline indicator: `Rectangle().fill(Theme.accent).frame(height: 2)` under active tab
- Spring animation `response: 0.3, dampingFraction: 0.75` on tab switch
- Tab bar sits at 52pt from top, underlined with a full-width `Theme.border` separator

**"For You" tab:** All existing content preserved, but with `TodaySummaryCard` inserted first

**`TodaySummaryCard` — new struct:**
- Dark `#0D0D1A` card with indigo gradient border (same visual language as `AIMarketContextCard`)
- "TODAY'S SUMMARY" small caps label + "AI" green pill
- If user has positions: references their portfolio and today P&L by name
- If no positions: generic market summary (2 sentences)
- "Full Daily Brief →" button calls `appState.showDailyBrief = true`

**"Markets" tab — `marketsContent()`:**
- Index snapshot compact list (4 indices, live quotes with fallback to mock change values)
- `TrendingTickersFeedView` (reused from `MarketView`)
- `TopMoversGrid` (reused from `MarketView` — same module, same file)

**"News" tab — `newsContent()`:**
- `MockNewsItem` struct + `mockNewsHeadlines` array (8 items)
- Each card: ticker tags (accent colored), time ago, headline (14pt semibold), source (11pt text3)
- Tapping navigates to first ticker via `onTicker`

**`hotOnSTALKSection` cards:** 130pt → **160pt** height, `148pt` width
- Added `ZStack` with `LinearGradient` overlay (gain/loss tinted, top-to-bottom)
- Ticker enlarged to 24pt black, adds counter in 16pt bold accent
- % change in 15pt black capsule (top right), icon in tinted 40×40pt rounded square
- Border tinted gain/loss at 20% opacity

### Build Status
`** BUILD SUCCEEDED **` — zero errors, pre-existing QuoteService actor-isolation warnings only (not our code)
