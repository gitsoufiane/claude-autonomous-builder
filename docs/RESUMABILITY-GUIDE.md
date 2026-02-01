# Orchestrator Resumability Guide

The autonomous orchestrator supports **resumability** - the ability to stop work at any point and continue later with full context preservation.

## Why Resumability?

Building complex projects can take hours or days. Resumability enables:

- 🔄 **Multi-Session Work** - Stop at any time, resume tomorrow
- 💾 **Checkpoint Recovery** - Recover from crashes or interruptions
- 📊 **Context Protection** - Avoid hitting token limits mid-task
- 🎯 **Precise Continuation** - Resume exactly where you left off
- 🔍 **State Verification** - Sync with GitHub to ensure accuracy

## How It Works

### Automatic Checkpointing

The orchestrator saves state automatically:

| Event | Checkpoint Trigger |
|-------|-------------------|
| Phase Complete | After each of 7 phases |
| Issue Closed | After every GitHub issue |
| Agent Invoked | Before/after agent runs |
| Long Operations | Every 10 minutes (heartbeat) |
| Context Warning | At 75%, 80%, 85%, 90% usage |

**You never have to manually save** (but you can with `/checkpoint`).

### Checkpoint Contents

Every checkpoint includes:

```json
{
  "project": {
    "name": "task-management-api",
    "idea": "Original project description",
    "started_at": "2026-01-31T10:00:00Z"
  },
  "phase": {
    "current": 3,
    "name": "Implementation",
    "status": "in_progress"
  },
  "work_progress": {
    "completed_issues": [1, 2, 3, 4, 5],
    "in_progress_issue": 6,
    "open_issues": [6, 7, 8, 9, 10, 11, 12]
  },
  "context_tracking": {
    "used": 96000,
    "percentage": 48
  },
  "verification": {
    "loop_count": 1,
    "max_loops": 3
  }
}
```

Stored at: `docs/.orchestrator-state.json`

## Basic Usage

### Start a New Project

```bash
cd ~/projects/my-new-project
/orchestrator "A task management API with JWT auth"

# Orchestrator runs for a few hours...
# Context at 78% - save and resume tomorrow
```

Checkpoint automatically saved at `docs/.orchestrator-state.json`.

### Resume Existing Project

```bash
cd ~/projects/my-new-project
/orchestrator

# Output:
🔄 Existing project found: task-management-api
📍 Last checkpoint: Implementation (at 2026-01-31 15:45:00 UTC)
💡 Resume at Phase 3, issue #6 (Password Reset)

Resume existing project or start fresh?
> resume

# Continues exactly from issue #6
```

Or use the explicit resume skill:

```bash
/resume
```

### Check Status

Before resuming, check project status:

```bash
cd ~/projects/my-project
/status

# Shows:
# - Current phase
# - Completed/open issues
# - Context usage
# - Last activity
```

## Advanced Usage

### Force Resume

Skip confirmation dialog:

```bash
/resume --force
```

### Manual Checkpoint

Save state manually before risky operations:

```bash
/checkpoint "About to refactor auth module"

# Do manual work...

/checkpoint "Refactoring complete"
```

### Verify Checkpoint Accuracy

Check if checkpoint matches GitHub:

```bash
/status --verify

# Output:
🔍 Verifying checkpoint against GitHub...
✅ Checkpoint in sync with GitHub
```

### Start Fresh (Delete Checkpoint)

Abandon checkpoint and start over:

```bash
/orchestrator --fresh "New project idea"

# Warns you:
⚠️  Starting fresh will DELETE existing state.
Are you sure? (y/n)
```

## Resume Scenarios

### Scenario 1: Context Limit Approaching

**Day 1:**
```bash
/orchestrator "E-commerce platform with Stripe integration"

# ... Phase 3, working on issue #8 ...
# Context at 78%

⚠️  Context usage: 78% - approaching limit!
💡 Consider closing current session and resuming tomorrow

# Save and exit (auto-checkpoint)
exit
```

**Day 2:**
```bash
cd ~/projects/ecommerce
/resume

# Starts with fresh 200K context budget
# Continues from issue #8
```

### Scenario 2: Mid-Issue Crash

```bash
/orchestrator "Blog platform with Markdown editor"

# ... Phase 3, implementing issue #5 ...
# Computer crashes or connection lost

# Last checkpoint: Issue #4 completed, #5 in-progress
```

**Recovery:**
```bash
cd ~/projects/blog
/resume

# Output:
🔄 Issue #5 still open - resuming here
   Title: Markdown Editor Component
```

Orchestrator re-runs issue #5 from start (may duplicate some work, but ensures correctness).

### Scenario 3: Verification Loop Resume

```bash
/orchestrator "Complex microservices architecture"

# ... Phase 5: Verification Loop 2/3 ...
# Tests still failing, hit context limit

# Checkpoint saved:
{
  "verification": {
    "loop_count": 2,
    "max_loops": 3
  }
}
```

