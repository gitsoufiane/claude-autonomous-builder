# Claude Autonomous Project Builder

A complete autonomous development workflow for Claude Code that transforms project ideas into production-ready code through a multi-agent system.

## 🎯 What This Does

This configuration enables Claude to autonomously build complete software projects from a single prompt, handling:

- **Product Definition** - Creates PRDs and GitHub issues
- **Architecture Design** - Designs system architecture and project structure
- **Implementation** - Writes production-quality code with tests
- **Quality Assurance** - Runs tests, security audits, and finds bugs
- **Bug Fixing** - Automatically fixes issues and re-verifies
- **Documentation** - Generates comprehensive documentation
- **🆕 Self-Learning** - Continuously improves by learning from every project
- **🔄 Resumability** - Stop and resume work across days/weeks with full state preservation

## 🧠 Meta-Learning Architecture (NEW)

The orchestrator now includes a **self-learning system** that gets smarter with every project:

### Knowledge Base
- **SQLite Database** - Stores project metrics, patterns, and learnings across all projects
- **Pattern Library** - Reusable solution patterns extracted from successful implementations
- **Anti-Pattern Detection** - Automatically identifies and prevents common mistakes
- **Threshold Optimization** - Statistically tunes complexity, time, and context budgets

### Project-Specific Learning
```
Feature 1 → Complete → Learn
              ↓
Feature 2 → Uses Pattern from Feature 1 → Complete → Learn
              ↓
Feature 3 → Uses Patterns from Features 1 & 2 → Complete
```

**Impact Within a Project:**
- 📊 Pattern library builds as features are implemented
- 🎯 Learn from early features to improve later ones
- 📚 Project-specific best practices documented
- 🔍 Anti-patterns identified and prevented

**Note:** Each project has its own isolated knowledge base. Learnings accumulate within the project but do not transfer between projects.

See [LEARNING-SYSTEM-SUMMARY.md](LEARNING-SYSTEM-SUMMARY.md) for full details.

## 🔄 Resumability (NEW)

The orchestrator now supports **checkpoint-based resumability** for multi-session development:

### Key Features
- ✅ **Automatic Checkpointing** - State saved after every phase and issue
- ✅ **Multi-Session Support** - Stop and resume across days/weeks
- ✅ **Context Protection** - Warns at 75% token usage, prevents limit failures
- ✅ **State Verification** - Syncs checkpoint with GitHub for accuracy
- ✅ **Phase Preservation** - Resumes at exact point (issue-level granularity)
- ✅ **Verification Loop Counter** - Maintains attempt tracking across sessions

### Basic Usage

**Start a project:**
```bash
cd ~/projects/my-project
/orchestrator "A task management API with JWT auth"

# ... work for a few hours ...
# Context at 78% - save and resume tomorrow
exit
```

**Resume next day:**
```bash
cd ~/projects/my-project
/orchestrator  # Detects checkpoint, asks to resume

# Or use explicit resume skill:
/resume
```

**Check status:**
```bash
/status  # Shows phase, progress, context usage
```

### Skills
- `/resume` - Resume from checkpoint
- `/checkpoint` - Manual checkpoint save
- `/status` - Show checkpoint status

### How It Works
Every checkpoint includes:
- Current phase and sub-phase
- Completed and in-progress issues
- Context usage tracking (warns at 75%)
- Verification loop counter
- Agent invocation history
- Resume instructions

**Checkpoint file:** `docs/.orchestrator-state.json`

**See:** [docs/RESUMABILITY-GUIDE.md](docs/RESUMABILITY-GUIDE.md) for complete documentation.

## 🏗️ Architecture

The system uses specialized agents that work together in phases:

