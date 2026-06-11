# Social Feed Design Spec
**Author:** Luna (UX Designer)
**Date:** 2026-06-11
**Status:** Spec — ready for implementation

---

## Vision

The STALK social feed is a premium finance version of Instagram. Dark, opinionated, obsessively crafted. Every pixel earns its place. The goal is scroll-stopping momentum — the kind of feed you open without knowing why, and close 20 minutes later.

The emotional bar: Robinhood's confidence + Instagram's intimacy + TikTok's pull.

---

## Stories Row

### Container
- Background: `#0A0A0F` — the same as the app base. No card, no separator, no elevation. Stories float directly on the void.
- Horizontal padding: 16pt each side
- Vertical padding: 12pt top, 8pt bottom
- Row height: 96pt total
- Avatar size: 60pt diameter
- No clip border on the container — the ring IS the border

### Ring System
- Ring stroke width: **3pt**
- Gap between ring and avatar edge: **2pt** (achieved via padding inset, not offset)
- Ring sits outside the avatar frame, not clipping it

**Gain ring:**
```
Color: #00D26A → #00FF87 gradient, clockwise
Fill: proportional to day's gain percentage
  - 0% gain = ring starts empty (stroke from top, 12 o'clock)
  - +5% gain = ring half filled
  - +10%+ = ring fully filled, gradient pulses opacity 0.85 → 1.0
```

**Loss ring:**
```
Color: #FF4757 solid (no gradient — loss should feel blunt, not beautiful)
Fill: proportional to day's loss, clockwise
  - Opacity: 0.9 at any loss — slightly dimmer than gain to reinforce negative affect
```

**ATH ring (All-Time High):**
```
Gradient: #F5A623 → #FFD700 → #F5A623, clockwise
Full ring — always fully stroked when at ATH
Animation: pulse scale 1.0 → 1.04 → 1.0, duration 1.4s, ease-in-out, repeat forever
Additional: subtle golden particle shimmer overlay using .screen blend mode
```

**Neutral / flat day:**
```
Color: #2A2A3A — dim ring to indicate presence, not performance
No animation
```

**Unviewed indicator:**
- When a story is unviewed: full ring at full opacity
- When viewed: ring drops to 30% opacity, no animation

### Avatar Treatment
- Shape: circle, 60pt
- Font for initials fallback: SF Pro Rounded, 20pt, Medium
- Initials background: gradient derived from username hash (consistent per user)

### Label
- Username below avatar, centered
- Font: SF Pro, 11pt, Regular
- Color: `#8E8EA0`
- Max width: 68pt, truncate with ellipsis
- Verified badge: 10pt SF Symbol `checkmark.seal.fill`, cyan `#06B6D4`, trailing the name

### Appear Animation
- Entry: spring pop — scale 0.6 → 1.0, opacity 0 → 1
- Stagger: 60ms delay per story from left to right
- Spring params: `response: 0.4, dampingFraction: 0.65`
- Do NOT animate on re-renders — only on first appear (use `.onAppear` once flag)

### "Add Story" Button (self)
- Position: always index 0
- Ring: dashed `#2A2A3A` 1pt stroke (signals "empty")
- Center: `+` icon, `#5B5BD6` indigo, 22pt, SF Symbol `plus.circle.fill`
- Label: "Your story"

---

## Post Card Design

### Card Container
- Width: full screen width minus 16pt each side (device width - 32pt)
- Corner radius: **20pt**
- Background: `#111118`
- Shadow: `color: .black.opacity(0.5), radius: 12, x: 0, y: 4`
- Vertical spacing between cards: 12pt
- Clip shape: RoundedRectangle(cornerRadius: 20)

### Card Header
- Height: 56pt
- Horizontal padding: 16pt

**Avatar:**
- Size: 40pt circle
- Trailing margin to text: 10pt

**User info (VStack, leading aligned):**
- Line 1: Display name — SF Pro, 14pt, Semibold, `#F5F5F7`
- Line 2: "2h ago" — SF Pro, 12pt, Regular, `#8E8EA0`

**Ticker badge (trailing):**
- Pill shape: 6pt corner radius
- Background: ticker-specific accent (default `#1C1C28`)
- Text: ticker symbol — SF Pro Mono, 12pt, Semibold
- Color: green if today's return positive, red if negative, gray if flat
- Padding: 6pt horizontal, 4pt vertical

**Optional header image (parallax):**
- When a post includes a stock chart screenshot or image, it appears as a 120pt tall banner behind the header row
- Image is blurred (`blur(radius: 20)`) and overlaid with `#000000.opacity(0.6)` — text remains legible
- On scroll: image offset by `scrollOffset * 0.3` — subtle parallax (positive toward top)
- This is a "nice to have" — only for posts that opt in to share a chart

### Post Body
- Horizontal padding: 16pt
- Top margin from header: 4pt
- Font: SF Pro, **14pt**, Regular
- Line spacing: **1.5x** (set via `.lineSpacing(7)` — SF Pro 14pt = 19pt line height × 0.5 = ~7pt extra spacing)
- Color: `Theme.text` (mapped to `#F5F5F7` in dark mode)
- Max lines: 4, "more" expansion tap
- "More" link: `#5B5BD6` indigo, same 14pt

### Performance Bar
- Position: below body text, 12pt top margin
- Height: 4pt, full card width minus 32pt horizontal padding
- Corner radius: 2pt (fully rounded ends)
- Background track: `#1C1C28`
- Fill:
  - Positive: `#00D26A`
  - Negative: `#FF4757`
  - Fill width = `abs(returnPercent) / maxReturn * totalWidth`, capped at 100%
