#!/bin/bash

# checkpoint.sh - Orchestrator State Management Functions
# Provides checkpoint persistence for resumable orchestrator execution

set -euo pipefail

CHECKPOINT_FILE="docs/.orchestrator-state.json"
CHECKPOINT_TEMPLATE=".claude/../docs/.orchestrator-state.template.json"

# Initialize a new checkpoint file for a project
# Usage: initialize_checkpoint "project-name" "project idea description"
initialize_checkpoint() {
  local project_name="$1"
  local project_idea="$2"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Ensure docs directory exists
  mkdir -p docs

  # Copy template and populate with initial values
  if [ -f "$CHECKPOINT_TEMPLATE" ]; then
    cp "$CHECKPOINT_TEMPLATE" "$CHECKPOINT_FILE"
  else
    # Fallback: create from scratch
    cat > "$CHECKPOINT_FILE" <<EOF
{
  "version": "1.0",
  "project": {
    "name": "",
    "idea": "",
    "started_at": "",
    "last_updated": ""
  },
  "phase": {
    "current": 0,
    "name": "Infrastructure Setup",
    "started_at": "",
    "last_checkpoint": "",
    "status": "not_started"
  },
  "phases_completed": [],
  "work_progress": {
    "total_issues": 0,
    "completed_issues": [],
    "in_progress_issue": null,
    "open_issues": [],
    "bug_issues": [],
    "last_closed_at": null
  },
  "context_tracking": {
    "total_budget": 200000,
    "used": 0,
    "percentage": 0,
    "last_issue_context": 0,
    "approaching_limit": false
  },
  "verification": {
    "loop_count": 0,
    "max_loops": 3,
    "last_attempt_at": null,
    "failures": []
  },
  "agents_invoked": [],
  "artifacts_created": [],
  "resume_instructions": "Project initialization - no work started yet"
}
EOF
  fi

  # Populate project metadata
  jq \
    --arg name "$project_name" \
    --arg idea "$project_idea" \
    --arg timestamp "$timestamp" \
    '.project.name = $name |
     .project.idea = $idea |
     .project.started_at = $timestamp |
     .project.last_updated = $timestamp |
     .phase.started_at = $timestamp |
     .phase.last_checkpoint = $timestamp' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "✅ Checkpoint initialized for project: $project_name"
}

# Update a specific field in the checkpoint
# Usage: update_checkpoint "key.path" "value"
update_checkpoint() {
  local key_path="$1"
  local value="$2"

  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found at $CHECKPOINT_FILE"
    return 1
  fi

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Handle different value types
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    # Numeric value
    jq \
      --arg timestamp "$timestamp" \
      "setpath([\"${key_path//./\",\"}\"] | split(\",\"); ${value}) | .project.last_updated = \$timestamp" \
      "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"
  elif [ "$value" = "null" ]; then
    # Null value
    jq \
      --arg timestamp "$timestamp" \
      "setpath([\"${key_path//./\",\"}\"] | split(\",\"); null) | .project.last_updated = \$timestamp" \
      "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"
  else
    # String value
    jq \
      --arg val "$value" \
      --arg timestamp "$timestamp" \
      "setpath([\"${key_path//./\",\"}\"] | split(\",\"); \$val) | .project.last_updated = \$timestamp" \
      "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"
  fi

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "💾 Checkpoint updated: $key_path = $value"
}

# Mark a phase as complete and advance to next phase
# Usage: checkpoint_phase_complete 1 "Product Definition"
checkpoint_phase_complete() {
  local phase_num=$1
  local phase_name="$2"
  local next_phase=$((phase_num + 1))

  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found"
    return 1
  fi

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Determine next phase name
  local next_phase_name
  case $next_phase in
    0) next_phase_name="Infrastructure Setup" ;;
    1) next_phase_name="Product Definition" ;;
    2) next_phase_name="Architecture & Design" ;;
    3) next_phase_name="Implementation" ;;
    4) next_phase_name="Quality Assurance" ;;
    5) next_phase_name="Verification Loop" ;;
    6) next_phase_name="Learning & Evolution" ;;
    7) next_phase_name="Complete" ;;
    *) next_phase_name="Unknown" ;;
  esac

  jq \
    --arg phase "$phase_num" \
    --arg next "$next_phase" \
    --arg next_name "$next_phase_name" \
    --arg timestamp "$timestamp" \
    '.phases_completed += [$phase | tonumber] |
     .phase.current = ($next | tonumber) |
     .phase.name = $next_name |
     .phase.started_at = $timestamp |
     .phase.last_checkpoint = $timestamp |
     .phase.status = "in_progress" |
     .project.last_updated = $timestamp' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "✅ Phase $phase_num ($phase_name) marked complete"
  echo "▶️  Advanced to Phase $next_phase ($next_phase_name)"
}