```
┌─────────────────────────────────────────────────┐
│  User Provides Project Idea                     │
└────────────────┬────────────────────────────────┘
                 │
        ┌────────▼────────┐
        │ Product Manager │ ─► PRD.md + GitHub Issues
        └────────┬────────┘
                 │
        ┌────────▼────────┐
        │   Architect     │ ─► ARCHITECTURE.md + Project Setup
        └────────┬────────┘
                 │
        ┌────────▼────────┐
        │   Developer     │ ─► Code + Tests
        └────────┬────────┘
                 │
        ┌────────▼────────┐
        │  QA Engineer    │ ─► Test Results + Bug Issues
        └────────┬────────┘
                 │
        ┌────────▼────────┐
        │    Reviewer     │ ─► Verification Loop
        └────────┬────────┘
                 │
        ┌────────▼────────┐  🆕 NEW
        │ Learning Agent  │ ─► Extract Patterns + Optimize
        └────────┬────────┘
                 │
        ┌────────▼────────┐
        │ ✅ Complete!     │
        │ (Smarter Next   │
        │  Time)          │
        └─────────────────┘
```

## 📁 Structure

```
.claude/
├── CLAUDE.md                      # Main workflow instructions
├── agents/
│   ├── product-manager.md         # Creates PRD and issues
│   ├── architect.md               # Designs architecture
│   ├── developer.md               # Implements features
│   ├── qa-engineer.md             # Tests and finds bugs
│   ├── reviewer.md                # Verifies completion
│   ├── learning-orchestrator.md   # 🆕 Post-project learning
│   ├── pattern-library.md         # 🆕 Pattern search & retrieval
│   └── threshold-optimizer.md     # 🆕 Statistical threshold tuning
├── commands/
│   └── orchestrator.md            # /orchestrator command
├── plugins/
│   ├── learning/                  # 🆕 Learning plugin
│   │   ├── plugin.json
│   │   └── skills/
│   │       ├── reflect.md         # /reflect skill
│   │       ├── patterns.md        # /patterns skill
│   │       └── optimize.md        # /optimize skill
│   └── orchestrator/              # 🔄 Resumability plugin
│       ├── plugin.json
│       └── skills/
│           ├── resume.md          # /resume skill
│           ├── checkpoint.md      # /checkpoint skill
│           └── status.md          # /status skill
├── knowledge/                     # 🆕 Knowledge base
│   ├── orchestrator.db            # SQLite database
│   ├── schema.sql                 # Database schema
│   ├── index.json                 # Pattern search index
│   ├── patterns/                  # Reusable patterns
│   │   └── auth-jwt.md
│   ├── anti-patterns/             # Known failure modes
│   │   └── hardcoded-secrets.md
│   └── README.md                  # Knowledge base docs
└── scripts/
    ├── init-knowledge-base.sh     # 🆕 Database initialization
    ├── checkpoint.sh              # 🔄 State management functions
    └── resume-handlers.sh         # 🔄 Phase resume logic
```

## 🚀 Getting Started

### One-Time Setup (Do This Once)

Clone or download this repository to use as a template:

```bash
git clone https://github.com/yourusername/claude-autonomous-builder.git
```

**Note:** Each project gets its own isolated `.claude` configuration and knowledge base. Projects do not share learnings.

### Per-Project Setup (Do This for Each New Project)

#### Setup Method: Copy to Project (Local Isolation)

Each project gets its own `.claude` configuration with an isolated knowledge base:

```bash
# In your new project directory
cd ~/my-new-project

# Copy the orchestrator configuration
cp -r /path/to/claude-autonomous-builder/.claude .

# Initialize project-specific knowledge base
.claude/scripts/init-knowledge-base.sh

# Verify it works
ls -la .claude/
```

**This approach ensures:**
- ✅ Complete project isolation
- ✅ No cross-contamination between projects
- ✅ Full control over project-specific configuration
- ✅ Can customize agents/workflow per project
- ✅ Project's learnings stay with the project

**Note:** The knowledge base (`.claude/knowledge/orchestrator.db`) learns only from the current project. Patterns and learnings do not transfer between projects.

### Using the Orchestrator

#### 1. Start a New Project

```bash
# Navigate to your project directory
cd ~/my-new-project

# Initialize git if not already
git init
git remote add origin https://github.com/yourusername/my-new-project.git

# Create a GitHub repository first (via gh CLI or web interface)
gh repo create my-new-project --public --source=. --remote=origin

# Start Claude Code in this directory
cd ~/my-new-project
# (Open in your IDE or run: code .)
```

#### 2. Run the Orchestrator

In Claude Code, simply type:

```bash
/orchestrator [Your complete project idea]
```

**Examples:**

