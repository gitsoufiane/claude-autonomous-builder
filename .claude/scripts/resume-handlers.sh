#!/bin/bash

# resume-handlers.sh - Phase-Specific Resume Logic
# Handles resuming orchestrator execution from checkpoints

set -euo pipefail

CHECKPOINT_FILE="docs/.orchestrator-state.json"

# Source checkpoint functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/checkpoint.sh"

# Verify checkpoint accuracy against GitHub state
# Returns 0 if in sync, 1 if diverged
verify_checkpoint_accuracy() {
  echo "🔍 Verifying checkpoint against GitHub state..."

  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ No checkpoint file found"
    return 1
  fi

  # Get checkpoint state
  local checkpoint_completed=$(jq -r '.work_progress.completed_issues[]' "$CHECKPOINT_FILE" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
  local checkpoint_open=$(jq -r '.work_progress.open_issues[]' "$CHECKPOINT_FILE" 2>/dev/null | tr '\n' ',' | sed 's/,$//')

  # Get GitHub state
  local github_closed=$(gh issue list --state closed --json number --jq '.[].number' 2>/dev/null | tr '\n' ',' | sed 's/,$//' || echo "")
  local github_open=$(gh issue list --state open --json number --jq '.[].number' 2>/dev/null | tr '\n' ',' | sed 's/,$//' || echo "")

  # Check for divergence
  local diverged=0

  if [ "$checkpoint_completed" != "$github_closed" ]; then
    echo "⚠️  Checkpoint/GitHub mismatch in completed issues"
    echo "   Checkpoint: [$checkpoint_completed]"
    echo "   GitHub: [$github_closed]"
    diverged=1
  fi

  if [ "$checkpoint_open" != "$github_open" ]; then
    echo "⚠️  Checkpoint/GitHub mismatch in open issues"
    echo "   Checkpoint: [$checkpoint_open]"
    echo "   GitHub: [$github_open]"
    diverged=1
  fi

  if [ $diverged -eq 1 ]; then
    echo "🔄 Syncing checkpoint with GitHub..."
    sync_github_state
    echo "✅ Checkpoint synchronized"
  else
    echo "✅ Checkpoint in sync with GitHub"
  fi

  return 0
}

# Sync checkpoint with GitHub state
sync_github_state() {
  update_work_progress
}

# Resume from Phase 0: Infrastructure Setup
resume_phase_0() {
  echo "🏗️  Phase 0: Infrastructure Setup (Resuming)"
  echo ""

  # Check what artifacts exist
  local has_ci=0
  local has_hooks=0
  local has_test_config=0

  [ -f ".github/workflows/ci.yml" ] && has_ci=1
  [ -f ".husky/pre-commit" ] && has_hooks=1
  [ -f "jest.config.js" ] || [ -f "vitest.config.ts" ] && has_test_config=1

  echo "Existing infrastructure:"
  [ $has_ci -eq 1 ] && echo "✅ GitHub Actions CI" || echo "❌ GitHub Actions CI"
  [ $has_hooks -eq 1 ] && echo "✅ Pre-commit hooks" || echo "❌ Pre-commit hooks"
  [ $has_test_config -eq 1 ] && echo "✅ Test configuration" || echo "❌ Test configuration"
  echo ""

  # If all complete, advance to Phase 1
  if [ $has_ci -eq 1 ] && [ $has_hooks -eq 1 ] && [ $has_test_config -eq 1 ]; then
    echo "✅ Infrastructure setup appears complete"
    echo "▶️  Advancing to Phase 1"
    checkpoint_phase_complete 0 "Infrastructure Setup"
    return 0
  fi

  echo "▶️  Re-running Phase 0 infrastructure setup"
  update_resume_instructions "Resume at Phase 0 - Infrastructure setup incomplete"
  return 1
}

# Resume from Phase 1: Product Definition
resume_phase_1() {
  echo "📋 Phase 1: Product Definition (Resuming)"
  echo ""

  # Check for PRD
  if [ ! -f "docs/PRD.md" ]; then
    echo "❌ PRD not found - restarting Phase 1"
    update_resume_instructions "Resume at Phase 1 - PRD creation"
    return 1
  fi

  echo "✅ PRD found: docs/PRD.md"

  # Check for GitHub issues
  local issue_count=$(gh issue list --json number --jq '. | length' 2>/dev/null || echo "0")

  if [ "$issue_count" -eq 0 ]; then
    echo "❌ No GitHub issues found - need to create feature issues"
    update_resume_instructions "Resume at Phase 1 - GitHub issue creation"
    return 1
  fi

  echo "✅ GitHub issues found: $issue_count total"

  # Check for complexity analysis
  local analyzed_count=$(gh issue list --json labels --jq '[.[] | select(.labels[]? | .name | startswith("complexity:"))] | length' 2>/dev/null || echo "0")

  if [ "$analyzed_count" -eq 0 ]; then
    echo "⚠️  No complexity analysis found - may need to run Phase 1.5"
    update_resume_instructions "Resume at Phase 1.5 - Complexity analysis"
    return 1
  fi

  echo "✅ Phase 1 complete - advancing to Phase 2"
  checkpoint_phase_complete 1 "Product Definition"
  return 0
}

# Resume from Phase 2: Architecture & Design
resume_phase_2() {
  echo "🏛️  Phase 2: Architecture & Design (Resuming)"
  echo ""

  # Check for architecture document
  if [ ! -f "docs/ARCHITECTURE.md" ]; then
    echo "❌ Architecture document not found - restarting Phase 2"
    update_resume_instructions "Resume at Phase 2 - Architecture design"
    return 1
  fi

  echo "✅ Architecture found: docs/ARCHITECTURE.md"

  # Check for project structure (package.json or equivalent)
  if [ ! -f "package.json" ] && [ ! -f "Cargo.toml" ] && [ ! -f "pyproject.toml" ]; then
    echo "❌ Project structure not initialized - need to complete Phase 2"
    update_resume_instructions "Resume at Phase 2 - Project structure setup"
    return 1
  fi

  echo "✅ Project structure initialized"
  echo "✅ Phase 2 complete - advancing to Phase 3"
  checkpoint_phase_complete 2 "Architecture & Design"
  return 0
}

# Resume from Phase 3: Implementation
resume_phase_3() {
  echo "💻 Phase 3: Implementation (Resuming)"
  echo ""

  # Verify checkpoint accuracy
  verify_checkpoint_accuracy

  # Query GitHub for actual state
  local open_features=$(gh issue list --state open --label "feature" --json number,title --jq '.[] | "\(.number): \(.title)"' 2>/dev/null || echo "")
  local open_bugs=$(gh issue list --state open --label "bug" --json number,title --jq '.[] | "\(.number): \(.title)"' 2>/dev/null || echo "")

  # Read checkpoint
  local in_progress=$(jq -r '.work_progress.in_progress_issue' "$CHECKPOINT_FILE")
  local completed=$(jq -r '.work_progress.completed_issues[]' "$CHECKPOINT_FILE" 2>/dev/null | tr '\n' ',' | sed 's/,$//' || echo "")

  echo "Completed issues: [$completed]"
  echo ""

  # Check in-progress issue status
  if [ "$in_progress" != "null" ]; then
    local issue_state=$(gh issue view "$in_progress" --json state --jq '.state' 2>/dev/null || echo "UNKNOWN")

    if [ "$issue_state" = "CLOSED" ]; then
      echo "✅ Issue #$in_progress was completed since last checkpoint"
      clear_in_progress_issue
      in_progress="null"
    else
      echo "🔄 Issue #$in_progress still open - resuming here"
      local issue_title=$(gh issue view "$in_progress" --json title --jq '.title' 2>/dev/null || echo "Unknown")
      echo "   Title: $issue_title"
      update_resume_instructions "Resume at Phase 3, issue #$in_progress ($issue_title)"
      return 1  # Return control to run this issue
    fi
  fi

  # Find next open feature issue
  local next_feature=$(echo "$open_features" | head -n1 | cut -d: -f1 || echo "")

  if [ -n "$next_feature" ]; then
    echo "▶️  Next feature issue: #$next_feature"
    local next_title=$(gh issue view "$next_feature" --json title --jq '.title' 2>/dev/null || echo "Unknown")
    set_in_progress_issue "$next_feature"
    update_resume_instructions "Resume at Phase 3, issue #$next_feature ($next_title)"
    return 1  # Return control to run this issue
  fi

  echo "✅ All feature issues complete!"
  echo ""

  # Check for bugs
  if [ -n "$open_bugs" ]; then
    echo "🐛 Bug issues found:"
    echo "$open_bugs"
    echo ""
    local first_bug=$(echo "$open_bugs" | head -n1 | cut -d: -f1)
    echo "▶️  Resuming bug fixing at issue #$first_bug"
    set_in_progress_issue "$first_bug"
    local bug_title=$(gh issue view "$first_bug" --json title --jq '.title' 2>/dev/null || echo "Unknown")
    update_resume_instructions "Resume at Phase 3 bug fixing, issue #$first_bug ($bug_title)"
    return 1
  fi

  echo "✅ No bugs found - Phase 3 complete"
  echo "▶️  Advancing to Phase 4"
  checkpoint_phase_complete 3 "Implementation"
  return 0
}

# Resume from Phase 4: Quality Assurance
resume_phase_4() {
  echo "🧪 Phase 4: Quality Assurance (Resuming)"
  echo ""

  # Check if QA report exists
  if [ -f "docs/QA-REPORT.md" ]; then
    echo "✅ QA report found: docs/QA-REPORT.md"

    # Check for open bugs (means QA found issues)
    local open_bugs=$(gh issue list --state open --label "bug" --json number --jq '. | length' 2>/dev/null || echo "0")

    if [ "$open_bugs" -gt 0 ]; then
      echo "🐛 $open_bugs bug issues found - returning to Phase 3"
      update_resume_instructions "Resume at Phase 3 - Bug fixes required from QA"
      update_checkpoint "phase.current" 3
      update_checkpoint "phase.name" "Implementation"
      return 1
    fi

    echo "✅ No bugs found - advancing to Phase 5"
    checkpoint_phase_complete 4 "Quality Assurance"
    return 0
  fi

  echo "⚠️  QA report not found - re-running Phase 4"
  update_resume_instructions "Resume at Phase 4 - QA testing"
  return 1
}

# Resume from Phase 5: Verification Loop
resume_phase_5() {
  echo "🔍 Phase 5: Verification Loop (Resuming)"
  echo ""

  # Read loop counter from checkpoint
  local loop_count=$(jq -r '.verification.loop_count' "$CHECKPOINT_FILE")
  local max_loops=$(jq -r '.verification.max_loops' "$CHECKPOINT_FILE")

  echo "🔄 Verification attempt: $loop_count of $max_loops"
  echo ""

  if [ "$loop_count" -ge "$max_loops" ]; then
    echo "🛑 Max verification loops reached"

    # Check for divergence report
    if [ -f "docs/DIVERGENCE-REPORT.md" ]; then
      echo "📄 Divergence report exists - manual intervention required"
      echo ""
      echo "Please review docs/DIVERGENCE-REPORT.md and provide guidance."
      return 1
    else
      echo "📝 Creating divergence report..."
      update_resume_instructions "Resume at Phase 5 - Divergence detected, awaiting user guidance"
      return 1
    fi
  fi

  echo "▶️  Re-running verification checks"
  update_resume_instructions "Resume at Phase 5 - Verification attempt $((loop_count + 1))"
  return 1
}

# Resume from Phase 6: Learning & Evolution
resume_phase_6() {
  echo "🧠 Phase 6: Learning & Evolution (Resuming)"
  echo ""

  # Check for learning report
  if [ -f "docs/LEARNING-REPORT.md" ]; then
    echo "✅ Learning report found: docs/LEARNING-REPORT.md"
    echo "✅ Project complete!"
    update_checkpoint "phase.status" "complete"
    return 0
  fi

  echo "⚠️  Learning report not found - re-running Phase 6"
  update_resume_instructions "Resume at Phase 6 - Learning retrospective"
  return 1
}

# Main resume router
resume_from_checkpoint() {
  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ No checkpoint found at $CHECKPOINT_FILE"
    return 1
  fi

  # Show checkpoint status
  show_checkpoint_status

  # Get current phase
  local current_phase=$(jq -r '.phase.current' "$CHECKPOINT_FILE")

  # Route to appropriate resume handler
  case $current_phase in
    0)
      resume_phase_0
      return $?
      ;;
    1)
      resume_phase_1
      return $?
      ;;
    2)
      resume_phase_2
      return $?
      ;;
    3)
      resume_phase_3
      return $?
      ;;
    4)
      resume_phase_4
      return $?
      ;;
    5)
      resume_phase_5
      return $?
      ;;
    6)
      resume_phase_6
      return $?
      ;;
    *)
      echo "❌ Unknown phase: $current_phase"
      return 1
      ;;
  esac
}

# Export functions
export -f verify_checkpoint_accuracy
export -f sync_github_state
export -f resume_phase_0
export -f resume_phase_1
export -f resume_phase_2
export -f resume_phase_3
export -f resume_phase_4
export -f resume_phase_5
export -f resume_phase_6
export -f resume_from_checkpoint
