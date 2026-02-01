---
name: reflect
description: Trigger post-project learning and retrospective analysis
---

# /reflect - Project Retrospective

Triggers the learning orchestrator to analyze the completed project and extract actionable insights.

## Usage

```bash
# Automatic (after project completion)
# The /orchestrator command automatically calls this if auto_learn is enabled

# Manual (for existing projects)
/reflect
/reflect --project-id <id>
```

## What It Does

1. **Launches learning-orchestrator agent** to analyze:
   - Project metrics (autonomy score, coverage, verification loops)
   - Complexity score accuracy
   - Time budget performance
   - Agent effectiveness
   - Pattern opportunities
   - Anti-pattern detection

2. **Generates reports:**
   - `docs/LEARNING-REPORT.md` - Comprehensive retrospective
   - `.claude/knowledge/patterns/*.md` - Extracted patterns (if any)
   - `.claude/knowledge/anti-patterns/*.md` - Detected anti-patterns (if any)

3. **Updates knowledge base:**
   - Stores project metrics in SQLite database
   - Updates pattern library index
   - Records learning insights

## Prerequisites

- ✅ Project must be completed (all phases done)
- ✅ `docs/METRICS.md` must exist
- ✅ `docs/COMPLETION-REPORT.md` must exist
- ✅ SQLite knowledge base must be initialized

## Example Output

```markdown
📊 Analyzing project: "Todo API with JWT auth"

✅ Autonomy score: 92%
✅ Test coverage: 85%
✅ Verification loops: 1 (clean)
⚠️ Phase 3 exceeded budget by 25%

📚 Patterns extracted:
  - JWT Authentication Pattern (auth-jwt-pattern-001)
  - REST CRUD Pattern (rest-crud-pattern-002)

🚫 Anti-patterns found: 0

📈 Recommendations:
  - Increase Phase 3 budget from 4h to 5h
  - Complexity thresholds accurate (no change needed)

📄 Full report: docs/LEARNING-REPORT.md

Knowledge base updated:
  - Projects: 1 record added
  - Issues: 8 records added
  - Patterns: 2 added to library
  - Learnings: 5 insights recorded
```

## When to Use

### Automatic Mode (Recommended)

If `auto_learn: true` in plugin settings, learning happens automatically after Phase 5 (Verification) completes successfully.

**Workflow:**
```
Phase 5: Verification ✅
  ↓
Phase 6: Learning (automatic)
  ↓
LEARNING-REPORT.md generated
  ↓
Project complete
```

### Manual Mode

Use `/reflect` when:
- Analyzing an old project retroactively
- Auto-learn was disabled
- Re-running analysis with updated agents
- Learning phase failed and needs retry

## Parameters

### --project-id

Specify which project to analyze (default: current directory's project).

```bash
/reflect --project-id abc123-def456-789
```

Useful for:
- Batch analysis of historical projects
- Re-analyzing after pattern library updates
- Analyzing projects in other directories

## Configuration

Edit `.claude/plugins/learning.local.md`:

```yaml
---
auto_learn: true
pattern_extraction_threshold: 500
min_projects_for_optimization: 5
---

# Learning Plugin Settings

- **auto_learn:** Trigger learning phase automatically after project completion
- **pattern_extraction_threshold:** Minimum complexity score to extract as pattern
- **min_projects_for_optimization:** Minimum projects before running threshold optimization
```

## Troubleshooting

### "Insufficient data for learning"

**Cause:** Missing `docs/METRICS.md` or `docs/COMPLETION-REPORT.md`

**Fix:**
```bash
# Ensure project completed all phases
ls docs/METRICS.md docs/COMPLETION-REPORT.md

# If missing, project may not have completed properly
# Re-run orchestrator or manually generate metrics
```

### "Knowledge base not initialized"

**Cause:** SQLite database doesn't exist

**Fix:**
```bash
.claude/scripts/init-knowledge-base.sh
```

### "Pattern extraction failed"

**Cause:** No patterns met extraction criteria (complexity < 500, or not reusable)

**Note:** This is normal. Not all projects produce extractable patterns.

## Integration with Orchestrator

In `.claude/commands/orchestrator.md`, Phase 6 automatically calls:

```markdown
## Phase 6: Learning (if auto_learn enabled)

Delegate to `learning-orchestrator` agent:
1. Read project metrics and completion report
2. Extract patterns and anti-patterns
3. Generate learning report
4. Update knowledge base
5. Recommend threshold adjustments (if 5+ projects)

Output: docs/LEARNING-REPORT.md
```

## Success Criteria

After running `/reflect`:
- [ ] `docs/LEARNING-REPORT.md` exists and is complete
- [ ] Project record added to SQLite database
- [ ] Issue records added for all GitHub issues
- [ ] Patterns extracted (if applicable)
- [ ] Anti-patterns documented (if found)
- [ ] Pattern library index updated
- [ ] Actionable recommendations provided

## Related Skills

- `/patterns` - Search the pattern library
- `/optimize` - Run threshold optimization (requires 5+ projects)

---

**Note:** Learning is the key to continuous improvement. Every project makes the next one better.
