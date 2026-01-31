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
        ┌────────▼────────┐
        │ ✅ Complete!     │
        └─────────────────┘
```

## 📁 Structure

```
.claude/
├── CLAUDE.md           # Main workflow instructions
├── agents/
│   ├── product-manager.md    # Creates PRD and issues
│   ├── architect.md          # Designs architecture
│   ├── developer.md          # Implements features
│   ├── qa-engineer.md        # Tests and finds bugs
│   └── reviewer.md           # Verifies completion
└── commands/
    └── build-project.md      # /build-project command
```

## 🚀 Quick Start

### 1. Install in Your Project

```bash
# Copy to your project root
cp -r .claude /path/to/your/project/

# Or symlink for global use
ln -s $(pwd)/.claude ~/.claude-templates/autonomous-builder
```

### 2. Use in Claude Code

In any Claude Code session:

```bash
/build-project Your project idea here
```

**Example:**
```bash
/build-project A RESTful API for a task management system with user authentication,
task CRUD operations, and real-time notifications using WebSockets
```

### 3. Watch It Build

Claude will:
1. ✅ Create a detailed PRD
2. ✅ Break it into GitHub issues
3. ✅ Design the architecture
4. ✅ Implement all features with tests
5. ✅ Run QA and fix bugs
6. ✅ Verify everything passes

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

**Want to see it in action?** Check out the [Periodic Table SPA](https://github.com/gitsoufiane/periodic-table-spa) - fully built by this system!
