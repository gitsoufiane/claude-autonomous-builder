---
name: status
description: Show current orchestrator checkpoint status
---

# /status - Show Orchestrator Status

Displays the current orchestrator checkpoint status without resuming execution.

## Usage

```bash
# Show full status
/status

# Show compact status
/status --compact

# Show with GitHub sync check
/status --verify
```

## What It Does

1. **Reads Checkpoint** - Loads `docs/.orchestrator-state.json`
2. **Displays State** - Shows phase, progress, context
3. **No Execution** - Read-only, doesn't resume work

## Example Output

### Full Status

```
🔄 Orchestrator Status

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Project: task-management-api
💡 Idea: A RESTful API for task management with JWT auth...

⏰ Started: 2026-01-31 10:00:00 UTC
🔄 Last Updated: 2026-01-31 15:45:00 UTC
⏱️  Duration: 5h 45m

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Current Phase: 3 (Implementation)
   Status: in_progress
   Started: 2026-01-31 13:00:00 UTC
   Duration: 2h 45m

✅ Completed Phases: [0, 1, 2]
   0: Infrastructure Setup
   1: Product Definition
   2: Architecture & Design

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Work Progress

Total Issues: 12
✅ Completed: 5 issues [#1, #2, #3, #4, #5]
🔄 In-Progress: Issue #6 (Password Reset)
📝 Open: 7 issues [#6, #7, #8, #9, #10, #11, #12]
🐛 Bugs: 0 issues

Last Closed: Issue #5 at 2026-01-31T15:40:00Z

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Context Tracking

Total Budget: 200,000 tokens
Used: 96,000 tokens (48%)
Last Issue: 14,000 tokens

Status: ✅ Healthy (below 75% threshold)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Verification Loop

Current Loop: 1 of 3 max
Last Attempt: 2026-01-31T14:20:00Z
Failures: 0

Status: ✅ No divergence

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🤖 Agents Invoked

1. product-manager (Phase 1)
   ✅ completed
   Duration: 30m

2. architect (Phase 2)
   ✅ completed
   Duration: 1h 30m

3. developer (Phase 3, Issue #6)
   🔄 in_progress
   Started: 2026-01-31T15:42:00Z

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Artifacts Created

- docs/PRD.md
- docs/ARCHITECTURE.md
- .github/workflows/ci.yml
- .github/workflows/security.yml
- src/index.ts
- src/auth/jwt.ts
- src/auth/password.ts

Total: 7 files

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Resume Instructions

Resume at Phase 3, issue #6 (Password Reset). Completed user auth, now implementing password reset flow.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Use /resume to continue from checkpoint.
```

### Compact Status

```
📍 Phase 3 (Implementation) | ✅ 5/12 issues | 🔄 Issue #6 | 📊 48% context
```

## Status with Verification

```bash
/status --verify
```

Adds GitHub sync check:

```
🔍 Verifying checkpoint against GitHub...

Checkpoint State:
  Completed: [1, 2, 3, 4, 5]
  Open: [6, 7, 8, 9, 10, 11, 12]

GitHub State:
  Closed: [1, 2, 3, 4, 5]
  Open: [6, 7, 8, 9, 10, 11, 12]

✅ Checkpoint in sync with GitHub

[... rest of status ...]
```

## Context Usage Indicators

Status includes visual indicators for context:

```bash
# Healthy (0-50%)
📊 Context: 48% ✅ Healthy

# Warning (51-75%)
📊 Context: 68% ⚠️  Moderate

# Approaching Limit (76-89%)
📊 Context: 82% 🚨 High - Consider resuming tomorrow

# Critical (90-100%)
📊 Context: 94% 🛑 CRITICAL - Save and resume immediately
```

## Verification Loop Status

Shows verification state:

```bash
# No attempts yet
🔍 Verification: Not started

# In progress (loops remaining)
🔍 Verification: Loop 1/3 ✅ Active

# Approaching limit
🔍 Verification: Loop 2/3 ⚠️  Warning

# Divergence detected
🔍 Verification: Loop 3/3 🛑 Divergence - Manual intervention required
```

## Phase Progress Visualization

```bash
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 0: Infrastructure Setup      (15m)
✅ 1: Product Definition        (30m)
✅ 2: Architecture & Design     (1h 30m)
🔄 3: Implementation            (2h 45m - in progress)
⏳ 4: Quality Assurance
⏳ 5: Verification Loop
⏳ 6: Learning & Evolution

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## No Checkpoint Found

If no checkpoint exists:

```
❌ No orchestrator checkpoint found

Location: docs/.orchestrator-state.json

This directory has no active orchestrator session.

To start a new project:
  /orchestrator "Your project idea"

To resume an existing project:
  cd /path/to/project
  /status
```

## Use Cases

### Daily Standup
Check progress before resuming work:
```bash
cd ~/projects/task-api
/status --compact

# Output: Phase 3 | ✅ 5/12 issues | 🔄 Issue #6 | 📊 48% context
```

### Mid-Session Check
Verify context usage during work:
```bash
/status

# See: Context: 68% ⚠️  Moderate
# Decision: Continue or save for tomorrow
```

### Debugging
Check if checkpoint matches GitHub:
```bash
/status --verify

# Detects mismatches, suggests sync
```

### Handoff
Share status with team/user:
```bash
/status > status.txt
cat status.txt

# Send status report
```

## Related Skills

- `/resume` - Resume from checkpoint
- `/checkpoint` - Save current state
- `/orchestrator` - Start new project

## Notes

- Read-only operation (doesn't modify state)
- Always shows **latest** checkpoint data
- Use `--verify` to catch GitHub/checkpoint drift
- Compact mode useful for scripting/automation