**Resume:**
```bash
/resume

# Continues from loop 2/3 (not restart at loop 1)
# Runs 3rd verification attempt
```

### Scenario 4: Manual Intervention

```bash
/orchestrator "API with rate limiting"

# ... Phase 3 ...
# You notice a bug and fix it manually outside orchestrator

git add src/middleware/ratelimit.ts
git commit -m "fix: resolve rate limit window calculation"

# Update checkpoint to reflect manual work
/checkpoint "Manually fixed rate limit bug in middleware"

# Resume orchestrator
/resume
```

## Context Budget Protection

### How It Works

Each session has a 200,000 token budget. Checkpoint tracks usage:

```bash
# During execution
📊 Context usage: 48%    # Healthy
📊 Context usage: 76%    # Warning at 75%
⚠️  Context usage: 82%   # High - save soon
🚨 Context usage: 94%    # CRITICAL - save immediately
```

### When to Save

**Recommended:** Save at 75-80% usage

```bash
# Check status
/status

# See: Context: 78% ⚠️  Approaching limit

# Save and resume tomorrow
/checkpoint "Completed issue #7, stopping at 78% context"
exit

# Next day
/resume  # Fresh 200K budget
```

### Why 75%?

Remaining 25% (50K tokens) provides buffer for:
- Resume operations
- GitHub queries
- State synchronization
- Graceful shutdown

## State Synchronization

### GitHub as Source of Truth

Checkpoint syncs with GitHub on resume:

```bash
/resume

# Behind the scenes:
1. Read checkpoint: completed_issues = [1,2,3,4]
2. Query GitHub: closed issues = [1,2,3,4,5]
3. Detect mismatch: Issue #5 closed outside orchestrator
4. Sync checkpoint: Update to match GitHub
5. Continue from issue #6
```

### Handles:

- ✅ Issues closed manually
- ✅ New bugs created outside orchestrator
- ✅ Labels changed
- ✅ Issue edits/comments
- ✅ Issues deleted

### Verification

Always verify sync:

```bash
/status --verify

# Output:
Checkpoint State:
  Completed: [1, 2, 3, 4, 5]
  Open: [6, 7, 8, 9, 10, 11, 12]

GitHub State:
  Closed: [1, 2, 3, 4, 5]
  Open: [6, 7, 8, 9, 10, 11, 12]

✅ Checkpoint in sync with GitHub
```

## Phase-Specific Resume Behavior

### Phase 0: Infrastructure Setup

**Resumes by:**
1. Checking existing CI/CD artifacts
2. Re-running setup if incomplete
3. Advancing to Phase 1 if complete

### Phase 1: Product Definition

**Resumes by:**
1. Verifying PRD exists
2. Checking GitHub issues created
3. Validating complexity analysis done
4. Advancing to Phase 2 if complete

### Phase 2: Architecture & Design

**Resumes by:**
1. Verifying architecture document
2. Checking project structure initialized
3. Advancing to Phase 3 if complete

### Phase 3: Implementation (Most Common)

**Resumes by:**
1. Syncing checkpoint with GitHub
2. Identifying last completed issue
3. Resuming at next open feature issue
4. Or switching to bug fixes if any exist

**Example:**
```bash
# Resume output
💻 Phase 3: Implementation (Resuming)

✅ Completed issues: 1, 2, 3, 4, 5
🔄 In-progress issue: #6 (Password Reset)

▶️  Resuming implementation at issue #6
```

### Phase 4: Quality Assurance

**Resumes by:**
1. Checking for QA report
2. Identifying bugs found
3. Returning to Phase 3 if bugs exist
4. Advancing to Phase 5 if clean

### Phase 5: Verification Loop

**Resumes by:**
1. Restoring loop counter (critical!)
2. Detecting divergence if max loops reached
3. Re-running verification checks
4. Advancing to Phase 6 on success

**Example:**
```bash
# Resume with loop counter preserved
🔍 Phase 5: Verification (Resuming)

🔄 Verification attempt: 2 of 3

▶️  Re-running verification checks
```

### Phase 6: Learning & Evolution

**Resumes by:**
1. Checking for learning report
2. Re-running learning if incomplete
3. Marking project complete

## Best Practices

### 1. Check Status Daily

Start each session by checking status:

```bash
cd ~/projects/my-project
/status --compact

# Compact output for quick check
Phase 3 | ✅ 8/15 issues | 🔄 Issue #9 | 📊 52% context
```

### 2. Save Before Risky Operations

Manual checkpoint before experiments:

```bash
/checkpoint "Before attempting WebSocket refactor"

# Try risky refactor...

# If it fails:
git reset --hard HEAD
/resume  # Back to checkpoint
```

### 3. Monitor Context Usage

Watch context throughout session:

```bash
# Periodically check
/status

# Act at thresholds:
# 75% → Plan to save soon
# 80% → Save within 1-2 issues
# 85% → Save immediately
```

