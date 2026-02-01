---
name: orchestrator
description: Start the autonomous project orchestrator with a project idea
---

# Orchestrator Command

You have been given a project idea to build autonomously. Follow the workflow defined in CLAUDE.md precisely.

## Resumability Check (FIRST STEP)

**Before starting, ALWAYS check for existing checkpoint:**

1. Check if `docs/.orchestrator-state.json` exists
2. If exists:
   - Source checkpoint functions: `source .claude/scripts/checkpoint.sh`
   - Show status: `show_checkpoint_status`
   - Use AskUserQuestion to ask: "Resume existing project or start fresh?"
   - If "Resume": Call `resume_from_checkpoint` (from `.claude/scripts/resume-handlers.sh`)
   - If "Start fresh": Confirm deletion, then `rm docs/.orchestrator-state.json`
3. If not exists: Initialize new checkpoint with `initialize_checkpoint`

**Checkpoint Management Throughout:**
- Call `checkpoint_phase_complete` after each phase
- Call `update_work_progress` after closing issues
- Call `track_context_usage` to monitor token budget
- Call `update_resume_instructions` with helpful hints
- Warn at 75% context usage

**Scripts Location:**
- `.claude/scripts/checkpoint.sh` - State management functions
- `.claude/scripts/resume-handlers.sh` - Phase resume logic

## Your Mission

Transform the user's idea into a fully working project with:
- Complete documentation (PRD, Architecture)
- All features tracked in GitHub Issues
- Production-quality implementation
- Comprehensive tests (80%+ coverage)
- All bugs found and fixed
- Verification passing

**All progress automatically checkpointed for resumability.**

## Execution Plan

### Phase 0: Infrastructure Setup (NEW)

**Before delegating:**
```bash
source .claude/scripts/checkpoint.sh
update_checkpoint "phase.current" 0
update_checkpoint "phase.name" "Infrastructure Setup"
update_checkpoint "phase.status" "in_progress"
```

Delegate to `cicd-orchestrator` agent:
> "Set up GitHub Actions workflows, pre-commit hooks, and test infrastructure for this project. Configure CI/CD automation with security scanning. DO NOT create deployment workflows."

Wait for completion. Verify:
- .github/workflows/ci.yml exists
- .github/workflows/security.yml exists
- .husky/pre-commit hook exists
- .husky/pre-push hook exists
- package.json has test/lint/typecheck scripts
- Jest/Playwright configs created (if applicable)

**After completion:**
```bash
record_artifact ".github/workflows/ci.yml"
record_artifact ".github/workflows/security.yml"
record_artifact ".husky/pre-commit"
checkpoint_phase_complete 0 "Infrastructure Setup"
```

**Critical:** This phase MUST complete before writing any code. Quality gates must exist from the start.

### Phase 1: Product Definition

**Before delegating:**
```bash
update_checkpoint "phase.current" 1
update_checkpoint "phase.name" "Product Definition"
update_resume_instructions "Starting Phase 1 - Product Definition"
```

Delegate to `product-manager` agent:
> "Analyze this project idea and create a comprehensive PRD. Break it down into features and create GitHub issues for each. The idea is: $ARGUMENTS"

Wait for completion. Verify:
- docs/PRD.md exists
- GitHub issues created with proper labels
- Milestone created

**After completion:**
```bash
record_artifact "docs/PRD.md"
update_work_progress  # Sync GitHub issues
checkpoint_phase_complete 1 "Product Definition"
```

### Phase 1.5: Complexity Analysis & Issue Decomposition (NEW - CRITICAL)

Delegate to `task-complexity-analyzer` agent:
> "Analyze complexity of all GitHub issues created by product-manager. For each issue:
> 1. Calculate complexity score (files × 100 + LOC + dependencies × 50)
> 2. Classify as SIMPLE (0-500), MEDIUM (501-1500), or COMPLEX (1501+)
> 3. Estimate context budget (tokens needed for implementation)
> 4. For COMPLEX issues (>1500), recommend splitting into sub-issues
> 5. Add complexity analysis comment to each GitHub issue
> Provide detailed recommendations for any issues requiring decomposition."

