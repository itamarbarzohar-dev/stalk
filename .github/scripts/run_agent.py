#!/usr/bin/env python3
"""Single entry point for all STALK agents. Usage: python3 run_agent.py <agent_name>"""

import sys
import os
import re
import subprocess
from pathlib import Path
import anthropic

AGENT = sys.argv[1] if len(sys.argv) > 1 else "reporter"
TODAY = os.environ.get("TODAY", "unknown")
API_KEY = os.environ["ANTHROPIC_API_KEY"]

client = anthropic.Anthropic(api_key=API_KEY)


def read_file(path, lines=None):
    try:
        content = Path(path).read_text()
        if lines:
            content = "\n".join(content.split("\n")[-lines:])
        return content
    except Exception:
        return f"[Not found: {path}]"


def git(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""


def call_claude(prompt, max_tokens=2500):
    msg = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=max_tokens,
        messages=[{"role": "user", "content": prompt}]
    )
    return msg.content[0].text


def write_outputs(output):
    pattern = r"=== FILE: (.+?) ===\n(.*?)\n=== END ==="
    matches = re.findall(pattern, output, re.DOTALL)
    for filepath, content in matches:
        filepath = filepath.strip()
        content = content.strip()
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        Path(filepath).write_text(content + "\n")
        print(f"Wrote: {filepath}")
    if not matches:
        print("No FILE blocks found in output — check prompt format")
    return len(matches)


def tasks_for(role_keywords):
    tasks_dir = Path("agents/tasks")
    results = []
    if tasks_dir.exists():
        for f in sorted(tasks_dir.iterdir()):
            if f.is_file() and "_DONE" not in f.name:
                if any(k.upper() in f.name.upper() for k in role_keywords):
                    results.append(f"--- {f.name} ---\n" + f.read_text()[:400])
    return "\n".join(results) if results else "No tasks assigned today."


# ─────────────────────────── CEO — Alex ────────────────────────────────────
def run_ceo():
    company_state = read_file("agents/COMPANY_STATE.md")
    ceo_log = read_file("agents/memory/ceo_log.md", lines=40)
    git_log = git("git log --oneline -15")

    tasks_dir = Path("agents/tasks")
    open_tasks = []
    if tasks_dir.exists():
        for f in sorted(tasks_dir.iterdir()):
            if f.is_file() and "_DONE" not in f.name:
                open_tasks.append(f"- {f.name}: " + f.read_text()[:200])
    tasks_str = "\n".join(open_tasks) if open_tasks else "No open tasks."

    prompt = f"""Today is {TODAY}. You are Alex, CEO of STALK — an iOS stock portfolio social app in SwiftUI.

COMPANY STATE:
{company_state}

CEO LOG (recent):
{ceo_log}

OPEN TASKS:
{tasks_str}

GIT LOG (last 15):
{git_log}

Your job today:
1. Review company state and sprint progress
2. Write task files for each agent (CTO/Maya, iOS Dev/Jordan, UX/Luna, CPO/Sam, CRO/Rex, Reporter/Dana)
3. Update CEO log with today's priorities

Output ONLY using this exact format — nothing outside the markers:

=== FILE: agents/tasks/CEO_CTO_TASK_{TODAY}.md ===
[Maya's task — architecture focus, specific and actionable, under 120 words]
=== END ===

=== FILE: agents/tasks/CEO_IOS_TASK_{TODAY}.md ===
[Jordan's task — specific Swift/SwiftUI work to review or flag, under 120 words]
=== END ===

=== FILE: agents/tasks/CEO_UX_TASK_{TODAY}.md ===
[Luna's task — design audit focus, under 120 words]
=== END ===

=== FILE: agents/tasks/CEO_CPO_TASK_{TODAY}.md ===
[Sam's task — product prioritization focus, under 120 words]
=== END ===

=== FILE: agents/tasks/CEO_CRO_TASK_{TODAY}.md ===
[Rex's task — revenue/monetization focus, under 120 words]
=== END ===

=== FILE: agents/tasks/CEO_REPORTER_TASK_{TODAY}.md ===
[Dana's task — what to cover in daily report, under 60 words]
=== END ===

=== FILE: agents/memory/ceo_log.md ===
{ceo_log}

## {TODAY}
[3-5 bullet points: priorities, decisions, blockers. Focus on App Store launch readiness.]
=== END ==="""

    output = call_claude(prompt, max_tokens=3500)
    print("=== CEO OUTPUT ===\n", output)
    write_outputs(output)


