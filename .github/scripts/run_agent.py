#!/usr/bin/env python3
"""STALK Agent Network. Usage: python3 run_agent.py <agent_name>"""

import sys
import os
import re
import subprocess
from pathlib import Path
import anthropic

AGENT = sys.argv[1] if len(sys.argv) > 1 else "reporter"
TODAY = os.environ.get("TODAY", "unknown")
API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")

if not API_KEY or API_KEY == "***":
    print("ERROR: ANTHROPIC_API_KEY is not set or invalid")
    sys.exit(1)

client = anthropic.Anthropic(api_key=API_KEY)

FORMAT_INSTRUCTION = """
CRITICAL RULE: You MUST wrap every file you write in EXACTLY this format:
=== FILE: path/to/file.md ===
[file content here]
=== END ===

Do NOT output any text outside these markers. Only === FILE === blocks.
"""


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
    count = 0
    for filepath, content in matches:
        filepath = filepath.strip()
        content = content.strip()
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        Path(filepath).write_text(content + "\n")
        print(f"[WROTE] {filepath}")
        count += 1
    if count == 0:
        print("[WARN] No FILE blocks found. Dumping raw output for debug:")
        print(output[:500])
    return count


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
                open_tasks.append(f"- {f.name}")
    tasks_str = "\n".join(open_tasks) if open_tasks else "No open tasks."

    ceo_log_new = ceo_log + f"\n\n## {TODAY}\n[CEO priorities and decisions for today]"

    prompt = f"""{FORMAT_INSTRUCTION}

Today is {TODAY}. You are Alex, CEO of STALK — iOS SwiftUI stock portfolio social app.

COMPANY STATE:
{company_state}

CEO LOG (last 40 lines):
{ceo_log}

OPEN TASKS:
{tasks_str}

GIT LOG:
{git_log}

Write EXACTLY 7 FILE blocks (no other text):

1. Task for Maya (CTO) — architecture/data provider decisions
2. Task for Jordan (iOS Dev) — specific Swift code to review or build
3. Task for Luna (UX) — design audit focus
4. Task for Sam (CPO) — product prioritization
5. Task for Rex (CRO) — revenue/monetization action
6. Task for Dana (Reporter) — what to include in today's report
7. Updated CEO log (append new entry at bottom)

=== FILE: agents/tasks/CEO_CTO_TASK_{TODAY}.md ===
[Maya's task: architecture decisions needed today, specific and actionable, under 150 words]
=== END ===

=== FILE: agents/tasks/CEO_IOS_TASK_{TODAY}.md ===
[Jordan's task: specific Swift/SwiftUI work to review or flag, under 150 words]
=== END ===

=== FILE: agents/tasks/CEO_UX_TASK_{TODAY}.md ===
[Luna's task: design audit focus areas today, under 150 words]
=== END ===

=== FILE: agents/tasks/CEO_CPO_TASK_{TODAY}.md ===
[Sam's task: product prioritization focus, under 150 words]
=== END ===

=== FILE: agents/tasks/CEO_CRO_TASK_{TODAY}.md ===
[Rex's task: revenue/monetization action today, under 150 words]
=== END ===

=== FILE: agents/tasks/CEO_REPORTER_TASK_{TODAY}.md ===
[Dana's task: what to cover in daily report, under 80 words]
=== END ===

=== FILE: agents/memory/ceo_log.md ===
{ceo_log}

## {TODAY}
- [Priority 1]
- [Priority 2]
- [Priority 3]
- [Blockers: what needs Itamar's decision]
=== END ==="""

    output = call_claude(prompt, max_tokens=3500)
    print("=== CEO RAN ===")
    write_outputs(output)