**Backend API:**
```bash
/orchestrator A RESTful API for a task management system with:
- User authentication using JWT
- CRUD operations for tasks (create, read, update, delete)
- Task categories and tags
- Due date tracking
- Real-time notifications via WebSockets
- PostgreSQL database
- 80%+ test coverage
```

**Frontend App:**
```bash
/orchestrator A React e-commerce product catalog with:
- Product listing with search and filters
- Product detail pages
- Shopping cart functionality
- Responsive design with Tailwind CSS
- Integration with a mock API
- TypeScript and comprehensive tests
```

**Full-Stack:**
```bash
/orchestrator A full-stack blog platform using:
- Next.js 14 with App Router
- Markdown support for posts
- Author authentication
- Comment system
- PostgreSQL with Prisma ORM
- Deployed on Vercel
```

**CLI Tool:**
```bash
/orchestrator A Node.js CLI tool for database migrations with:
- Support for PostgreSQL and MySQL
- Up/down migrations
- Migration versioning
- Rollback support
- TypeScript
- Published to npm
```

#### 3. What Happens Next

The orchestrator will autonomously:

1. **Phase 0: CI/CD Setup** (15 min)
   - GitHub Actions workflows
   - Pre-commit hooks
   - Test infrastructure

2. **Phase 1: Product Definition** (30 min)
   - Creates `docs/PRD.md`
   - Breaks into GitHub issues
   - Sets up milestone

3. **Phase 2: Architecture** (45 min)
   - Creates `docs/ARCHITECTURE.md`
   - Sets up project structure
   - Defines data models

4. **Phase 3: Implementation** (4+ hours)
   - Implements all features with TDD
   - Writes comprehensive tests
   - Follows best practices

5. **Phase 4: QA** (30 min)
   - Runs test suite
   - Security audit
   - E2E testing

6. **Phase 5: Verification** (15 min)
   - Validates completion criteria
   - Self-healing if needed
   - Generates metrics

7. **Phase 6: Learning** (5 min) 🆕
   - Extracts patterns
   - Updates knowledge base
   - Generates learning report

**Total Time:** 6-10 hours (runs autonomously)

**💡 Can't finish in one session?** The orchestrator automatically saves checkpoints. You can safely stop at any time and resume later:

```bash
# Stop mid-execution (at 78% context)
⚠️  Context usage: 78% - approaching limit!
exit

# Resume next day - fresh context, same progress
cd ~/my-project
/orchestrator  # Detects checkpoint, asks to resume
# OR
/resume
```

#### 4. Review the Results

After completion:

```bash
# View the PRD
cat docs/PRD.md

# View architecture
cat docs/ARCHITECTURE.md

# View metrics
cat docs/METRICS.md

# View learning report
cat docs/LEARNING-REPORT.md

# Run tests
npm test

# Check coverage
npm run test:coverage

# View all GitHub issues (should be closed)
gh issue list --state all
```

### Multi-Session Workflow Example

For large projects that span multiple days:

```bash
# ═══════════════════════════════════════════════
# Day 1: Monday Morning (Setup + Planning)
# ═══════════════════════════════════════════════

cd ~/projects/enterprise-saas
/orchestrator "Enterprise SaaS platform with multi-tenancy, role-based auth,
billing integration, admin dashboard, REST API, and comprehensive analytics"

# Orchestrator runs Phases 0-2
# ✅ Phase 0: CI/CD Setup (15 min)
# ✅ Phase 1: Product Definition (30 min, 15 GitHub issues created)
# ✅ Phase 2: Architecture (45 min)

# Check progress
/status
# Output: Phase 2 complete, Context: 42%

# End of day - save checkpoint
exit  # Checkpoint auto-saves at docs/.orchestrator-state.json

# ═══════════════════════════════════════════════
# Day 2: Tuesday Morning (Implementation Part 1)
# ═══════════════════════════════════════════════

cd ~/projects/enterprise-saas
/resume

# Output:
# 🔄 Existing project found: enterprise-saas
# 📍 Last checkpoint: Architecture (completed Monday)
# ✅ Completed: 0/15 issues
# 📊 Context Used: 0% (fresh session)
#
# Resume existing project? (y/n)
> y

# Orchestrator continues from Phase 3
# ✅ Implements issues #1-5 (3 hours)
# Context reaches 78%

⚠️  Context usage: 78% - approaching limit!

/checkpoint "Completed auth module (issues #1-5)"
exit

# ═══════════════════════════════════════════════
# Day 3: Wednesday Morning (Implementation Part 2)
# ═══════════════════════════════════════════════

/resume

# Continues from issue #6
# ✅ Implements issues #6-10 (3 hours)
# Context: 72%

/checkpoint "Completed billing integration (issues #6-10)"
exit

# ═══════════════════════════════════════════════
# Day 4: Thursday (Final Implementation + QA)
# ═══════════════════════════════════════════════

/resume

# ✅ Implements issues #11-15 (2 hours)
# ✅ Phase 4: QA (30 min, finds 2 bugs)
# ✅ Bug fixes (1 hour)
# ✅ Phase 5: Verification (15 min, passes!)
# ✅ Phase 6: Learning (5 min)

# Project complete! 🎉
# Total: 15 issues, 206 tests, 87% coverage
```