# ─────────────────────────── CTO — Maya ────────────────────────────────────
def run_cto():
    company_state = read_file("agents/COMPANY_STATE.md")
    cto_log = read_file("agents/memory/cto_decisions.md", lines=30)
    git_log = git("git log --oneline -10")
    changed_swift = git("git diff HEAD~5 --name-only 2>/dev/null | grep '\\.swift$' | head -10")
    my_tasks = tasks_for(["CTO", "MAYA"])

    prompt = f"""Today is {TODAY}. You are Maya, CTO of STALK.

Tech stack: Swift 6, SwiftUI, iOS 26.5, @Observable (never ObservableObject), SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor.

COMPANY STATE:
{company_state}

CTO LOG (recent):
{cto_log}

MY TASKS:
{my_tasks}

GIT LOG:
{git_log}

CHANGED SWIFT FILES (last 5 commits):
{changed_swift}

Your job:
1. Review architecture decisions needed
2. Flag any Swift anti-patterns or technical debt from recent changes
3. Update CTO decisions log

=== FILE: agents/memory/cto_decisions.md ===
{cto_log}

## {TODAY}
[Architecture notes — 3-5 bullet points. Specific file references where relevant. Flag @Observable violations, actor isolation issues, or any patterns that will break at scale.]
=== END ==="""

    output = call_claude(prompt, max_tokens=2000)
    print("=== CTO OUTPUT ===\n", output)
    write_outputs(output)


# ─────────────────────────── iOS Dev — Jordan ──────────────────────────────
def run_ios_dev():
    company_state = read_file("agents/COMPANY_STATE.md")
    ios_log = read_file("agents/memory/ios_dev_log.md", lines=30)
    git_log = git("git log --oneline -10")
    changed_files = git("git diff HEAD~3 --name-only 2>/dev/null | grep '\\.swift$' | head -5")
    my_tasks = tasks_for(["IOS", "JORDAN"])

    snippets = ""
    if changed_files:
        for f in changed_files.splitlines():
            if Path(f).exists():
                lines = Path(f).read_text().splitlines()[:60]
                snippets += f"\n\n--- {f} (first 60 lines) ---\n" + "\n".join(lines)

    prompt = f"""Today is {TODAY}. You are Jordan, iOS Developer at STALK.

Rules: Swift 6, @Observable only (never ObservableObject), MainActor isolation. Nano banana (#D4F03C) ONLY on data viz.

COMPANY STATE:
{company_state}

IOS DEV LOG (recent):
{ios_log}

MY TASKS:
{my_tasks}

GIT LOG:
{git_log}

CHANGED SWIFT FILES:
{snippets if snippets else changed_files if changed_files else 'No Swift changes in last 3 commits'}

Your job:
1. Review recent Swift changes for bugs and anti-patterns
2. Log findings with specific file references
3. Flag anything that needs Itamar's review
4. NEVER suggest pushing code directly — recommendations only

=== FILE: agents/memory/ios_dev_log.md ===
{ios_log}

## {TODAY}
**Files reviewed:** [list]
**Bugs/issues found:** [specific, with file:line if possible]
**Recommendations:** [actionable]
**For Itamar review:** [anything requiring founder decision]
=== END ==="""

    output = call_claude(prompt, max_tokens=2000)
    print("=== iOS Dev OUTPUT ===\n", output)
    write_outputs(output)


# ─────────────────────────── UX — Luna ────────────────────────────────────
def run_ux():
    company_state = read_file("agents/COMPANY_STATE.md")
    screen_audit = read_file("agents/memory/design/screen_audit.md", lines=40)
    my_tasks = tasks_for(["UX", "LUNA"])
    changed_files = git("git diff HEAD~3 --name-only 2>/dev/null | grep '\\.swift$' | head -5")

    snippets = ""
    if changed_files:
        for f in changed_files.splitlines():
            if Path(f).exists():
                lines = Path(f).read_text().splitlines()[:50]
                snippets += f"\n\n--- {f} ---\n" + "\n".join(lines)

    prompt = f"""Today is {TODAY}. You are Luna, UX Lead at STALK.

Design rules:
- Nano banana (#D4F03C) = ONLY on data viz (charts, P&L numbers), NEVER on UI chrome
- Theme.bg / Theme.card / Theme.border for all containers
- Premium dark-mode aesthetic, SF Symbols with gradient fills
- Spring animations on interactions

SCREEN AUDIT (recent):
{screen_audit}

MY TASKS:
{my_tasks}

CHANGED SWIFT UI FILES:
{snippets if snippets else 'No UI changes in last 3 commits'}

=== FILE: agents/memory/design/screen_audit.md ===
{screen_audit}

## {TODAY}
**Files reviewed:** [list]
**Design issues:** [specific — wrong color, missing shadow, layout problem + file reference]
**Nano banana status:** [correct usage / misuse found where]
**Sprint recommendations:** [top 2-3 UX improvements for this sprint]
=== END ==="""

    output = call_claude(prompt, max_tokens=1500)
    print("=== UX OUTPUT ===\n", output)
    write_outputs(output)