# ─────────────────────────── CTO — Maya ────────────────────────────────────
def run_cto():
    company_state = read_file("agents/COMPANY_STATE.md")
    cto_log = read_file("agents/memory/cto_decisions.md", lines=30)
    git_log = git("git log --oneline -10")
    changed_swift = git("git diff HEAD~5 --name-only | grep '\\.swift$' | head -10")
    my_tasks = tasks_for(["CTO", "MAYA"])

    prompt = f"""{FORMAT_INSTRUCTION}

Today is {TODAY}. You are Maya, CTO of STALK. Swift 6, SwiftUI, @Observable only (never ObservableObject), MainActor.

COMPANY STATE:
{company_state}

CTO DECISIONS LOG:
{cto_log}

MY TASKS TODAY:
{my_tasks}

GIT LOG:
{git_log}

CHANGED SWIFT FILES:
{changed_swift if changed_swift else 'No Swift changes in last 5 commits'}

Write EXACTLY 1 FILE block — the updated CTO decisions log with today's section appended:

=== FILE: agents/memory/cto_decisions.md ===
{cto_log}

## {TODAY}
**Architecture decisions:**
- [Decision 1 with rationale]
**Technical risks flagged:**
- [Risk with file reference if applicable]
**Action items for Jordan:**
- [Specific Swift code task]
=== END ==="""

    output = call_claude(prompt, max_tokens=2000)
    print("=== CTO RAN ===")
    write_outputs(output)


# ─────────────────────────── iOS Dev — Jordan ──────────────────────────────
def run_ios_dev():
    company_state = read_file("agents/COMPANY_STATE.md")
    ios_log = read_file("agents/memory/ios_dev_log.md", lines=30)
    git_log = git("git log --oneline -10")
    changed_files = git("git diff HEAD~3 --name-only | grep '\\.swift$' | head -5")
    my_tasks = tasks_for(["IOS", "JORDAN"])

    snippets = ""
    if changed_files:
        for f in changed_files.splitlines():
            if Path(f).exists():
                lines_content = Path(f).read_text().splitlines()[:50]
                snippets += f"\n--- {f} ---\n" + "\n".join(lines_content)

    prompt = f"""{FORMAT_INSTRUCTION}

Today is {TODAY}. You are Jordan, iOS Developer at STALK. Swift 6, @Observable only, MainActor isolation.

COMPANY STATE:
{company_state}

IOS DEV LOG:
{ios_log}

MY TASKS:
{my_tasks}

GIT LOG:
{git_log}

CHANGED SWIFT FILES:
{snippets if snippets else changed_files if changed_files else 'No Swift changes in last 3 commits'}

Write EXACTLY 1 FILE block — the updated iOS dev log with today's section:

=== FILE: agents/memory/ios_dev_log.md ===
{ios_log}

## {TODAY}
**Files reviewed:** [list or 'none changed']
**Bugs or issues found:** [specific, with file:line if possible, or 'none found']
**Recommendations:** [actionable improvements]
**Code quality notes:** [@Observable compliance, MainActor usage, any anti-patterns]
**For Itamar review:** [anything requiring founder decision, or 'none']
=== END ==="""

    output = call_claude(prompt, max_tokens=2000)
    print("=== iOS Dev RAN ===")
    write_outputs(output)


# ─────────────────────────── UX — Luna ────────────────────────────────────
def run_ux():
    company_state = read_file("agents/COMPANY_STATE.md")
    screen_audit = read_file("agents/memory/design/screen_audit.md", lines=40)
    my_tasks = tasks_for(["UX", "LUNA"])
    changed_files = git("git diff HEAD~3 --name-only | grep '\\.swift$' | head -5")

    snippets = ""
    if changed_files:
        for f in changed_files.splitlines():
            if Path(f).exists():
                lines_content = Path(f).read_text().splitlines()[:40]
                snippets += f"\n--- {f} ---\n" + "\n".join(lines_content)

    prompt = f"""{FORMAT_INSTRUCTION}

Today is {TODAY}. You are Luna, UX Lead at STALK. Nano banana (#D4F03C) = ONLY on data viz, never UI chrome.

COMPANY STATE:
{company_state}

SCREEN AUDIT LOG:
{screen_audit}

MY TASKS:
{my_tasks}

CHANGED UI FILES:
{snippets if snippets else 'No UI changes in last 3 commits'}

Write EXACTLY 1 FILE block — the updated screen audit with today's entry:

=== FILE: agents/memory/design/screen_audit.md ===
{screen_audit}

## {TODAY}
**Files reviewed:** [list or 'none changed']
**Design issues:** [specific — wrong color usage, missing shadow, layout issue + file reference]
**Nano banana status:** [correct / misused — where exactly]
**Recommendations for next sprint:** [top 2-3 UX improvements]
=== END ==="""

    output = call_claude(prompt, max_tokens=1500)
    print("=== UX RAN ===")
    write_outputs(output)