# Track context usage for an operation
# Usage: track_context_usage 5 12000
track_context_usage() {
  local issue_num=${1:-0}
  local tokens_used=${2:-0}

  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found"
    return 1
  fi

  # Read current usage
  local current_used=$(jq -r '.context_tracking.used' "$CHECKPOINT_FILE")
  local total_budget=$(jq -r '.context_tracking.total_budget' "$CHECKPOINT_FILE")

  # Calculate new usage
  local new_total=$((current_used + tokens_used))
  local percentage=$((new_total * 100 / total_budget))
  local approaching_limit="false"

  if [ $percentage -gt 75 ]; then
    approaching_limit="true"
  fi

  # Update checkpoint
  jq \
    --arg used "$new_total" \
    --arg pct "$percentage" \
    --arg issue_ctx "$tokens_used" \
    --arg approaching "$approaching_limit" \
    '.context_tracking.used = ($used | tonumber) |
     .context_tracking.percentage = ($pct | tonumber) |
     .context_tracking.last_issue_context = ($issue_ctx | tonumber) |
     .context_tracking.approaching_limit = ($approaching == "true")' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  if [ "$approaching_limit" = "true" ]; then
    echo "⚠️  Context usage: ${percentage}% - approaching limit!"
    echo "💡 Consider closing current session and resuming tomorrow"
  else
    echo "📊 Context usage: ${percentage}%"
  fi
}

# Record agent invocation
# Usage: record_agent_invocation "developer" 3 5 "in_progress"
record_agent_invocation() {
  local agent_name="$1"
  local phase_num="$2"
  local issue_num="${3:-null}"
  local status="${4:-completed}"

  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found"
    return 1
  fi

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Create agent record
  local agent_record
  if [ "$issue_num" = "null" ]; then
    agent_record=$(jq -n \
      --arg agent "$agent_name" \
      --arg phase "$phase_num" \
      --arg status "$status" \
      --arg timestamp "$timestamp" \
      '{
        agent: $agent,
        phase: ($phase | tonumber),
        status: $status,
        started_at: $timestamp
      }')
  else
    agent_record=$(jq -n \
      --arg agent "$agent_name" \
      --arg phase "$phase_num" \
      --arg issue "$issue_num" \
      --arg status "$status" \
      --arg timestamp "$timestamp" \
      '{
        agent: $agent,
        phase: ($phase | tonumber),
        issue: ($issue | tonumber),
        status: $status,
        started_at: $timestamp
      }')
  fi

  # Append to agents_invoked array
  jq \
    --argjson record "$agent_record" \
    '.agents_invoked += [$record]' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "📝 Recorded agent invocation: $agent_name (Phase $phase_num)"
}

# Complete an agent invocation
# Usage: complete_agent_invocation "developer" "completed"
complete_agent_invocation() {
  local agent_name="$1"
  local status="${2:-completed}"

  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found"
    return 1
  fi

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Update the last matching agent invocation
  jq \
    --arg agent "$agent_name" \
    --arg status "$status" \
    --arg timestamp "$timestamp" \
    '(.agents_invoked[] | select(.agent == $agent and .status == "in_progress") | .status) = $status |
     (.agents_invoked[] | select(.agent == $agent and .status == $status) | .completed_at) = $timestamp' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "✅ Agent completed: $agent_name ($status)"
}

# Update work progress (issues)
# Usage: update_work_progress
update_work_progress() {
  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found"
    return 1
  fi

  # Query GitHub for actual state
  local open_features=$(gh issue list --state open --label "feature" --json number --jq '.[].number' | tr '\n' ',' | sed 's/,$//')
  local open_bugs=$(gh issue list --state open --label "bug" --json number --jq '.[].number' | tr '\n' ',' | sed 's/,$//')
  local closed_issues=$(gh issue list --state closed --json number --jq '.[].number' | tr '\n' ',' | sed 's/,$//')
  local total_issues=$(gh issue list --json number --jq '. | length')

  # Convert to JSON arrays
  local open_features_array="[]"
  if [ -n "$open_features" ]; then
    open_features_array="[${open_features}]"
  fi

  local open_bugs_array="[]"
  if [ -n "$open_bugs" ]; then
    open_bugs_array="[${open_bugs}]"
  fi

  local closed_issues_array="[]"
  if [ -n "$closed_issues" ]; then
    closed_issues_array="[${closed_issues}]"
  fi

  # Combine open features and bugs
  local all_open=$(echo "$open_features_array" "$open_bugs_array" | jq -s 'add | unique | sort')

  # Update checkpoint
  jq \
    --argjson total "$total_issues" \
    --argjson completed "$closed_issues_array" \
    --argjson open "$all_open" \
    --argjson bugs "$open_bugs_array" \
    '.work_progress.total_issues = $total |
     .work_progress.completed_issues = $completed |
     .work_progress.open_issues = $open |
     .work_progress.bug_issues = $bugs' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "📋 Work progress updated: $total_issues total, ${#closed_issues[@]} completed"
}

