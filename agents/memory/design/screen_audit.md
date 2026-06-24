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


## 2026-06-24
**Files reviewed:** None changed (no UI files committed since last sprint)

**Design issues:** 
- Dark mode systemic fixes (Theme color constants) remain pending across all screens — blocking visual polish for App Store screenshots
- Data viz charts (Sector Heat Map, Portfolio Health Score, Earnings Calendar) — nano banana (#D4F03C) **MUST** be restricted to chart visualization only, never applied to UI chrome/buttons/borders
- Onboarding flow background and CTA buttons not yet styled per dark design system
- Card shadows insufficient for dark backgrounds — need opacity ≥ 0.15 for visibility

**Nano banana status:** Not yet in use (new features in progress — Jordan building Sector Heat Map, Health Score, Earnings Calendar). Will require strict governance: **#D4F03C accent ONLY in data viz legends, chart overlays, and numeric highlights. Zero usage in tab bars, buttons, section headers, or interactive chrome.**

**Recommendations for next sprint:**
1. **Finish App Store assets TODAY** — 5 feature screenshots (Heat Map, Health Score, Earnings, Trending, AI Context) + final app icon approval. This unblocks Itamar's submission review.
2. **Apply systemic dark theme to all active screens** — batch convert Theme constants across portfolio hero, tab bar, card system. Priority: before any public screenshots.
3. **Nano banana governance doc** — create `design_system/nano_banana_rules.md` with strict rules for #D4F03C usage before Jordan ships chart features (prevent misuse across social feed, headers, etc.).