# ─────────────────────────── CPO — Sam ────────────────────────────────────
def run_cpo():
    company_state = read_file("agents/COMPANY_STATE.md")
    backlog = read_file("agents/memory/product/feature_backlog.md")
    my_tasks = tasks_for(["CPO", "SAM"])

    prompt = f"""{FORMAT_INSTRUCTION}

Today is {TODAY}. You are Sam, CPO of STALK. Target: retail investors. Competitors: Robinhood, eToro, Stocktwits.

COMPANY STATE:
{company_state}

FEATURE BACKLOG:
{backlog}

MY TASKS:
{my_tasks}

Write EXACTLY 1 FILE block — the updated feature backlog:

=== FILE: agents/memory/product/feature_backlog.md ===
# STALK Feature Backlog — Updated {TODAY}

## HIGH — Launch Blockers
[items required before App Store launch — be specific]

## MEDIUM — Launch Enhancers
[items that significantly improve launch quality]

## LOW — Post-Launch
[nice-to-have features after first users]

## {TODAY} CPO Notes
- Top feature this week: [specific]
- Competitor gap to close: [specific vs. Robinhood/eToro/Stocktwits]
- Launch readiness: [% estimate and what's blocking]
=== END ==="""

    output = call_claude(prompt, max_tokens=2000)
    print("=== CPO RAN ===")
    write_outputs(output)


# ─────────────────────────── CRO — Rex ────────────────────────────────────
def run_cro():
    company_state = read_file("agents/COMPANY_STATE.md")
    revenue_analysis = read_file("agents/memory/revenue/business_model_analysis.md", lines=50)
    my_tasks = tasks_for(["CRO", "REX"])

    prompt = f"""{FORMAT_INSTRUCTION}

Today is {TODAY}. You are Rex, CRO of STALK. Model: freemium ($4.99/mo or $29.99/yr) + broker affiliate.

COMPANY STATE:
{company_state}

REVENUE ANALYSIS:
{revenue_analysis}

MY TASKS:
{my_tasks}

Write EXACTLY 1 FILE block — the updated revenue analysis with today's section appended:

=== FILE: agents/memory/revenue/business_model_analysis.md ===
{revenue_analysis}

## {TODAY} Revenue Update
- Top revenue lever this week: [specific and actionable]
- Paywall timing: [when in user journey to show paywall]
- Broker affiliate next step: [one concrete action]
- Conversion insight: [one key observation]
=== END ==="""

    output = call_claude(prompt, max_tokens=1500)
    print("=== CRO RAN ===")
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

    prompt = f"""{FORMAT_INSTRUCTION}

Today is {TODAY}. You are Dana, Reporter at STALK. Itamar reads this first thing every morning.

CEO LOG: {ceo_log}
CTO LOG: {cto_log}
iOS DEV LOG: {ios_log}
BACKLOG (top): {backlog}
REVENUE: {revenue}
GIT (24h): {git_24h if git_24h else 'No commits'}
Stats: {commit_count} commits, {open_task_count} open tasks.

Write EXACTLY 1 FILE block — the daily report. Under 300 words. Sharp and factual.

=== FILE: agents/reports/daily_{TODAY}.md ===
# STALK Daily Report — {TODAY}
> Dana (Reporter Agent)

## What Got Done
- [bullet from git log + agent activity]

## Blockers
- [what is stuck and who unblocks it]

## Agent Activity
- Alex (CEO): [1 line]
- Maya (CTO): [1 line]
- Jordan (iOS): [1 line]
- Luna (UX): [1 line]
- Sam (CPO): [1 line]
- Rex (CRO): [1 line]

## Top Priority Tomorrow
[single most important thing for Itamar]

## Stats
- Commits: {commit_count}
- Open tasks: {open_task_count}
=== END ==="""

    output = call_claude(prompt, max_tokens=1500)
    print("=== REPORTER RAN ===")
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

print(f"[START] Agent: {AGENT} | Date: {TODAY}")
AGENTS[AGENT]()
print(f"[DONE] Agent: {AGENT}")