### 4. Verify Sync on Long Gaps

If resuming after days/weeks:

```bash
/status --verify

# Ensure checkpoint matches GitHub
# Especially if team made changes
```

### 5. Use Compact Status for Scripting

Integrate into daily workflow:

```bash
#!/bin/bash
# morning-standup.sh

cd ~/projects/current-project
echo "Project Status:"
/status --compact
```

## Troubleshooting

### Checkpoint Not Found

```bash
❌ No checkpoint found at docs/.orchestrator-state.json

Use /orchestrator to start a new project.
```

**Cause:** No project started in this directory

**Fix:** Start new project or `cd` to correct directory

### Checkpoint/GitHub Mismatch

```bash
⚠️  Checkpoint/GitHub mismatch in completed issues
🔄 Syncing checkpoint with GitHub...
✅ Checkpoint synchronized
```

**Cause:** Manual changes made outside orchestrator

**Fix:** Automatic (checkpoint syncs to match GitHub)

### Verification Divergence

```bash
🛑 Max verification loops reached (3/3)
📄 Divergence report: docs/DIVERGENCE-REPORT.md
```

**Cause:** Tests failing repeatedly, coverage not met

**Fix:** Review `DIVERGENCE-REPORT.md`, manually fix issues, then:

```bash
# After manual fixes
git commit -m "fix: resolve divergence issues"

# Resume (will re-run verification)
/resume
```

### Corrupted Checkpoint

```bash
❌ Error reading checkpoint: Invalid JSON
```

**Cause:** Checkpoint file corrupted

**Fix:**

```bash
# Restore from git
git checkout docs/.orchestrator-state.json

# Or delete and recreate
rm docs/.orchestrator-state.json
/orchestrator --fresh "Project idea"
```

## Architecture

### Checkpoint File Location

```
project-root/
├── docs/
│   ├── .orchestrator-state.json  ← Checkpoint file
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   └── ...
```

**Why `docs/`?**
- Already created in Phase 1
- Logical home for project metadata
- Easy to `.gitignore` if desired

### Scripts

```
.claude/
├── scripts/
│   ├── checkpoint.sh         ← State management functions
│   └── resume-handlers.sh    ← Phase-specific resume logic
```

### Skills

```
.claude/
├── plugins/
│   └── orchestrator/
│       ├── plugin.json
│       └── skills/
│           ├── resume.md      ← /resume skill
│           ├── checkpoint.md  ← /checkpoint skill
│           └── status.md      ← /status skill
```

## FAQ

### Q: Do checkpoints work across different machines?

**A:** Yes, if you commit `.orchestrator-state.json` to git:

```bash
# Machine 1
git add docs/.orchestrator-state.json
git commit -m "chore: save orchestrator checkpoint"
git push

# Machine 2
git pull
/resume
```

### Q: Can I edit the checkpoint file manually?

**A:** Yes, but risky. Better to use checkpoint functions:

```bash
# Instead of manual edit:
source .claude/scripts/checkpoint.sh
update_checkpoint "work_progress.in_progress_issue" 7
```

### Q: What if I delete an issue on GitHub?

**A:** Checkpoint syncs on resume:

```bash
# Delete issue #6 on GitHub

# Resume detects and skips to #7
/resume

# Output:
Issue #6 not found - skipping to next issue #7
```

### Q: Can I run multiple orchestrators in parallel?

**A:** Yes, each project has its own checkpoint:

```bash
# Project 1
cd ~/projects/api-project
/orchestrator "API idea"

# Project 2 (different directory)
cd ~/projects/web-app
/orchestrator "Web app idea"

# Each has separate docs/.orchestrator-state.json
```

### Q: Does context budget reset on resume?

**A:** Yes! New session = fresh 200K tokens:

```bash
# Day 1
Context: 85% (170K used)
exit

# Day 2
/resume
Context: 0% (fresh 200K budget)
```

Checkpoint tracks **cumulative** usage for metrics, but each session starts fresh.

## Related Documentation

- [CLAUDE.md](../.claude/CLAUDE.md) - Orchestrator workflow
- [README.md](../README.md) - Setup and usage
- `/resume` skill - Resume from checkpoint
- `/checkpoint` skill - Manual checkpoint save
- `/status` skill - Show checkpoint status

## Summary

Resumability transforms the orchestrator from a single-session tool into a **persistent autonomous system**:

✅ **Automatic Checkpointing** - No manual saves needed
✅ **Multi-Session Support** - Stop and resume across days
✅ **Context Protection** - Prevents limit-related failures
✅ **State Verification** - Syncs with GitHub for accuracy
✅ **Phase Preservation** - Resumes at exact point
✅ **Verification Loop** - Maintains attempt counter
✅ **Crash Recovery** - Recovers from interruptions

**Start building, stop anytime, resume anywhere.**