**Key Benefits:**
- ✅ **No context overflow** - Each session starts fresh (200K tokens)
- ✅ **Exact resume point** - Continues from last completed issue
- ✅ **Progress preserved** - Verification loop counter, agent history maintained
- ✅ **GitHub sync** - Handles any manual changes between sessions
- ✅ **Project isolation** - Knowledge base learns only from this project

### Using Learning Features

#### During Project Development

```bash
# After implementing several features, search for patterns
/patterns recommend "Add payment integration"

# Search by domain (from current project's patterns)
/patterns search domain=authentication

# Get specific pattern details
/patterns get auth-jwt-pattern-001

# View library statistics (current project only)
/patterns stats
```

#### After Project Completion

```bash
# Learning happens automatically at the end, but you can also:
/reflect

# This generates docs/LEARNING-REPORT.md with:
# - What worked well in this project
# - Patterns extracted from this project
# - Anti-patterns found in this project
# - Recommendations for future features

# Note: Patterns are stored in .claude/knowledge/ for this project only
```

#### Pattern Scope

**Important:** Patterns learned in this project stay with this project. They can help with:
- Adding new features to this project later
- Maintaining this project
- Understanding what worked well

**Patterns do NOT transfer to other projects.**

### Typical Workflow

```bash
# 1. Create new project directory
mkdir my-project && cd my-project

# 2. Initialize git + GitHub repo
git init
gh repo create my-project --public --source=. --remote=origin

# 3. Copy orchestrator config
cp -r /path/to/claude-autonomous-builder/.claude .
.claude/scripts/init-knowledge-base.sh

# 4. Open in Claude Code
code .

# 5. Run orchestrator
/orchestrator "Your detailed project description"

# 6. Wait for completion (6-10 hours)
# Check progress periodically via:
# - GitHub issues
# - docs/METRICS.md
# - git log

# 6a. If you need to stop mid-execution:
# - Check context usage: /status
# - At 75%+: Save and exit (checkpoint auto-saves)
# - Next day: /resume to continue

# 7. Review results
cat docs/LEARNING-REPORT.md
npm test
npm run test:coverage

# 8. Push to GitHub
git push -u origin main

# 9. Create PR if needed
/review-pr
```

### Pro Tips

**Be Specific:**
```bash
# ✅ Good
/orchestrator A todo API using Express.js and PostgreSQL with:
- User registration and JWT authentication
- CRUD operations for todos
- Categories and tags
- Due dates with reminders
- 80%+ test coverage

# ❌ Too Vague
/orchestrator Build a todo app
```

**Specify Tech Stack:**
```bash
# The orchestrator will choose technologies if you don't specify,
# but being explicit ensures you get what you want:

"Using React 18 with TypeScript and Tailwind CSS"
"Using Express.js, NOT Fastify"
"Using PostgreSQL with Prisma ORM"
```

**Set Constraints:**
```bash
# Help guide the implementation:
- "Under 50 dependencies"
- "No external APIs"
- "Mobile-first responsive design"
- "Optimized for performance"
```

