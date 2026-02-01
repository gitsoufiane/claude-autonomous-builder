# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a **meta-project**: a configuration system for Claude Code that enables autonomous project building. It contains agents, commands, and workflows that allow Claude to independently build complete software projects from a single prompt.

## Core Architecture

### Multi-Agent System

The system operates through a 5-phase workflow, each handled by a specialized agent:

1. **product-manager** (Sonnet) - Analyzes ideas, creates PRD (`docs/PRD.md`), generates GitHub issues
2. **architect** (Opus) - Designs architecture (`docs/ARCHITECTURE.md`), creates project structure, defines technical specifications
3. **developer** - Implements features from GitHub issues in priority order with tests
4. **qa-engineer** - Runs test suite, checks coverage, performs security audit, creates bug issues
5. **reviewer** - Verification loop that enforces completion criteria and loops back to developer if issues found

### Critical Workflow Pattern

```
Product Manager → Architect → Developer → QA → Reviewer
                                   ↑              ↓
                                   └──── (if bugs/failures)
```

The reviewer creates a **verification loop**: if bugs exist or tests fail, control returns to the developer agent until all checks pass.

## Primary Command

### /orchestrator [idea]

Entry point for autonomous building. Located in `.claude/commands/orchestrator.md`.

**Usage:**
```bash
/orchestrator A task management API with JWT auth and WebSocket notifications
```

**What it does:**
1. Delegates through all 5 phases in sequence
2. Waits for each agent to complete before proceeding
3. Loops on verification failures until all criteria met
4. Produces production-ready code with 80%+ test coverage

## Agent Configuration

All agents defined in `.claude/agents/*.md` with YAML frontmatter:

```yaml
---
name: agent-name
description: Purpose
allowed_tools: [Read, Write, Edit, Bash, Glob, Grep]
model: sonnet|opus  # Model selection for cost/capability trade-off
---
```

Key design decision: **Architect uses Opus** for deeper reasoning on system design, while product-manager uses Sonnet for cost efficiency on more structured tasks.

## Completion Criteria (Enforced by Reviewer)

The project is considered complete only when ALL of these pass:

- All feature issues closed
- All bug issues closed
- Test suite passes (exit code 0)
- Code coverage ≥ 80%
- Documentation complete (README, ARCHITECTURE, API docs)
- No critical/high priority issues remain open

## GitHub Integration Pattern

All work tracking uses `gh` CLI:

```bash
# Create feature issue
gh issue create --title "[Feature] Name" --body "..." --label "feature,priority:high"

# Create bug issue (from QA phase)
gh issue create --title "[Bug] Name" --body "..." --label "bug,priority:critical"

# Close with evidence
gh issue close <number> --comment "Implemented in <commit-hash>"

# Check open bugs (reviewer uses this)
gh issue list --state open --label "bug"
```

## Typical Project Verification Commands

The reviewer and QA agents expect these commands to work:

```bash
npm test              # Must exit 0
npm run test:coverage # Must show ≥80%
npm run lint          # Code quality check
npm run typecheck     # TypeScript validation (if applicable)
```

## Key Design Patterns

### Phase Verification

Each phase must verify outputs before the next begins:
- Product Manager: Confirm `docs/PRD.md` and GitHub issues exist
- Architect: Confirm `docs/ARCHITECTURE.md` and project structure exists
- Developer: Confirm all feature issues closed with tests
- QA: Report coverage percentage and create bug issues
- Reviewer: Loop until all criteria pass

### Issue-Driven Development

Every piece of work must have a GitHub issue:
- Features created by product-manager
- Bugs created by qa-engineer
- Issues closed by developer with commit references
- Reviewer verifies by checking issue state

### Quality Gates

The system enforces quality through:
- Test coverage threshold (80%)
- Security audit via `npm audit`
- Type safety via `tsc --noEmit`
- All tests passing before completion

## Real-World Example

The [Periodic Table SPA](https://github.com/gitsoufiane/periodic-table-spa) was built entirely by this system:
- 206 passing tests, 87% coverage
- Complete documentation (PRD, Architecture, QA Report)
- Zero security vulnerabilities
- Built from single prompt

## Modifying This System

### Adding a New Agent

Create `.claude/agents/new-agent.md`:

```markdown
---
name: new-agent
description: What this agent does
allowed_tools: [Read, Write, Bash]
model: sonnet
---

# Agent Purpose
...
```

Then reference in `.claude/CLAUDE.md` workflow and `.claude/commands/orchestrator.md`.

### Changing Workflow

Edit `.claude/CLAUDE.md` to modify:
- Phase order
- Completion criteria
- Verification commands
- GitHub integration patterns

### Adding Commands

Create `.claude/commands/command-name.md` with frontmatter:

```yaml
---
name: command-name
description: Brief description
---
```

## Important: This is a Template

This repository is meant to be **copied into other projects** or **symlinked globally**:

```bash
# Copy to a specific project
cp -r .claude /path/to/project/

# Or symlink globally for all projects
ln -s $(pwd)/.claude ~/.claude-templates/autonomous-builder
```

Once in a project, `/orchestrator` will create that project's code in the working directory.