Wait for analyzer completion. Then delegate back to `product-manager`:
> "Process task-complexity-analyzer recommendations:
> 1. For COMPLEX issues (score > 1500): Close original, create sub-issues
> 2. For MEDIUM issues (score 501-1500): Add commit breakdown suggestions
> 3. For SIMPLE issues (score 0-500): Confirm single-commit approach
> 4. Update docs/PRD.md with complexity scores and dependency graph"

Verify:
- All issues have complexity scores in comments
- Complex issues (>1500) split into sub-issues with clear dependencies
- Medium issues have commit breakdown guidance
- PRD updated with "Feature Complexity Analysis" section
- No single issue exceeds 150K token estimate

**Why this matters:**
- Prevents mid-implementation context overflows
- Ensures each developer session fits in context window
- Guarantees atomic commits (1 issue = 1-3 commits max)
- Enables parallel work on independent sub-issues
- Provides early warning of implementation complexity

### Phase 2: Architecture

**Before delegating:**
```bash
update_checkpoint "phase.current" 2
update_checkpoint "phase.name" "Architecture & Design"
update_resume_instructions "Starting Phase 2 - Architecture Design"
```

Delegate to `architect` agent:
> "Read the PRD at docs/PRD.md and design the system architecture. Create the project structure, install dependencies, and document everything in docs/ARCHITECTURE.md. Add technical details to each GitHub issue."

Wait for completion. Verify:
- docs/ARCHITECTURE.md exists
- Project structure created
- package.json configured
- tsconfig.json configured

**After completion:**
```bash
record_artifact "docs/ARCHITECTURE.md"
checkpoint_phase_complete 2 "Architecture & Design"
```

### Phase 3: Implementation (ENHANCED)

**Before delegating:**
```bash
update_checkpoint "phase.current" 3
update_checkpoint "phase.name" "Implementation"
update_resume_instructions "Starting Phase 3 - Implementation"
```

Delegate to `developer` agent:
> "Implement all features from the GitHub issues. Work in priority order (high → medium → low). For each feature:
> 1. Set in-progress: set_in_progress_issue <issue_number>
> 2. Delegate to tdd-guide for test-driven development
> 3. Delegate to code-reviewer for quality/security checks
> 4. Delegate to security-reviewer if auth/API/data feature
> 5. Delegate to commit-manager for atomic commits
> 6. Close issue with commit reference
> 7. Update checkpoint: clear_in_progress_issue && update_work_progress
> Follow the enhanced workflow strictly. Monitor context usage with track_context_usage."

**After each issue closes:**
```bash
clear_in_progress_issue
update_work_progress
# Developer agent should call track_context_usage with tokens used
```

Wait for completion. Verify:
- All feature issues closed
- Tests exist for each feature (from TDD)
- All commits follow conventional format
- No CRITICAL/HIGH review issues remain
- No CRITICAL security issues remain

**After completion:**
```bash
checkpoint_phase_complete 3 "Implementation"
```

### Phase 4: Quality Assurance (ENHANCED)

**Before delegating:**
```bash
update_checkpoint "phase.current" 4
update_checkpoint "phase.name" "Quality Assurance"
update_resume_instructions "Starting Phase 4 - QA Testing"
```

Delegate to `qa-engineer` agent:
> "Run the full test suite and check coverage. Then:
> 1. Delegate to e2e-runner agent to generate and run E2E tests for all features
> 2. Delegate to security-reviewer agent for comprehensive security audit
> 3. Create GitHub issues for all bugs found, prioritized by severity
> Document all findings in docs/QA-REPORT.md."

Wait for completion. Review:
- Unit/integration test results
- Coverage percentage (must be ≥80%)
- E2E test results and report
- Security audit findings
- Bug issues created (if any)

