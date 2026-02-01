---
name: optimize
description: Run threshold optimization analysis on accumulated project data
---

# /optimize - Threshold Optimization

Analyzes accumulated project data to recommend evidence-based threshold adjustments.

## Usage

```bash
# Run full optimization analysis
/optimize

# Optimize specific threshold category
/optimize complexity
/optimize context
/optimize time
/optimize coverage

# Force optimization (bypass minimum project check)
/optimize --force
```

## What It Does

Launches the **threshold-optimizer** agent to perform statistical analysis on:

1. **Complexity Thresholds**
   - Simple/Medium/Complex boundaries
   - Split decision accuracy
   - Commit count distribution

2. **Context Budgets**
   - Green/Yellow/Red zone distribution
   - Overflow rate
   - Warning effectiveness

3. **Time Budgets**
   - Phase duration accuracy
   - Timeout rates
   - Budget variance

4. **Commit Limits**
   - Max files per commit
   - Max LOC per commit
   - Violation rates

5. **Coverage Thresholds**
   - 80% target appropriateness
   - Achievement rate by project type
   - Tiered threshold recommendations

## Prerequisites

- ✅ **Minimum 5 completed projects** (statistical significance)
- ✅ SQLite knowledge base initialized and populated
- ✅ Projects have complete metrics data

**If < 5 projects:**
```
⚠️ Insufficient data for optimization

Projects in database: 3
Required: 5

Continue collecting baseline data.
Next optimization available after 2 more projects.
```

## Output

Generates `docs/THRESHOLD-OPTIMIZATION-REPORT.md`:

```markdown
# Threshold Optimization Report

**Projects Analyzed:** 23
**Data Points:** 145 issues, 125 commits
**Confidence Level:** High

## Recommended Changes: 3

### 1. Complexity: Medium Upper Bound ⚠️
**Current:** 1500
**Recommended:** 1200
**Confidence:** High (78 data points)
**Impact:** Reduce 3-commit issues by 15%

**Reasoning:**
Issues scoring 1200-1500 consistently need 3 commits (42% rate).
Lowering threshold catches these earlier for better planning.

### 2. Time Budget: Phase 3 (Implementation) ⚠️
**Current:** 240 min (4 hours)
**Recommended:** 300 min (5 hours)
**Confidence:** High (23 projects)
**Impact:** Reduce timeout rate from 22% to <10%

**Reasoning:**
Consistent 30% overrun across projects.
Systematic underestimation of implementation time.

### 3. Coverage Threshold 📊
**Current:** 80% (all projects)
**Recommended:** Tiered by project type
  - APIs: 85%
  - CLIs: 80%
  - Frontend: 70%
  - Full-stack: 75%

**Confidence:** Medium (limited frontend data)
**Impact:** Match targets to project realities

**Reasoning:**
Frontend projects achieve only 68% avg coverage.
UI testing inherently harder than API testing.

## No Change Needed: 2

- Complexity: SIMPLE threshold (0-500) ✅
- Context budgets (performing well) ✅

[Full statistical analysis and charts...]
```

## Threshold Categories

### complexity

Analyze and optimize complexity score thresholds.

**Current Defaults:**
```
SIMPLE: 0 - 500
MEDIUM: 501 - 1500
COMPLEX: 1501+
```

**Metrics Analyzed:**
- Split rate by category
- Average context usage
- Commit count distribution
- Estimation accuracy

**Example Recommendation:**
```
MEDIUM upper bound: 1500 → 1200
Reason: 42% of 1200-1500 issues need 3 commits
Impact: Better planning, fewer surprises
```

### context

Analyze and optimize context budget thresholds.

**Current Defaults:**
```
GREEN: < 100K tokens (safe)
YELLOW: 100-150K tokens (warning)
RED: > 150K tokens (danger, overflow)
```

**Metrics Analyzed:**
- Distribution across zones
- Overflow rate (RED zone)
- Warning effectiveness (YELLOW zone)

**Example Recommendation:**
```
YELLOW threshold: 100K → 80K
Reason: Only 3% hit YELLOW, too few warnings
Impact: Earlier warnings, more proactive optimization
```

### time

Analyze and optimize phase time budgets.

**Current Defaults:**
```
Phase 0 (CI/CD): 15 min
Phase 1 (Product): 30 min
Phase 2 (Architecture): 45 min
Phase 3 (Implementation): 240 min (4 hours)
Phase 4 (QA): 30 min
Phase 5 (Verification): 15 min
```

**Metrics Analyzed:**
- Actual vs budgeted duration
- Timeout rate by phase
- Variance and standard deviation

**Example Recommendation:**
```
Phase 3: 240 min → 300 min
Reason: 22% timeout rate, consistent 30% overrun
Impact: Reduce timeouts, better expectations
```

### coverage

Analyze and optimize test coverage thresholds.

**Current Default:**
```
80% across all projects
```

**Metrics Analyzed:**
- Achievement rate overall
- Achievement rate by project type
- Average coverage by type

**Example Recommendation:**
```
Implement tiered thresholds:
- APIs: 85% (easily achievable)
- CLIs: 80% (baseline)
- Frontend: 70% (UI testing harder)
- Full-stack: 75% (compromise)

Reason: Project type significantly affects coverage
Impact: Realistic targets, less frustration
```