# ─────────────────────────── CPO — Sam ────────────────────────────────────
def run_cpo():
    company_state = read_file("agents/COMPANY_STATE.md")
    backlog = read_file("agents/memory/product/feature_backlog.md")
    my_tasks = tasks_for(["CPO", "SAM"])

    prompt = f"""Today is {TODAY}. You are Sam, CPO of STALK — iOS stock portfolio social app for retail investors.

Competitors: Robinhood (portfolio), eToro (copy trading, social), Stocktwits (community), Perplexity Finance (AI context).
Goal: beat them all in one app. Target: Israeli retail investor expanding globally.

COMPANY STATE:
{company_state}

FEATURE BACKLOG:
{backlog}

MY TASKS:
{my_tasks}

Your job:
1. Re-prioritize the backlog for fastest path to App Store launch
2. Identify the 1 feature that will drive the most downloads/retention this week
3. Flag any product gaps vs. competitors

=== FILE: agents/memory/product/feature_backlog.md ===
# STALK Feature Backlog — {TODAY}
> CPO: Sam | Agent-updated

## HIGH — Launch Blockers
[items that MUST be done before App Store]

## MEDIUM — Launch Enhancers
[items that make the app significantly better at launch]

## LOW — Post-Launch
[nice to have, build after first users]

## {TODAY} CPO Notes
[3-5 bullets: key decision, top feature of the week, competitor gap to close]
=== END ==="""

    output = call_claude(prompt, max_tokens=2000)
    print("=== CPO OUTPUT ===\n", output)
    write_outputs(output)


# ─────────────────────────── CRO — Rex ────────────────────────────────────
def run_cro():
    company_state = read_file("agents/COMPANY_STATE.md")
    revenue_analysis = read_file("agents/memory/revenue/business_model_analysis.md", lines=50)
    my_tasks = tasks_for(["CRO", "REX"])

    prompt = f"""Today is {TODAY}. You are Rex, CRO of STALK.

Revenue model: Freemium subscription ($4.99/mo or $29.99/yr) + broker affiliate partnerships.
Paywall gate: AI features, options flow, copy trading above $500.

COMPANY STATE:
{company_state}

REVENUE ANALYSIS (recent):
{revenue_analysis}

MY TASKS:
{my_tasks}

=== FILE: agents/memory/revenue/business_model_analysis.md ===
{revenue_analysis}

## {TODAY} Revenue Update
**Top lever this week:** [specific, actionable]
**Paywall timing recommendation:** [when to show paywall in the user journey]
**Broker affiliate next step:** [one specific action]
**Conversion funnel insight:** [one key observation]
=== END ==="""

    output = call_claude(prompt, max_tokens=1500)
    print("=== CRO OUTPUT ===\n", output)
    write_outputs(output)


# ─────────────────────────── Reporter — Dana ──────────────────────────────
def run_reporter():
    ceo_log = read_file("agents/memory/ceo_log.md", lines=20)
    cto_log = read_file("agents/memory/cto_decisions.md", lines=15)
    ios_log = read_file("agents/memory/ios_dev_log.md", lines=15)
    backlog = read_file("agents/memory/product/feature_backlog.md", lines=25)
    revenue = read_file("agents/memory/revenue/business_model_analysis.md", lines=15)
    git_24h = git("git log --oneline --since='24 hours ago'")
    commit_count = len(git_24h.splitlines()) if git_24h else 0

    tasks_dir = Path("agents/tasks")
    open_task_count = len([f for f in tasks_dir.iterdir() if f.is_file() and "_DONE" not in f.name]) if tasks_dir.exists() else 0

    prompt = f"""Today is {TODAY}. You are Dana, Reporter at STALK. Itamar (founder) reads this first thing in the morning.

TODAY'S AGENT OUTPUTS:

CEO Log:
{ceo_log}

CTO Log:
{cto_log}

iOS Dev Log:
{ios_log}

Feature Backlog (top):
{backlog}

Revenue Update:
{revenue}

GIT ACTIVITY (24h): {git_24h if git_24h else 'No commits'}

Stats: {commit_count} commits today, {open_task_count} open tasks.

Write the daily report. Sharp, factual, under 300 words.

=== FILE: agents/reports/daily_{TODAY}.md ===
# STALK Daily Report — {TODAY}
> Dana (Reporter Agent)

## What Got Done
[bullet list — concrete completions from git log and agent activity]

## Blockers
[what's stuck and who unblocks it]

## Agent Activity
- Alex (CEO): [1 line]
- Maya (CTO): [1 line]
- Jordan (iOS): [1 line]
- Luna (UX): [1 line]
- Sam (CPO): [1 line]
- Rex (CRO): [1 line]

## Top Priority Tomorrow
[the single most important thing Itamar should focus on]

## Stats
- Commits: {commit_count}
- Open tasks: {open_task_count}
=== END ==="""

    output = call_claude(prompt, max_tokens=1500)
    print("=== REPORTER OUTPUT ===\n", output)
    write_outputs(output)


# ─────────────────────────── Dispatch ─────────────────────────────────────
AGENTS = {
    "ceo": run_ceo,
    "cto": run_cto,
    "ios_dev": run_ios_dev,
    "ux": run_ux,
    "cpo": run_cpo,
    "cro": run_cro,
    "reporter": run_reporter,
}

if AGENT not in AGENTS:
    print(f"Unknown agent: {AGENT}. Valid: {list(AGENTS.keys())}")
    sys.exit(1)

print(f"Running agent: {AGENT} for {TODAY}")
AGENTS[AGENT]()
print(f"Agent {AGENT} done.")