- Return label: right-aligned above the bar, SF Pro Mono, 13pt, Semibold
  - Green/red matching bar color
  - Format: `+2.4%` or `-1.8%`
- Bar appears with a width animation from 0: `withAnimation(.spring(response: 0.5, dampingFraction: 0.75))`

### Reaction Bar
- Position: bottom of card, 12pt below performance bar, 16pt bottom margin
- Layout: HStack, spacing 8pt

**Reaction pill button:**
- Background (default): `#1C1C28`
- Background (selected): `#5B5BD6.opacity(0.25)` with `#5B5BD6` border 1pt
- Corner radius: 20pt (fully rounded)
- Padding: 8pt horizontal, 6pt vertical
- Content: emoji + count number
- Emoji size: 16pt
- Count: SF Pro, 13pt, Medium, `#8E8EA0` default, `#5B5BD6` when selected

**Reactions (in order):**
1. 🔥 Fire — "hot take"
2. 📈 Chart up — "bullish"
3. 💎 Diamond — "diamond hands"
4. 😱 Shocked — "big news"

**Interaction:**
- Tap selected reaction: deselect, decrement count
- Tap new reaction: select, previous deselects
- Tap animation: spring scale 1.0 → 1.3 → 1.0, `response: 0.25, dampingFraction: 0.5`

**More options:**
- Trailing: SF Symbol `ellipsis` — `#8E8EA0`, 16pt. Opens context menu: Share, Copy, Report, Mute

---

## Leaderboard

### Container
- Background: `#0A0A0F`
- No card — rows float on the background
- Header: "Leaderboard" — SF Pro, 22pt, Bold, `#F5F5F7`
- Period picker: segmented control, periods: 1D / 1W / 1M / YTD / All

### Podium Treatment (Top 3)

**Rank #1:**
- Avatar size: 52pt (vs 40pt standard — larger to signal dominance)
- Ring/border: 2pt stroke, gradient `#F5A623 → #FFD700`, always full ring (not performance-based)
- Name: SF Pro, 15pt, Bold
- Subtle crown icon: SF Symbol `crown.fill`, 10pt, `#F5A623`, above avatar
- Row background: `#1A1608` — very subtle warm tint, barely perceptible

**Rank #2:**
- Avatar: 44pt
- Border: 2pt `#C0C0C0` (silver)
- Standard name weight

**Rank #3:**
- Avatar: 40pt (standard)
- Border: 2pt `#CD7F32` (bronze)

**Rank 4+:** no special treatment

### Row Layout
- Height: **56pt**
- Horizontal padding: 16pt

**Left to right:**
1. Rank number — SF Pro Mono, 14pt, Bold, `#8E8EA0`, fixed 24pt width
2. Avatar circle — 40pt (or podium size)
3. VStack: display name (14pt Semibold, `#F5F5F7`) + username (12pt Regular, `#8E8EA0`)
4. Spacer
5. Return value — SF Pro, **15pt**, Black weight, tabular figures (`.monospacedDigit()`), right-aligned
   - Color: `#00D26A` positive, `#FF4757` negative

### Row Backgrounds
- Odd rows (1, 3, 5...): `#111118`
- Even rows (2, 4, 6...): `#0F0F17`
- Difference is intentionally subtle — just enough for the eye to track rows without visual noise

### My Rank Sticky Row
- When user is not in top 10, show their rank pinned to the bottom
- Separator: 1pt `#2A2A3A` above it
- Background: `#1C1C28` — slightly more visible than list rows
- Label: "Your rank" prepended in `#8E8EA0`

---

## Achievement Badges

### Badge Anatomy
- Size: 64pt × 64pt tappable area, 48pt visual icon
- Shape: squircle (continuous corner radius ~14pt)
- Grid: 3 columns in achievement shelf

### Locked State
- Icon: grayscale (`.grayscale(1.0)`)
- Opacity: **50%** (`.opacity(0.5)`)
- Lock overlay: SF Symbol `lock.fill`, 14pt, `#8E8EA0`, centered bottom-right of icon
- Background: `#111118` — no gradient
- Name label: `#8E8EA0`, 11pt

### Unlocked State
- Icon: full color
- Opacity: 1.0
- Background: subtle gradient matching badge accent color, 15% opacity
- Shine overlay: white highlight, 30% opacity, angled 45°, positioned top-left quadrant
- Name label: `#F5F5F7`, 11pt

### Recent Unlock Animation (< 24h since earned)
- Trigger: badge was earned within the last 24 hours
- Gold shimmer: animated gradient sweep, `#F5A623 → #FFD700 → transparent`, moves left to right
- Duration: 2.0s, delay 0.5s after appear, plays once
- Blend mode: `.screen` — overlays without hiding the badge art
- Scale pulse: 1.0 → 1.05 → 1.0 simultaneously, `response: 0.5`
- After animation completes: badge settles to standard unlocked state

### Badge Categories (for visual grouping)
- Portfolio badges: blue accent `#5B5BD6`
- Streak badges: orange `#F97316`
- Social badges: cyan `#06B6D4`
- Milestone badges: gold `#F5A623`

---

## Motion Principles

1. **Spring over ease**: all interactive animations use spring physics, not easing curves
2. **Never block**: animations run concurrently with data loads — skeleton states cover latency
3. **Stagger, don't flood**: list items appear in sequence with 40-60ms stagger
4. **Subtle depth**: shadows and parallax are present but subthreshold — felt not seen
5. **Reaction feedback must be instant**: < 16ms to first frame, server sync happens silently after

---

## Dark Mode Only

All specs above are dark mode. STALK does not offer a light mode for social features — the dark aesthetic is a brand signal. Light mode support, if ever added, should be a deliberate product decision, not a default.