## Force Mode

Bypass the 5-project minimum requirement.

```bash
/optimize --force
```

**When to Use:**
- Testing threshold optimization logic
- Analyzing early trends (informational only)
- Debugging optimizer agent

**Warning:**
```
⚠️ Force mode enabled (3 projects)

Results are NOT statistically significant.
DO NOT apply recommendations.

This is for informational purposes only.
Minimum 5 projects required for reliable optimization.
```

## Statistical Methods

The optimizer uses rigorous statistical analysis:

### Confidence Levels

- **High:** 30+ data points, low variance (stddev < 15% of mean)
- **Medium:** 10-29 data points, moderate variance
- **Low:** 5-9 data points, or high variance (stddev > 25%)

### Outlier Removal

Uses IQR (Interquartile Range) method:
```
Q1 = 25th percentile
Q3 = 75th percentile
IQR = Q3 - Q1
Outliers: < Q1 - 1.5*IQR or > Q3 + 1.5*IQR
```

Outliers are removed before calculating averages to prevent skew.

### Sample Size Requirements

| Threshold | Minimum Data Points | Recommendation Confidence |
|-----------|---------------------|---------------------------|
| Complexity | 30 issues | High |
| Context | 30 issues | High |
| Time | 10 projects | Medium |
| Coverage | 15 projects | Medium |

## Approval Workflow

Threshold changes require **explicit user approval**:

```
📊 Optimization complete: 3 recommendations

Would you like to:
1. Review full report (docs/THRESHOLD-OPTIMIZATION-REPORT.md)
2. Apply all high-confidence recommendations
3. Apply specific recommendations
4. Reject all (keep current thresholds)

Selection:
```

**If approved:**
```
✅ Applying threshold changes...

Updated .claude/CLAUDE.md:
- Complexity: MEDIUM threshold: 1500 → 1200
- Time Budget: Phase 3: 240 min → 300 min

Changes recorded in threshold_evolution table.
Next optimization: After 10 more projects (total 33)
```

## Integration with /orchestrator

Threshold optimization is **not automatic**. It must be triggered manually or scheduled.

**Recommended Schedule:**
- After first 5 projects: Baseline optimization
- Every 10 projects thereafter: Incremental tuning
- After major changes to agents/workflow: Re-calibration

**Example Workflow:**
```bash
# Complete 5 projects
/orchestrator "Project 1"
/orchestrator "Project 2"
/orchestrator "Project 3"
/orchestrator "Project 4"
/orchestrator "Project 5"

# Run first optimization
/optimize

# Review report
cat docs/THRESHOLD-OPTIMIZATION-REPORT.md

# Apply changes (if approved)
# Thresholds are updated in .claude/CLAUDE.md

# Continue with improved thresholds
/orchestrator "Project 6"
...
```

## Tracking Threshold Evolution

All threshold changes are recorded in the database:

```sql
SELECT
  parameter_name,
  old_value,
  new_value,
  changed_at,
  reason,
  projects_analyzed,
  confidence_level
FROM threshold_evolution
ORDER BY changed_at DESC;
```

**Example History:**
```
| Parameter | Old | New | Date | Reason | Projects | Confidence |
|-----------|-----|-----|------|--------|----------|------------|
| complexity_medium_upper | 1500 | 1200 | 2026-01-31 | 42% 3-commit rate | 23 | 0.95 |
| time_phase3 | 240 | 300 | 2026-01-31 | 22% timeout rate | 23 | 0.92 |
| complexity_medium_upper | 1200 | 1100 | 2026-02-15 | 38% 3-commit rate | 33 | 0.88 |
```

This tracks the **evolutionary path** of thresholds over time.

## Troubleshooting

### "Insufficient projects"

**Cause:** < 5 projects in database

**Fix:**
```bash
# Check project count
sqlite3 .claude/knowledge/orchestrator.db "SELECT COUNT(*) FROM projects WHERE completed_at IS NOT NULL;"

# Complete more projects
/orchestrator "New project idea"

# Or use force mode (informational only)
/optimize --force
```

### "No recommendations"

**Cause:** All thresholds are performing optimally

**Output:**
```
✅ All thresholds performing well!

No adjustments recommended at this time.
Next optimization: After 10 more projects.

Current performance:
- Complexity: 96% accuracy
- Context: 0% overflow rate
- Time: 8% timeout rate (target < 10%)
- Coverage: 89% achievement rate
```

### "Database connection failed"

**Cause:** SQLite database not initialized or MCP not configured

**Fix:**
```bash
# Initialize database
.claude/scripts/init-knowledge-base.sh

# Check MCP configuration
cat .claude/.mcp.json

# Test SQLite connection
sqlite3 .claude/knowledge/orchestrator.db "SELECT sqlite_version();"
```

## Success Criteria

After running `/optimize`:
- [ ] Statistical analysis performed on all thresholds
- [ ] Report generated with recommendations
- [ ] Confidence levels reported for each recommendation
- [ ] Expected impact quantified
- [ ] Threshold changes tracked in database (if approved)

## Related Skills

- `/reflect` - Collect project data for optimization
- `/patterns` - Pattern library affects complexity estimates

---

**Remember:** Optimization is continuous. Every batch of projects refines the system further.
