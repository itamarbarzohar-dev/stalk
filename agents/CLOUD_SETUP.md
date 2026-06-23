# STALK Cloud Agent Network — Setup Guide

## What this does
7 AI agents run automatically in GitHub Actions, 24/7, no machine needed:
- **Alex (CEO)** — sets daily agenda, writes tasks for all agents
- **Maya (CTO)** — reviews architecture, writes ADRs
- **Jordan (iOS Dev)** — audits Swift code, flags bugs as GitHub issues
- **Luna (UX)** — design consistency audit
- **Sam (CPO)** — prioritizes feature backlog
- **Rex (CRO)** — revenue analysis
- **Dana (Reporter)** — writes daily report (agents/reports/daily_YYYY-MM-DD.md)

**Schedule:** Weekdays 10am Israel time (8am UTC), auto-triggered on PRs.

---

## One-time setup (5 minutes)

### Step 1 — Get your Anthropic API key
1. Go to https://console.anthropic.com
2. Click **API Keys** → **Create Key**
3. Copy the key (starts with `sk-ant-...`)
4. Add $5 credits (lasts ~3 months for all agents)

### Step 2 — Add key to GitHub
1. Go to https://github.com/itamarbarzohar-dev/stalk/settings/secrets/actions
2. Click **New repository secret**
3. Name: `ANTHROPIC_API_KEY`
4. Value: paste your `sk-ant-...` key
5. Click **Add secret**

### Step 3 — Enable Actions
1. Go to https://github.com/itamarbarzohar-dev/stalk/actions
2. If prompted, click **Enable GitHub Actions**

### Step 4 — Test it
1. Go to Actions → **STALK Agent Network — Daily Run**
2. Click **Run workflow** → choose agent: `reporter`
3. Watch Dana write today's report in ~2 minutes

---

## How to read agent output
- Daily reports: `agents/reports/daily_YYYY-MM-DD.md`
- CEO log: `agents/memory/ceo_log.md`
- iOS dev log: `agents/memory/ios_dev_log.md`
- GitHub Issues: agents create issues automatically for bugs/improvements

## Cost
~$0.40/month for all 7 agents running daily on Claude Haiku.
