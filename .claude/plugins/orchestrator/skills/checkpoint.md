---
name: checkpoint
description: Manually save current orchestrator state
---

# /checkpoint - Manual Checkpoint Save

Manually triggers a checkpoint save to persist current orchestrator state.

## Usage

```bash
# Save checkpoint with current state
/checkpoint

# Save checkpoint with custom message
/checkpoint "Completed issue #5, about to start #6"

# Force save (even if no changes)
/checkpoint --force
```

## What It Does

1. **Syncs GitHub State** - Queries issues for latest status
2. **Updates Checkpoint** - Writes to `docs/.orchestrator-state.json`
3. **Records Context** - Tracks token usage
4. **Updates Resume Hint** - Sets helpful resume message

## When to Use

Checkpoints are **automatic** after:
- Each phase completes
- Each issue closes
- Each agent invocation
- Every 10 minutes during long operations

**Manual checkpoint** useful for:
- Before risky operations
- After significant manual changes
- Before closing session voluntarily
- After fixing bugs outside orchestrator

## Output

```bash
📋 Syncing GitHub state...
✅ Work progress updated: 12 total, 5 completed

💾 Checkpoint saved
   Phase: 3 (Implementation)
   In-Progress: Issue #6
   Context: 48%
   Last Updated: 2026-01-31T15:45:00Z

💡 Resume hint: "Completed issue #5 (User Auth), starting issue #6 (Password Reset)"
```

## Checkpoint Contents

```json
{
  "version": "1.0",
  "project": {
    "name": "task-management-api",
    "idea": "A RESTful API for task management...",
    "started_at": "2026-01-31T10:00:00Z",
    "last_updated": "2026-01-31T15:45:00Z"
  },
  "phase": {
    "current": 3,
    "name": "Implementation",
    "started_at": "2026-01-31T13:00:00Z",
    "last_checkpoint": "2026-01-31T15:45:00Z",
    "status": "in_progress"
  },
  "phases_completed": [0, 1, 2],
  "work_progress": {
    "total_issues": 12,
    "completed_issues": [1, 2, 3, 4, 5],
    "in_progress_issue": 6,
    "open_issues": [6, 7, 8, 9, 10, 11, 12],
    "bug_issues": [],
    "last_closed_at": "2026-01-31T15:40:00Z"
  },
  "context_tracking": {
    "total_budget": 200000,
    "used": 96000,
    "percentage": 48,
    "last_issue_context": 14000,
    "approaching_limit": false
  },
  "verification": {
    "loop_count": 1,
    "max_loops": 3,
    "last_attempt_at": "2026-01-31T14:20:00Z",
    "failures": []
  },
  "agents_invoked": [
    {
      "agent": "product-manager",
      "phase": 1,
      "status": "completed",
      "started_at": "2026-01-31T10:15:00Z",
      "completed_at": "2026-01-31T10:45:00Z"
    },
    {
      "agent": "developer",
      "phase": 3,
      "issue": 6,
      "status": "in_progress",
      "started_at": "2026-01-31T15:42:00Z"
    }
  ],
  "artifacts_created": [
    "docs/PRD.md",
    "docs/ARCHITECTURE.md",
    ".github/workflows/ci.yml",
    "src/index.ts",
    "src/auth/jwt.ts",
    "src/auth/password.ts"
  ],
  "resume_instructions": "Resume at Phase 3, issue #6 (Password Reset). Completed user auth, now implementing password reset flow."
}
```

## Automatic Checkpoint Triggers

Checkpoints save automatically on:

| Trigger | Location | Frequency |
|---------|----------|-----------|
| Phase complete | All phases | Once per phase |
| Issue closed | Phase 3 | Per issue |
| Agent start | All phases | Per agent |
| Agent complete | All phases | Per agent |
| Verification loop | Phase 5 | Per attempt |
| Heartbeat | Long operations | Every 10 min |

## Context Budget Warnings

Checkpoint tracks context usage:

```bash
📊 Context usage: 48%

# At 75%
⚠️  Context usage: 78% - approaching limit!
💡 Consider saving and resuming tomorrow

# At 90%
🚨 Context usage: 92% - CRITICAL!
🛑 Save immediately and resume in new session
```

## Recovery Scenarios

### Crash Recovery
If orchestrator crashes mid-execution:
```bash
# Last checkpoint before crash
Last Updated: 2026-01-31T15:40:00Z
In-Progress: Issue #5

# Resume picks up from last saved state
/resume
# Continues from issue #5
```

### Manual Intervention
After fixing something manually:
```bash
# Fixed bug in auth.ts outside orchestrator
git commit -m "fix: resolve token expiration bug"

# Update checkpoint to reflect manual change
/checkpoint "Manually fixed token expiration bug"

# Resume orchestrator
/resume
```

### Context Limit Hit
Before hitting limit:
```bash
# Context at 78%
⚠️  Approaching limit

# Save and exit
/checkpoint "Completed issue #5, context at 78%"
exit

# Next day - fresh context
cd ~/projects/task-api
/resume
# Starts with 0% context usage
```

## Verification

After checkpoint, verify with:

```bash
# Show status
/status

# View checkpoint file directly
cat docs/.orchestrator-state.json | jq '.'

# Check GitHub sync
gh issue list --json number,state
```

## Related Skills

- `/resume` - Resume from checkpoint
- `/status` - View checkpoint status
- `/orchestrator` - Main workflow (auto-checkpoints)

## Notes

- Checkpoint file: `docs/.orchestrator-state.json`
- GitHub is source of truth for issues
- Context budget resets per session
- Checkpoints are **idempotent** (safe to call multiple times)
