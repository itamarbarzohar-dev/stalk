# STALK Screen-by-Screen Design Audit
**Version 1.0 — June 2026**
**Authored by Luna (UX Designer Agent)**

---

## Audit Summary

The single biggest issue across every screen: **the app is light-mode**. Theme.swift defines white cards on light gray backgrounds. Every card, every background, every border is built for a light UI. The direction is explicitly dark — `#0A0A0F` backgrounds, `#111118` cards, dark semantic colors. This is a full dark-mode migration, not a tweak.

The second issue: **shadows do not work on dark backgrounds**. Every card uses `shadow(color: .black.opacity(0.04))` which is invisible against dark surfaces. Replace with glow-based or inner-border depth system.

The third issue: **emoji-driven UI**. "📋 Daily Brief", "📈 vs Market", "⚡ Live Feed" use emoji as the sole iconography. On a premium dark UI these read as playful/casual. SF Symbols should carry the load; emoji used sparingly and intentionally (e.g. country flags, ATH trophy).

---

## Screen 1: Portfolio

### What Currently Looks Dated / Wrong

1. **Light background (#F7F8FC)** — entire screen is washed-out, light gray. No depth.
2. **Hero gradient bleeds into light bg** — `heroGradient` from AppState transitions into `Theme.bg` which is near-white. The scrim overlay `RoundedRectangle(cornerRadius: 36).fill(Theme.bg)` creates a visible white blob at the bottom of the hero.
3. **Portfolio total value** — 44pt Heavy is close but not the final spec. Should be 48pt Black with `.monospacedDigit()` and `.contentTransition(.numericText())` for animated price updates.
4. **PnL pill** — `.background(isGain ? .white.opacity(0.2) : Color(hex: "#E5534B").opacity(0.35))` — loss pill reads okay on the gradient but gain pill (white tint) nearly disappears. Needs distinct gain/loss colors both visible.
5. **Stat pills (Today / ATH / Streak)** — pill background is `.white.opacity(0.15)` — these are barely readable. They need opaque semantic colors.
6. **AllocBar** — 5pt height, gap of 2pt between segments. Too thin to read. Segments are not individually labeled. Could be a meaningful visualization at 8pt with a gap of 1pt and visible labels on hover.
7. **White cards (PositionCard)** — `Theme.card` = white with `Theme.border` = #EBEBF0. On a light bg these have essentially no contrast edge. On the new dark system they become `#111118` on `#0A0A0F` — good separation, but currently wrong.
8. **Gain/Loss background tints in PositionCard** — `Theme.gainBg = #ECFDF5` and `Theme.lossBg = #FEF2F2` are light-mode tints. On dark cards these look like mis-applied colors.
9. **Add FAB** — correct concept, accent gradient, shadow. But shadow `opacity(0.4)` will need to increase to `opacity(0.5)` on dark. Padding `.padding(.bottom, 88)` should be 96pt to clear the new tab bar.
10. **AIAgentCard** — currently uses dark gradient (`#1A1040 → #2D1B6E`) — this is the ONE card that's already dark. It looks out of place against the white app. When app goes dark it will look correct.
11. **VsMarketCard / VsFriendsCard** — white cards with `Theme.gainBg`/`Theme.lossBg` semantic fills that are light. Must invert.
12. **LiveFeedCard** — icon backgrounds `event.accent.opacity(0.12)` look fine in concept. On dark this will pop more — keep approach, validate contrast.
13. **Section label "Long-press a card to delete"** — functional but ugly. On dark it should be `text4` color, centered, small.

### Specific Improvements

| Element | Change | Priority |
|---|---|---|
| `ScrollView` background | `Theme.bg` → `#0A0A0F` | 🔴 |
| Portfolio hero scrim | White blob → `#0A0A0F` blob | 🔴 |
| Portfolio value font | 44pt Heavy → 48pt Black, `.monospacedDigit()`, `.contentTransition(.numericText())` | 🔴 |
| PnL pill colors | White tint gain → `#00D26A` tinted bg; Loss stays red | 🔴 |
| Stat pills | `.white.opacity(0.15)` → semantic color fills at `.opacity(0.18)` | 🔴 |
| All card backgrounds | `Color.white` → `#111118` | 🔴 |
| All card borders | `#EBEBF0` → `rgba(255,255,255,0.06)` | 🔴 |
| Gain/Loss chip in PositionCard | Light mode tints → dark tints `gain.opacity(0.15)` / `loss.opacity(0.15)` | 🔴 |
| Card shadows | `.black.opacity(0.04)` → `.black.opacity(0.40)` | 🔴 |
| AllocBar height | 5pt → 8pt, gap 2pt → 1pt | 🟡 |
| AllocBar segment labels | None → small ticker labels below bar (collapsible) | 🟢 |
| VsMarketCard period picker | Filled active state uses `appState.accentColor` — correct, but bg tabs should be `#141420` | 🟡 |
| VsFriendsCard leaderboard | `Theme.bg2` row fill → `#141420` | 🟡 |
| FAB bottom padding | 88pt → 96pt | 🟡 |
| "Long-press to delete" label | Current style → `text4` color, 9pt | 🟢 |

---

## Screen 2: Market

### What Currently Looks Dated / Wrong

1. **Plain text title "Market"** — 26pt Bold, just floating left with `.padding(.top, 52)`. No visual hierarchy, no icon, no gradient. Looks like a default system view.
2. **Light background** — all the same issues as Portfolio screen.
3. **Section headers** — "SECTORS", "INDICES", "TRENDING" are 10pt uppercase labels styled with `Theme.text3`. Correct approach, but color is wrong in dark mode.
4. **SectorChip** — white card with light border, emoji icons, small name label. The emoji icons are inconsistent sizes. The change % is the most important info but buried at the bottom. Layout is not scannable.
5. **MarketRow** — white card, two-line left + price/change right. Minimal. No left accent, no visual weight on the important number (change %). Change percent should be in a pill/badge, not plain text.
6. **MarketRowSkeleton** — uses `Theme.bg2` as shimmer fill — will be correct `#141420` after dark mode migration. Add animation shimmer effect (currently none).
7. **No market-wide summary** — the screen opens straight into sectors. Premium apps open with an "at a glance" market summary — index futures, fear/greed, VIX. Missing entirely.
8. **No visual differentiation between green/red sectors** — all chips look identical. A chip for a sector up 3% looks the same as one down 2%.

### Specific Improvements

| Element | Change | Priority |
|---|---|---|
| Screen background | → `#0A0A0F` | 🔴 |
| All card backgrounds | → `#111118` | 🔴 |
| All card borders | → `rgba(255,255,255,0.06)` | 🔴 |
| Market title | Add left accent bar or icon; slight size up to 28pt | 🟡 |
| SectorChip bg tint | Add subtle gain/loss color tint to chip bg based on direction | 🟡 |
| SectorChip layout | Move change% to top right as prominent pill; name below icon | 🟡 |
| MarketRow change% | Wrap in gain/loss colored pill | 🟡 |
| MarketRowSkeleton | Add `.shimmering()` animation (shimmer from left to right) | 🟡 |
| At-a-glance market header | Add mini strip: SPY %, QQQ %, VIX, Fear/Greed index | 🟡 |
| Section label spacing | `.padding(.top, 22)` on first section to match system | 🟢 |
| Trending section | Add sparkline mini-chart (5-day) per row using SwiftUI path | 🟢 |

---

## Screen 3: For You

### What Currently Looks Dated / Wrong

1. **Title "For You ✨"** — emoji in title text is inconsistent with a premium data product. Drop emoji from title.
2. **Alert strip** — uses light amber gradient (`#FFFBEB → #FEF3C7`) with dark amber text. On dark app this becomes a garish yellow blob. Needs full redesign as a dark card with amber accent border-left.
3. **Section labels** — all use emoji prefix in `sectionLabel()`. Mix of emoji + uppercase text is visually noisy. Use SF Symbols icon + section name pattern instead.
4. **Hot on STALK cards** — white horizontal scroll cards. Light bg, light border. Correct concept — small cards in a horizontal scroll — wrong colors.
5. **Missed Opportunities** — left green accent bar `Rectangle().fill(Theme.gain).frame(width: 3)` is the right idea. Keep this pattern. The card bg should be `#111118`, the bar should be `#00D26A`.
6. **World Gainers** — white cards with colored avatar circles. After dark migration the circles will pop. The "Copy →" text is too subtle — should be an accent pill button.
7. **Earnings EarningsCell** — `hasBeat ? Theme.gainBg : Theme.lossBg` — light mode tints must flip to dark tints.
8. **Analyst Moves** — minimal design. No visual signal for upgrade vs downgrade other than text. Should have a colored left border or badge.
9. **Insider Buys** — same structural issue as Analyst Moves. The value `$2.4M` is the hero number but displayed in plain `text` color.
10. **Trump Watch cards** — red left accent bar is the right idea. Layout is OK. Needs dark card background.
11. **PremiumLockedCard** — white overlay at `.opacity(0.96)` — on dark app this is a stark white square. Replace with dark glass: `#16161F` at `.opacity(0.97)`.
12. **PremiumSheet** — dark gradient header already exists (`#1A0B3B → #2D1B69 → #4A2C8F`). The body section `Theme.bg` = white is jarring contrast to the dark header. Must be `#0A0A0F`.

### Specific Improvements

| Element | Change | Priority |
|---|---|---|
| All screen / card backgrounds | Dark migration | 🔴 |
| Alert strip | Dark card with `.5pt` amber left border + amber icon + white text | 🔴 |
| Title text | Remove emoji from "For You ✨" → "For You" | 🟡 |
| Section labels | Remove emoji from sectionLabel() — use text-only for UPPERCASE labels | 🟡 |
| PremiumLockedCard | White overlay → `#16161F` dark glass, border `rgba(255,255,255,0.10)` | 🔴 |
| PremiumSheet body bg | `Theme.bg` → `#0A0A0F` | 🔴 |
| Earnings cell tints | Light gains/loss tints → `gain.opacity(0.12)` / `loss.opacity(0.12)` | 🔴 |
| "Copy →" text | Text link → small accent pill: "Copy" with right arrow icon | 🟡 |
| Analyst Move upgrade/downgrade | Add colored left border (gain = upgrade, loss = downgrade) | 🟡 |
| Insider Buy value | Highlight $ amount in `text1` at 17pt Bold | 🟡 |
| PremiumSheet plan selector | `Theme.bg2` fill → `#141420` | 🔴 |
| CTA button shadow | Current `accent.opacity(0.4), radius: 12` → `accent.opacity(0.45), radius: 18` | 🟡 |

---

## Screen 4: Feed

### What Currently Looks Dated / Wrong

1. **My Profile bar** — accent gradient avatar is good. But the section has no card container — it just floats on the screen bg with a `Divider()` below. Needs more visual structure.
2. **"My Performance" card** — `perfItem()` uses `Theme.bg` as the cell background. On dark this becomes `bg2` (#141420). The numbers are the hero here — make them larger.
3. **Light card backgrounds** — same as all screens.
4. **`Theme.gainBg` / `Theme.lossBg` in perfBadge** — light mode semantic tints must flip.
5. **"Following" section header** — appears after a plain `Divider()`. Weak visual transition. Add spacing.
6. **TraderPostCard** — white card with border. The performance badges use light mode tints. After dark migration the `perfBadge` fill colors (`Theme.gainBg`, `Theme.lossBg`) must be dark.
7. **Ticker tag pills** — `background: Color(hex: "#EDEDFF")` with accent text. On dark this is a light purple blob — jarring. Replace with `accent.opacity(0.15)` bg and `accent` text.
8. **Follow/Following button** — `isFollowed ? Theme.accent : Theme.bg2`. When followed: white text on accent = good. When not followed: accent text on `bg2` (light gray) = works on light, needs `#141420` on dark.
9. **TraderProfileView cover gradient** — uses `trader.color → #EDE9FE`. The `#EDE9FE` is a light lavender. Replace with `trader.color → #0A0A0F` for a dark fade.
10. **TraderProfileView background** — `Theme.bg` = white. Must be `#0A0A0F`.

### Specific Improvements

| Element | Change | Priority |
|---|---|---|
| All card / screen backgrounds | Dark migration | 🔴 |
| Ticker tag bg | `#EDEDFF` → `accent.opacity(0.15)` | 🔴 |
| perfBadge tints | `gainBg` / `lossBg` light → dark tints | 🔴 |
| Profile cover gradient end | `#EDE9FE` → `#0A0A0F` | 🔴 |
| Profile screen bg | `Theme.bg` → `#0A0A0F` | 🔴 |
| My Performance numbers | 22pt Bold → 24pt Black with `.monospacedDigit()` | 🟡 |
| Profile header card | Wrap in `#111118` card with border for containment | 🟡 |
| "Following" section transition | Add 4pt top padding + stronger section header | 🟢 |
| Post actions (Like/Comment/Share) | Upgrade with SF Symbols: heart, bubble, arrowshape.turn.up.right | 🟢 |

---

## Screen 5: Daily Brief

### What Currently Looks Dated / Wrong

1. **The light-mode briefCard variants** — `case .good` uses `#ECFDF5` / `#6EE7B7`, `case .warn` uses `#FFFBEB` / `#FCD34D`, etc. Every single one is a pastel light-mode color. These are unreadable on dark.
2. **Background `Theme.bg`** — white, must be `#0A0A0F`.
3. **PositionBriefCard header bg** — `isUp ? Color(hex: "#ECFDF5") : Color(hex: "#FEF2F2")`. Pastel tints on what should be a dark card. The header row should use `gain.opacity(0.10)` or `loss.opacity(0.10)`.
4. **Divider overlay colors** — `isUp ? Color(hex: "#6EE7B7") : Color(hex: "#FCA5A5")` — light green/red dividers. Should be `gain.opacity(0.30)` / `loss.opacity(0.30)`.
5. **The section label emoji** — "📊 Your Portfolio", "🌍 What Moved the Market" — same issue as ForYou. Remove emoji from section headers.
6. **"📋 Daily Brief" title emoji** — the emoji here is ACCEPTABLE as it's in the hero gradient where color variety works. Keep this one.
7. **briefCard body copy** — hardcoded macro commentary (Fed rates, CPI, etc) that never updates. This is fine for MVP but visually needs to feel "fresh" — a shimmer/loading state and a timestamp.
8. **nextTradingDayBanner** — a `briefCard` with `.alert` type. On dark the blue alert tint (`#EFF6FF`) is the worst offender — nearly white on a dark bg.

### Specific Improvements

| Element | Change | Priority |
|---|---|---|
| All screen backgrounds | → `#0A0A0F` | 🔴 |
| `briefCard` .good bg/border | `#ECFDF5` → `gain.opacity(0.10)`, border `gain.opacity(0.25)` | 🔴 |
| `briefCard` .warn bg/border | `#FFFBEB` → `gold.opacity(0.10)`, border `gold.opacity(0.25)` | 🔴 |
| `briefCard` .danger bg/border | `#FEF2F2` → `loss.opacity(0.10)`, border `loss.opacity(0.25)` | 🔴 |
| `briefCard` .alert bg/border | `#EFF6FF` → `accent.opacity(0.10)`, border `accent.opacity(0.25)` | 🔴 |
| `briefCard` .neutral bg/border | `Theme.card` + `Theme.border` → `#111118` + `rgba(255,255,255,0.06)` | 🔴 |
| `briefCard` text colors | `Theme.text` / `Theme.text2` → `text1` / `text2` (after dark migration) | 🔴 |
| PositionBriefCard header bg | Pastel tints → `gain.opacity(0.10)` / `loss.opacity(0.10)` | 🔴 |
| PositionBriefCard dividers | Pastel tints → `gain.opacity(0.25)` / `loss.opacity(0.25)` | 🔴 |
| Section label emoji | Remove from section headers, keep in hero title only | 🟡 |
| Card timestamp | Add "Updated 5m ago" in `text4` | 🟢 |
| Loading shimmer | Add shimmer to briefCards while data is stale | 🟢 |

---

## Screen 6: Settings (Not yet read — based on pattern)

Settings screens are typically the most neglected. Based on the design system:

| Issue | Fix | Priority |
|---|---|---|
| Background color | Dark migration | 🔴 |
| List row separators | Default iOS separators → custom `rgba(255,255,255,0.06)` Divider | 🔴 |
| Section headers | Match the caption style (10pt uppercase) | 🟡 |
| Toggle / switch tint | System tint → `#5B5BD6` accent | 🟡 |
| Danger actions (delete, sign out) | Ensure `#FF4757` loss color | 🟡 |
| Navigation bar | Use `.toolbarBackground(.hidden)` with custom header | 🟢 |

---

## Screen 7: Onboarding (If it exists / future)

| Issue | Fix | Priority |
|---|---|---|
| First-impression background | Must be `#0A0A0F` from frame 1 | 🔴 |
| Progress indicator | Custom pill progress bar using accent gradient | 🟡 |
| CTA buttons | Full-width, accent gradient, 56pt height, 18pt radius | 🔴 |
| Value proposition headline | 44pt Black, `text1`, centered | 🟡 |
| Feature preview cards | Dark cards with neon accent glows showing app UI | 🟡 |
| Skip / Later text | `text3`, 13pt, centered | 🟢 |

---

## Cross-Screen Systemic Fixes (Apply Everywhere)

| Issue | Fix | Priority |
|---|---|---|
| All emoji in section headers | Remove — use text labels only or SF Symbols | 🟡 |
| All `Theme.gainBg` / `Theme.lossBg` | Replace with `gain.opacity(0.12)` / `loss.opacity(0.12)` | 🔴 |
| All `Theme.border` (#EBEBF0) | Replace with `Color.white.opacity(0.06)` | 🔴 |
| All `Theme.bg` (#F7F8FC) | Replace with `Color(hex: "#0A0A0F")` | 🔴 |
| All `Theme.bg2` (#EEEEF5) | Replace with `Color(hex: "#141420")` | 🔴 |
| All `Theme.card` (white) | Replace with `Color(hex: "#111118")` | 🔴 |
| All `Theme.text` (#18181B) | Replace with `Color(hex: "#F2F2F7")` | 🔴 |
| All `Theme.text2` (#52525B) | Replace with `Color(hex: "#A8A8B8")` | 🔴 |
| All `Theme.text3` (#A1A1AA) | Replace with `Color(hex: "#5C5C72")` | 🔴 |
| All `Color(hex: "#EDEDFF")` ticker tags | Replace with `Theme.accent.opacity(0.15)` | 🔴 |
| Card shadows | All < `.opacity(0.10)` are invisible on dark | 🔴 |
| Tab bar background | System default → `#0A0A0F` + top border `rgba(255,255,255,0.08)` | 🔴 |