**After completion:**
```bash
record_artifact "docs/QA-REPORT.md"
update_work_progress  # Sync new bug issues
checkpoint_phase_complete 4 "Quality Assurance"
```

### Phase 5: Bug Fixing (if needed)
If bugs were found, delegate to `developer` agent:
> "Fix all bugs in priority order (critical → high → medium → low). Close each bug issue when fixed."

### Phase 6: Verification Loop (ENHANCED)

**Before delegating:**
```bash
update_checkpoint "phase.current" 5
update_checkpoint "phase.name" "Verification Loop"
increment_verification_loop  # Increment counter before attempt
```

Delegate to `reviewer` agent:
> "Run the enhanced verification loop with self-healing and divergence detection:
> 1. Check all criteria (issues, tests, coverage, docs, security)
> 2. Try self-healing for flaky tests and coverage gaps
> 3. Read verification.loop_count from checkpoint (already incremented)
> 4. Generate metrics and reports
> If anything fails and loop < 3, report what needs fixing. If loop ≥ 3, create divergence report and HARD STOP."

**If verification passes (loop < 3):**
```bash
reset_verification_loop
record_artifact "docs/METRICS.md"
checkpoint_phase_complete 5 "Verification Loop"
update_checkpoint "phase.current" 6
update_checkpoint "phase.name" "Learning & Evolution"
```
- Generate completion report
- Generate metrics report (docs/METRICS.md)
- Calculate autonomy score
- Proceed to Phase 7 (Learning)

**If verification fails (loop < 3):**
```bash
add_verification_failure "Detailed failure message"
update_checkpoint "phase.current" 3  # Return to Phase 3
update_checkpoint "phase.name" "Implementation"
update_resume_instructions "Verification failed (loop X/3) - returning to bug fixes"
```
- Return to Phase 5 (developer) to fix issues
- Run Phase 6 again after fixes
- Repeat until all checks pass OR divergence

**If divergence detected (loop ≥ 3):**
```bash
add_verification_failure "Divergence: Max loops reached"
record_artifact "docs/DIVERGENCE-REPORT.md"
update_checkpoint "phase.status" "divergence"
update_resume_instructions "DIVERGENCE detected - manual intervention required"
```
- Create docs/DIVERGENCE-REPORT.md
- Analyze failure patterns
- Present options to user
- HARD STOP 🛑 - Require user approval to continue

## Important Notes

1. **Start with infrastructure (Phase 0)** - CI/CD must be set up first ✨NEW
2. **Be thorough** - Don't rush through phases
3. **Verify each phase** - Check outputs before moving on
4. **Delegate to specialized agents** - Use tdd-guide, code-reviewer, security-reviewer, commit-manager, e2e-runner ✨NEW
5. **Keep looping (max 3)** - Don't stop until verification passes OR divergence ✨NEW
6. **Use real GitHub** - Create actual issues, close them properly
7. **Quality over speed** - Write production-quality code
8. **Track metrics** - Update docs/METRICS.md throughout ✨NEW
9. **Watch for divergence** - HARD STOP after 3 failed verification attempts ✨NEW

## Enhanced Capabilities (NEW)

This autonomous builder now includes:
- ✅ **Atomic commits** - Conventional format, pre-commit validation
- ✅ **E2E testing** - Full Playwright automation
- ✅ **Code review** - Quality and security checks after each feature
- ✅ **Security scanning** - OWASP Top 10, secrets detection
- ✅ **Self-healing** - Quarantine flaky tests, document gaps
- ✅ **Divergence detection** - Prevents infinite loops
- ✅ **Metrics tracking** - Full observability into process
- ✅ **CI/CD automation** - GitHub Actions, pre-commit hooks

**Target Autonomy:** 90%+ for typical web projects

## Starting the Build

Begin by delegating to the product-manager with the user's idea.

The project idea to build is:

---

$ARGUMENTS
