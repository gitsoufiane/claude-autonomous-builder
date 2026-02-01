# Claude Autonomous Builder - Quick Start Cheat Sheet

## 🎯 One-Time Global Setup

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/claude-autonomous-builder.git
cd claude-autonomous-builder

# 2. Initialize knowledge base
.claude/scripts/init-knowledge-base.sh

# 3. Create global symlink
ln -s "$(pwd)/.claude" ~/.claude-global

# 4. Install MCP servers (optional)
npm install -g @modelcontextprotocol/server-sqlite
npm install -g @modelcontextprotocol/server-filesystem
```

## 🚀 Start a New Project (Two Ways)

### Method 1: Automated Script (Recommended)

```bash
cd /path/to/claude-autonomous-builder
.claude/scripts/setup-project.sh my-project-name
```

### Method 2: Manual Setup

```bash
# Create and enter project directory
mkdir ~/projects/my-project && cd ~/projects/my-project

# Initialize git
git init

# Link to global config
ln -s ~/.claude-global .claude

# Create GitHub repo
gh repo create my-project --public --source=. --remote=origin

# Open in IDE
code .
```

## ⚡ Run the Orchestrator

In Claude Code, type:

```bash
/orchestrator [Your detailed project description]
```

**Example Templates:**

**REST API:**
```bash
/orchestrator A RESTful API for task management with:
- User authentication using JWT
- CRUD operations for tasks
- Categories and tags
- PostgreSQL database
- 80%+ test coverage
```

**React App:**
```bash
/orchestrator A React e-commerce catalog with:
- Product listing with search and filters
- Shopping cart functionality
- Responsive design with Tailwind CSS
- TypeScript and comprehensive tests
```

**CLI Tool:**
```bash
/orchestrator A Node.js CLI for database migrations with:
- Support for PostgreSQL and MySQL
- Up/down migrations
- Migration versioning
- TypeScript
```

## 📊 Progress Monitoring

```bash
# View GitHub issues
gh issue list --state all

# Check current metrics
cat docs/METRICS.md

# View git history
git log --oneline

# Run tests manually
npm test
```

## 🧠 Learning Features

```bash
# Search for patterns before starting
/patterns recommend "Build an API with authentication"

# Search by domain
/patterns search domain=authentication

# Get specific pattern
/patterns get auth-jwt-pattern-001

# View pattern statistics
/patterns stats

# Trigger learning manually (automatic by default)
/reflect

# Optimize thresholds (after 5+ projects)
/optimize
```

## 📁 Important Files

After orchestrator completes:

```
docs/
├── PRD.md                           # Product requirements
├── ARCHITECTURE.md                  # System design
├── METRICS.md                       # Project metrics
├── LEARNING-REPORT.md               # Learnings extracted
├── COMPLETION-REPORT.md             # Final verification
└── THRESHOLD-OPTIMIZATION-REPORT.md # Threshold tuning (after 5+ projects)
```

## ✅ Verification Checklist

After completion, verify:

```bash
# All tests pass
npm test

# Coverage meets target
npm run test:coverage  # Should be ≥80%

# No open issues
gh issue list --state open  # Should be empty

# Security audit passes
npm audit

# Type checking passes (if TypeScript)
npm run typecheck
```

## 🔧 Troubleshooting

**Config not found:**
```bash
ls -la .claude/  # Should show symlink or directory
ln -s ~/.claude-global .claude  # Recreate symlink
```

**Knowledge base issues:**
```bash
.claude/scripts/init-knowledge-base.sh  # Reinitialize
```

**GitHub issues not created:**
```bash
git remote -v  # Check remote is set
gh repo create my-project --public --source=. --remote=origin
```

## 📋 Phase Timeline

| Phase | Duration | What Happens |
|-------|----------|--------------|
| 0: CI/CD | 15 min | GitHub Actions, pre-commit hooks |
| 1: Product | 30 min | PRD, GitHub issues, milestone |
| 2: Architecture | 45 min | ARCHITECTURE.md, project structure |
| 3: Implementation | 4+ hours | Code + tests (TDD approach) |
| 4: QA | 30 min | Test suite, security audit, E2E |
| 5: Verification | 15 min | Completion checks, self-healing |
| 6: Learning | 5 min | Pattern extraction, knowledge update |

**Total:** 6-10 hours (autonomous)

## 🎯 Best Practices

**Be Specific:**
- ✅ "Express.js API with JWT auth and PostgreSQL"
- ❌ "Build an API"

**Mention Tech Stack:**
- ✅ "Using React 18, TypeScript, and Tailwind CSS"
- ❌ "Build a web app"

**Define Features:**
- ✅ "CRUD for tasks, categories, tags, due dates, reminders"
- ❌ "Task management"

**Set Constraints:**
- ✅ "Under 50 dependencies, no external APIs"
- ✅ "Mobile-first responsive design"
- ✅ "Optimized for performance"

## 🌟 Pro Tips

1. **Use patterns:** Run `/patterns recommend` before starting
2. **Monitor progress:** Check GitHub issues and `docs/METRICS.md`
3. **Trust the process:** Don't interrupt, let it complete all phases
4. **Review learnings:** Read `docs/LEARNING-REPORT.md` after completion
5. **Optimize regularly:** Run `/optimize` every 10 projects

## 📊 Knowledge Base Maturity

| Projects | Capabilities | Autonomy |
|----------|--------------|----------|
| 1 | Baseline data | 70-80% |
| 5 | First optimization | 80-85% |
| 10 | Pattern reuse | 85-90% |
| 25 | Mature patterns | 90-93% |
| 50 | Prompt evolution | 93-95% |
| 100+ | Expert system | 95%+ |

## 🔗 Quick Links

- **Full Documentation:** [README.md](README.md)
- **Learning System:** [LEARNING-SYSTEM-SUMMARY.md](LEARNING-SYSTEM-SUMMARY.md)
- **Knowledge Base:** [.claude/knowledge/README.md](.claude/knowledge/README.md)
- **Example Project:** [Periodic Table SPA](https://github.com/gitsoufiane/periodic-table-spa)

---

**Print this cheat sheet and keep it handy!** 📄

**Questions?** Check the full README.md or the learning system documentation.