**Use Resumability for Large Projects:**
```bash
# For projects >6 hours, plan multi-session work:

# Day 1: Phases 0-2 (infrastructure + planning)
/orchestrator "Large e-commerce platform..."
# Stop at ~75% context, checkpoint auto-saves

# Day 2: Phase 3 (implementation part 1)
/resume  # Continue from where you left off

# Day 3: Phase 3 (implementation part 2) + Phases 4-6
/resume  # Finish remaining work

# Check progress anytime:
/status
```

### Troubleshooting Common Issues

**"Agent not found"**
```bash
# Verify .claude directory exists
ls -la .claude/

# If missing, copy from template:
cp -r /path/to/claude-autonomous-builder/.claude .
.claude/scripts/init-knowledge-base.sh
```

**"Knowledge base not initialized"**
```bash
# Initialize the database
.claude/scripts/init-knowledge-base.sh
```

**"GitHub issues not created"**
```bash
# Ensure you have a GitHub repo set up:
git remote -v

# Create one if missing:
gh repo create my-project --public --source=. --remote=origin
```

**"Tests failing"**
```bash
# The orchestrator will auto-fix in Phase 5 (Verification Loop)
# If it exceeds 3 attempts, it creates docs/DIVERGENCE-REPORT.md
# Review that report for manual intervention steps
```

**"Context limit approaching"**
```bash
# Save and resume when warned:
⚠️  Context usage: 78% - approaching limit!

# Stop gracefully (checkpoint auto-saves)
exit

# Resume next day with fresh context
/resume
```

**"Checkpoint out of sync"**
```bash
# Verify checkpoint matches GitHub
/status --verify

# If issues detected, checkpoint auto-syncs
# Or manually sync:
source .claude/scripts/checkpoint.sh
update_work_progress
```

**"Resume not working"**
```bash
# Check checkpoint exists
ls -la docs/.orchestrator-state.json

# View checkpoint status
/status

# If corrupted, restore from git or start fresh:
git checkout docs/.orchestrator-state.json
# OR
rm docs/.orchestrator-state.json
/orchestrator --fresh "Project idea"
```

## 🎛️ Configuration

### CLAUDE.md

The main workflow file defines:
- **Phases**: Product → Architecture → Implementation → QA → Verification
- **Completion criteria**: All issues closed, tests passing, 80%+ coverage
- **GitHub integration**: Issue tracking and milestone management

### Agents

Each agent has:
- **Purpose**: Specific role in the workflow
- **Tools**: Available capabilities
- **Success criteria**: When its phase is complete

Customize agents by editing `.claude/agents/*.md`

## 📊 Real-World Example

**Input:**
```
A Periodic Table SPA using React and Tailwind CSS
```

**Output:**
- ✅ Full React + TypeScript application
- ✅ 118 chemical elements with accurate data
- ✅ Category filtering and real-time search
- ✅ 206 passing tests (87% coverage)
- ✅ Complete documentation (PRD, Architecture, QA Report)
- ✅ Zero security vulnerabilities

