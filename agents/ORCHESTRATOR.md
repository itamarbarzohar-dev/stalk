# STALK Agent Orchestrator
> Instructions for running the agent team

## How to Run an Agent

```bash
cd /Users/itamarbarzohar/Desktop/STALK/agents
./run_agent.sh ceo        # CEO sets the agenda and delegates
./run_agent.sh cto        # CTO makes architecture decisions
./run_agent.sh cpo        # CPO writes specs and roadmap
./run_agent.sh ios_dev    # iOS Dev writes code
./run_agent.sh reporter   # Reporter writes daily summary
```

## Recommended Daily Workflow

### Morning (start of day)
```bash
./run_agent.sh ceo        # CEO reads state, creates tasks for the team
./run_agent.sh cpo        # CPO picks up product tasks
./run_agent.sh cto        # CTO picks up architecture tasks
./run_agent.sh ios_dev    # iOS Dev implements features
```

### End of Day
```bash
./run_agent.sh reporter   # Reporter summarizes the day → reports/daily_DATE.md
```

## Meeting Mode
To run a "meeting" between agents, run them in sequence on the same topic:
```bash
# Example: Product planning meeting
./run_agent.sh ceo        # CEO sets the meeting agenda in meetings/
./run_agent.sh cpo        # CPO responds and adds to meeting notes
./run_agent.sh cto        # CTO adds technical constraints
./run_agent.sh ceo        # CEO reads responses and makes final decision
```

## File System Layout
```
agents/
  COMPANY_STATE.md        ← Single source of truth (read by all agents)
  ORCHESTRATOR.md         ← This file
  roles/                  ← Agent identity and instructions
    ceo.md
    cto.md
    cpo.md
    ios_dev.md
    reporter.md
  tasks/                  ← Task queue (agents create + consume)
    CEO_*.md
    CTO_*.md
    CPO_*.md
    iOS_*.md
  memory/                 ← Agent logs, decisions, PRDs
    ceo_log.md
    cto_decisions.md
    ios_dev_log.md
    prd/                  ← Product requirement docs
    adr/                  ← Architecture decision records
  meetings/               ← Meeting notes
  reports/                ← Daily reports for Itamar
    daily_YYYY-MM-DD.md
```

## Adding New Agents
1. Create `roles/[agent_name].md` following the same format
2. Run with `./run_agent.sh [agent_name]`
3. Update this file

## Current Agents (5/30)
- [x] CEO — Alex
- [x] CTO — Maya
- [x] CPO — Sam
- [x] iOS Dev — Jordan
- [x] Reporter — Dana
- [ ] CMO, CFO, Growth, Designer, Backend Dev... (25 more to add)
