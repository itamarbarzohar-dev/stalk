# Task: Full UX Audit — Futuristic Design System for STALK
**Assigned to:** Luna (UX Designer)
**Priority:** HIGH
**Due:** 2026-06-09
**From:** CEO Alex
**Status:** OPEN

## Context

STALK is a native SwiftUI iOS app. It currently uses a dark theme (`#0D0D0F` background, indigo/violet accent `#5B5BD6`, monospaced fonts for numbers). The app has: Portfolio tab, Market tab, Social Feed tab, For You tab (with Daily Brief, FOMO cards, AI card), and Settings. The app is pre-launch, so design changes can be made without backwards compatibility constraints.

The goal: STALK should feel like it was designed in 2027. Not Bloomberg (institutional/cold). Not Robinhood (gamified/cheap). Something closer to **Arc Browser meets a trading terminal** — opinionated, premium, alive. Think: subtle animations, glassy layers, data that breathes.

## What I need

### Part 1: Screen-by-Screen Audit

For each screen listed below, provide:
- **Current state** (1–2 sentences describing what it likely looks like based on the codebase)
- **What's broken** (specific UX problems: hierarchy, spacing, color, contrast, animation, information density)
- **Exact fixes** (hex colors, pt sizes, corner radii, animation curves — no vague "make it more modern")

Screens to audit:

**1. Portfolio Tab (PortfolioView)**
- Hero number: total portfolio value. Is it readable at a glance? Font weight, size?
- Position list: ticker, company name, shares, current price, gain/loss %. Spacing issues?
- Colors: gain = green, loss = red. Are these the right greens/reds, or do they look garish?
- Swipe actions on position rows — do they exist? Should they?
- Empty state (no positions added yet) — is there one?

**2. Market Tab (MarketView)**
- Index cards (S&P 500, NASDAQ, etc.) — layout and data density
- Sector heat map — does one exist? Should there be one?
- "Trending" section — how is it visually differentiated from indexes?
- Information hierarchy: what does the user's eye hit first?

**3. Social Feed Tab**
- Feed card design: avatar, username, ticker tag, text, like/comment actions
- Is there visual differentiation between different post types (price alert posts vs. opinion posts)?
- Empty state for cold-start (no follows, no posts)

**4. For You Tab**
- Daily Brief card: typography hierarchy for the AI-generated brief text
- FOMO cards: urgency visual language — does it feel urgent without feeling spammy?
- AI Agent card: the "Ask me anything" input — does it invite interaction?
- Card stack layout: spacing, shadow/elevation, corner radii

**5. Onboarding Flow (4 screens)**
- Screen 1 (name/username): input field styling
- Screen 2 (add first stock): chip layout for trending tickers
- Screen 3 (portfolio preview): animated counter — is the animation actually good?
- Screen 4 (notifications ask): trust framing, button hierarchy

**6. Paywall / PremiumSheet**
- Does it feel like a $50/yr product or a $1.99/yr product?
- Feature list presentation: icons, spacing, copy
- Plan selector: annual vs. monthly — visual hierarchy
- CTA button: size, color, copy, micro-animation on tap

**7. Settings**
- Theme picker: circle swatches — size, selected state indicator
- Section headers: are they visually distinct from row content?
- Destructive actions (delete data): are they appropriately scary?

**8. Price Alert UI (not yet built — design spec needed)**
- This is NEW. Jordan will implement it. You're designing it from scratch.
- User story: I tap a stock in my portfolio → I want to set "alert me if AAPL goes above $200 or below $180"
- Design the modal/sheet: input fields, current price context, toggle for above/below, confirmation
- Exact specs: field height, font, border color (inactive vs. focused), button placement

### Part 2: Design System Spec

Write the complete STALK design system in one document. Every value must be exact — no "approximately" or "something like."

**Colors**
- Background layers: bg0 (deepest), bg1, bg2, bg3 (surface cards) — current hex values and proposed changes
- Accent: current `#5B5BD6` — keep or evolve? If evolve, propose exact new value with rationale
- Gain: current green — exact hex, and whether it should have a glow effect
- Loss: current red — exact hex
- Text hierarchy: text1 (primary), text2 (secondary), text3 (tertiary) — exact hex values for each
- Destructive: exact hex

**Typography**
- App uses SF Pro and SF Mono (for numbers) — confirm this is correct
- Define: display size (hero numbers), title1, title2, body, caption, label
- For each: font name, weight, size (pt), line height, letter spacing
- Special case: portfolio value hero number — exact spec (size, weight, kerning)

**Spacing**
- Base unit (4pt or 8pt system?)
- Card padding: inner padding, outer margin
- Section spacing
- List row height and vertical padding

**Border Radius**
- Cards: exact value
- Buttons: exact value
- Input fields: exact value
- Chips/tags: exact value

**Shadows & Elevation**
- Card shadow: color (rgba), blur, offset
- Modal shadow
- Should cards use glassmorphism (blur + translucency)? If yes: exact `UIBlurEffect` style and opacity

**Motion**
- Default spring animation: response, dampingFraction
- Transition for tab switching
- Number counter animation: duration, curve
- Card tap feedback: scale transform value, duration
- Skeleton loading: should it exist? Color and animation?

**Iconography**
- SF Symbols vs. custom icons: which areas need custom?
- Icon weight used throughout (regular, medium, semibold?)
- Icon size for tab bar, list rows, action buttons

### Part 3: Three "Signature Moments"

Define three micro-interactions that make STALK feel magical — the kind of thing that makes users say "wait, how did they do that?" For each:
- Name it
- Describe the trigger and response in precise terms
- Specify the animation values (duration, curve, transform)
- Explain why it earns its complexity (i.e., it communicates something meaningful, not just decoration)

## Why it matters

STALK is competing against apps with design teams of 20+. The only way to win is to be more intentional, not more staffed. Every pixel has to be deliberate. A mediocre-looking app with good features will lose to a beautiful app with good features. Luna's job is to make sure STALK looks like it was made by someone who cares obsessively about craft.

## Definition of Done

- All 8 screens audited with specific fixes (not vague suggestions)
- Price Alert UI fully specced (Jordan can build from Luna's spec without asking questions)
- Design system doc written with exact values for every token listed above
- Three signature moments defined with full animation specs
- All output written to `agents/memory/design/ux_audit_2026-06-09.md`
- Status updated in this task file when complete
- **No vague language.** "Make it more premium" is not a deliverable. "#1A1A2E at 0.85 opacity with 24pt blur" is.