**GitHub:** [periodic-table-spa](https://github.com/gitsoufiane/periodic-table-spa)

## 🔧 Customization

### Modify the Workflow

Edit `.claude/CLAUDE.md` to:
- Add/remove phases
- Change completion criteria
- Adjust GitHub integration
- Modify verification checks

### Create New Agents

Add `.claude/agents/your-agent.md`:

```markdown
---
name: your-agent
color: blue
---

# Your Agent

## Purpose
Describe what this agent does

## Tools
- Tool 1
- Tool 2

## Success Criteria
- Criterion 1
- Criterion 2
```

### Add Commands

Create `.claude/commands/your-command.md`:

```markdown
---
name: your-command
description: What this command does
---

Your command implementation
```

## 🎯 Best Practices

### When to Use
- ✅ New projects from scratch
- ✅ Well-defined feature additions
- ✅ Building MVPs or prototypes
- ✅ Learning new technologies

### When NOT to Use
- ❌ Debugging existing complex systems
- ❌ Vague or undefined requirements
- ❌ Projects requiring domain expertise
- ❌ Simple one-file scripts

### Tips for Success

1. **Be specific** - "Build a blog with markdown support" > "Build a blog"
2. **Mention tech stack** - "Using Next.js and PostgreSQL" helps
3. **Define key features** - List the main capabilities upfront
4. **Set constraints** - "Under 50 dependencies" or "No external APIs"
5. **Monitor context usage** - Check `/status` periodically, save at 75%+ usage
6. **Use multi-session for large projects** - Projects >6 hours benefit from planned resume points

## 🧪 Quality Standards

The system enforces:

- **Testing**: 80%+ code coverage required
- **Security**: npm audit must pass with 0 vulnerabilities
- **Code Quality**: ESLint + Prettier configured
- **Documentation**: PRD, Architecture, and README required
- **Type Safety**: TypeScript strict mode (when applicable)

## 🐛 Troubleshooting

### "Agent stuck in loop"
The verification loop will retry failed steps. If it loops more than 3 times, check:
- Are tests actually passing?
- Is coverage really 80%+?
- Are all GitHub issues closed?

### "Wrong tech stack"
Be explicit: "Using React, NOT Vue" or "Python with FastAPI, NOT Flask"

### "Missing features"
The product-manager agent breaks down your idea. Review the PRD and issues before implementation starts.

## 🤝 Contributing

Improvements welcome! This is a living configuration that gets better with use.

**Ideas for enhancement:**
- Add deployment agents (Vercel, AWS, etc.)
- E2E testing automation
- Performance benchmarking
- Security scanning agents
- Dependency update automation

## 📝 License

MIT License - Free to use and modify

## 🙏 Acknowledgments

Built using Claude Code and the Claude Sonnet 4.5 model.

---

## 📋 Quick Reference

**🎯 New to the orchestrator? Print the [QUICK-START-CHEAT-SHEET.md](QUICK-START-CHEAT-SHEET.md) for easy reference!**

---

### Essential Commands

```bash
# Start a new project
/orchestrator "Your detailed project description"

# Resume from checkpoint (multi-session support)
/resume                           # Resume with confirmation
/resume --force                   # Skip confirmation
/status                           # Check checkpoint status
/status --verify                  # Verify GitHub sync
/checkpoint "Custom message"      # Manual checkpoint save

# Search for patterns
/patterns recommend "Your feature description"
/patterns search domain=authentication
/patterns get pattern-id

# Trigger learning (automatic by default)
/reflect

# Optimize thresholds (after 5+ projects)
/optimize
```

### File Locations

```
docs/
├── PRD.md                      # Product requirements
├── ARCHITECTURE.md             # System design
├── METRICS.md                  # Project metrics
├── LEARNING-REPORT.md          # Post-project learnings
├── COMPLETION-REPORT.md        # Final verification
├── THRESHOLD-OPTIMIZATION-REPORT.md  # Threshold tuning
└── .orchestrator-state.json    # 🔄 Resumability checkpoint (auto-created)

.claude/
├── knowledge/
│   ├── orchestrator.db         # Knowledge base
│   ├── patterns/              # Reusable patterns
│   └── anti-patterns/         # Known failure modes
├── scripts/
│   ├── checkpoint.sh           # 🔄 State management functions
│   └── resume-handlers.sh      # 🔄 Phase resume logic
└── plugins/
    └── orchestrator/
        └── skills/
            ├── resume.md       # 🔄 /resume skill
            ├── checkpoint.md   # 🔄 /checkpoint skill
            └── status.md       # 🔄 /status skill
```

### GitHub Workflow

```bash
# The orchestrator uses GitHub issues for tracking:
gh issue list --state all           # View all issues
gh issue view <number>              # View specific issue
gh pr list                          # View pull requests (if created)
```

### Verification

```bash
# Check if everything is set up correctly:
ls -la .claude/                     # Config exists
cat .claude/knowledge/orchestrator.db  # Database exists
.claude/scripts/init-knowledge-base.sh # Reinitialize if needed
```

### Project Setup

**Local (Project-Specific - Only Option):**
```bash
# Per project - copy and initialize
cd ~/your-project
cp -r /path/to/claude-autonomous-builder/.claude .
.claude/scripts/init-knowledge-base.sh

# Verify
ls -la .claude/knowledge/orchestrator.db
```

**Note:** Each project has its own isolated knowledge base. Learnings do not transfer between projects.

---

**Want to see it in action?** Check out the [Periodic Table SPA](https://github.com/gitsoufiane/periodic-table-spa) - fully built by this system!
