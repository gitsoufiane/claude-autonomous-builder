---
name: resume
description: Resume orchestrator execution from last checkpoint
---

# /resume - Resume Orchestrator Execution

Resumes the autonomous orchestrator from its last saved checkpoint.

## Usage

```bash
# Resume from checkpoint (with confirmation)
/resume

# Force resume (skip confirmation)
/resume --force

# Show checkpoint status without resuming
/resume --status
```

## What It Does

1. **Reads Checkpoint** - Loads `docs/.orchestrator-state.json`
2. **Verifies State** - Syncs checkpoint with GitHub issues
3. **Shows Status** - Displays current phase, progress, context usage
4. **Asks Confirmation** - User approves resume (unless `--force`)
5. **Resumes Execution** - Continues from exact point of interruption

## Prerequisites

- ✅ Checkpoint file must exist (`docs/.orchestrator-state.json`)
- ✅ GitHub repository must be configured
- ✅ Issues must reflect actual work state

## Resume Behavior by Phase

### Phase 0: Infrastructure Setup
- Checks existing CI/CD artifacts
- Re-runs setup if incomplete
- Advances to Phase 1 if complete

### Phase 1: Product Definition
- Verifies PRD exists
- Checks GitHub issues created
- Validates complexity analysis done
- Advances to Phase 2 if complete

### Phase 2: Architecture & Design
- Verifies architecture document
- Checks project structure initialized
- Advances to Phase 3 if complete

### Phase 3: Implementation (Most Common)
- Syncs checkpoint with GitHub state
- Identifies last completed issue
- Resumes at next open issue
- Handles bug fixes if any

### Phase 4: Quality Assurance
- Checks for QA report
- Identifies bugs found
- Returns to Phase 3 if bugs exist
- Advances to Phase 5 if clean

### Phase 5: Verification Loop
- Restores loop counter
- Detects divergence if max loops reached
- Re-runs verification checks
- Advances to Phase 6 on success

### Phase 6: Learning & Evolution
- Checks for learning report
- Re-runs learning if incomplete
- Marks project complete

## Example Output

```
🔄 Orchestrator Checkpoint Found

Project: task-management-api
Last Updated: 2026-01-31 14:30:00 UTC

📍 Current Phase: 3 (Implementation)
✅ Completed: 4/12 issues
🔄 In-Progress: Issue #5 (User Authentication)
📊 Context Used: 42%

💡 Resume at Phase 3, issue #5 (User Authentication). Developer agent was implementing JWT utilities when interrupted.

Resume from here? (y/n)
```

## State Synchronization

The resume process **always syncs with GitHub** to ensure accuracy:

1. Queries `gh issue list` for actual state
2. Compares with checkpoint data
3. Updates checkpoint if diverged
4. Uses GitHub as source of truth

**Handles:**
- Issues closed outside orchestrator
- New bugs created manually
- Labels changed
- Issue edits

## Context Budget Tracking

Resume restores context tracking:

```json
{
  "context_tracking": {
    "total_budget": 200000,
    "used": 84000,
    "percentage": 42,
    "last_issue_context": 12000,
    "approaching_limit": false
  }
}
```

**Warning at 75% usage:**
```
⚠️  Context usage: 78% - approaching limit!
💡 Consider closing current session and resuming tomorrow
```

## Verification Loop Recovery

Preserves loop counter across sessions:

```json
{
  "verification": {
    "loop_count": 2,
    "max_loops": 3,
    "last_attempt_at": "2026-01-31T14:20:00Z",
    "failures": [
      {
        "message": "Tests failed: 3 errors in auth.test.ts",
        "timestamp": "2026-01-31T14:15:00Z"
      }
    ]
  }
}
```

On resume, continues from **loop 2 of 3**, not restarting at loop 1.

## Error Handling

### Checkpoint Not Found
```bash
❌ No checkpoint found at docs/.orchestrator-state.json

Use /orchestrator to start a new project.
```

### Checkpoint/GitHub Mismatch
```bash
⚠️  Checkpoint/GitHub mismatch in completed issues
   Checkpoint: [1,2,3,4]
   GitHub: [1,2,3,4,5]

🔄 Syncing checkpoint with GitHub...
✅ Checkpoint synchronized
```

### Divergence Detected
```bash
🛑 Max verification loops reached (3/3)
📄 Divergence report: docs/DIVERGENCE-REPORT.md

Manual intervention required. Review the report and provide guidance.
```

## Related Skills

- `/checkpoint` - Manually save current state
- `/status` - Show checkpoint status without resuming
- `/orchestrator` - Start new project or detect existing checkpoint

## Notes

- Checkpoint updates automatically after each phase and issue
- Resume is **session-independent** - works across days/weeks
- GitHub issues are the **source of truth** for all work
- Context budget resets on new session (200K tokens available)
