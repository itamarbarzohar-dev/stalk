**Maya (CTO) — Data Provider & Architecture Lock**

**Immediate action (today):**
1. **Earnings Calendar data source decision** — CRITICAL PATH. Compare:
   - IEX Cloud (reliable, $9-99/mo, US market focus)
   - Alpha Vantage (free tier + paid, broader coverage)
   - Finnhub (real-time, $9-99/mo, quality)
   - Recommend one. Jordan can't code without this locked.

2. **Backend decision for v1** — Firebase (quick) vs Supabase (control) vs minimal API? We need auth + user portfolios by launch. Propose architecture for live feed persistence.

3. **Real-time price update strategy** — WebSocket vs polling? What data provider feeds the live ticker updates (currently mock)?

**Flag any blockers** on data costs, API rate limits, or infrastructure that blocks launch. Report by EOD.

**Success:** One-page decision doc + recommended provider stack.