# Set in-progress issue
# Usage: set_in_progress_issue 5
set_in_progress_issue() {
  local issue_num="$1"

  update_checkpoint "work_progress.in_progress_issue" "$issue_num"
}

# Clear in-progress issue
# Usage: clear_in_progress_issue
clear_in_progress_issue() {
  update_checkpoint "work_progress.in_progress_issue" "null"
}

# Record artifact creation
# Usage: record_artifact "docs/PRD.md"
record_artifact() {
  local artifact_path="$1"

  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found"
    return 1
  fi

  jq \
    --arg artifact "$artifact_path" \
    '.artifacts_created += [$artifact] | .artifacts_created |= unique' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "📄 Artifact recorded: $artifact_path"
}

# Update resume instructions
# Usage: update_resume_instructions "Resume at Phase 3, issue #5 (User Authentication)"
update_resume_instructions() {
  local instructions="$1"

  update_checkpoint "resume_instructions" "$instructions"
}

# Increment verification loop counter
# Usage: increment_verification_loop
increment_verification_loop() {
  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found"
    return 1
  fi

  local current_count=$(jq -r '.verification.loop_count' "$CHECKPOINT_FILE")
  local new_count=$((current_count + 1))
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  jq \
    --arg count "$new_count" \
    --arg timestamp "$timestamp" \
    '.verification.loop_count = ($count | tonumber) |
     .verification.last_attempt_at = $timestamp' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "🔄 Verification loop count: $new_count"
}

# Add verification failure
# Usage: add_verification_failure "Tests failed: 3 errors in auth.test.ts"
add_verification_failure() {
  local failure_message="$1"

  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found"
    return 1
  fi

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  jq \
    --arg message "$failure_message" \
    --arg timestamp "$timestamp" \
    '.verification.failures += [{message: $message, timestamp: $timestamp}]' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "❌ Verification failure recorded: $failure_message"
}

# Reset verification loop (on success)
# Usage: reset_verification_loop
reset_verification_loop() {
  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Error: Checkpoint file not found"
    return 1
  fi

  jq \
    '.verification.loop_count = 0 |
     .verification.failures = []' \
    "$CHECKPOINT_FILE" > "${CHECKPOINT_FILE}.tmp"

  mv "${CHECKPOINT_FILE}.tmp" "$CHECKPOINT_FILE"

  echo "✅ Verification loop reset (success)"
}

# Display checkpoint status
# Usage: show_checkpoint_status
show_checkpoint_status() {
  if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ No checkpoint found"
    return 1
  fi

  local project_name=$(jq -r '.project.name' "$CHECKPOINT_FILE")
  local last_updated=$(jq -r '.project.last_updated' "$CHECKPOINT_FILE")
  local phase_name=$(jq -r '.phase.name' "$CHECKPOINT_FILE")
  local phase_num=$(jq -r '.phase.current' "$CHECKPOINT_FILE")
  local completed_count=$(jq -r '.work_progress.completed_issues | length' "$CHECKPOINT_FILE")
  local total_count=$(jq -r '.work_progress.total_issues' "$CHECKPOINT_FILE")
  local context_pct=$(jq -r '.context_tracking.percentage' "$CHECKPOINT_FILE")
  local in_progress=$(jq -r '.work_progress.in_progress_issue' "$CHECKPOINT_FILE")
  local resume_hint=$(jq -r '.resume_instructions' "$CHECKPOINT_FILE")

  echo ""
  echo "🔄 Orchestrator Checkpoint Found"
  echo ""
  echo "Project: $project_name"
  echo "Last Updated: $last_updated"
  echo ""
  echo "📍 Current Phase: $phase_num ($phase_name)"
  echo "✅ Completed: $completed_count/$total_count issues"
  if [ "$in_progress" != "null" ]; then
    echo "🔄 In-Progress: Issue #$in_progress"
  fi
  echo "📊 Context Used: ${context_pct}%"
  echo ""
  echo "💡 $resume_hint"
  echo ""
}

# Export functions for use in other scripts
export -f initialize_checkpoint
export -f update_checkpoint
export -f checkpoint_phase_complete
export -f track_context_usage
export -f record_agent_invocation
export -f complete_agent_invocation
export -f update_work_progress
export -f set_in_progress_issue
export -f clear_in_progress_issue
export -f record_artifact
export -f update_resume_instructions
export -f increment_verification_loop
export -f add_verification_failure
export -f reset_verification_loop
export -f show_checkpoint_status
