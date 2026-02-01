# Orchestrator Knowledge Base

This directory contains the **self-learning system** for the autonomous orchestrator. It accumulates knowledge across all projects to enable continuous improvement.

## Architecture

The knowledge base implements a **meta-learning architecture** inspired by 2026 best practices:
- Continuous learning from project outcomes
- Pattern library for solution reuse
- Statistical threshold optimization
- Agent prompt evolution via A/B testing

## Directory Structure

```
.claude/knowledge/
├── orchestrator.db              # SQLite database (metrics, patterns, learnings)
├── schema.sql                   # Database schema definition
├── index.json                   # Pattern library search index
├── patterns/                    # Reusable solution patterns
│   ├── auth-jwt.md             # JWT authentication pattern
│   ├── .gitkeep
│   └── ...
├── anti-patterns/               # Known failure modes to avoid
│   ├── hardcoded-secrets.md    # Hardcoded secrets anti-pattern
│   ├── .gitkeep
│   └── ...
└── experiments/                 # A/B tests for prompt optimization
    ├── .gitkeep
    └── ...
```

## Initialization

**First-time setup:**
```bash
.claude/scripts/init-knowledge-base.sh
```

This will:
1. Create SQLite database from schema.sql
2. Initialize pattern library structure
3. Create index.json for pattern search
4. Verify database connectivity

**Prerequisites:**
- SQLite 3 installed (`brew install sqlite3` on macOS)
- MCP servers configured (see `.claude/.mcp.json`)

## Database Schema

The SQLite database tracks:

- **projects** - Project metadata, autonomy scores, verification loops
- **issues** - GitHub issues with complexity analysis (estimated vs actual)
- **patterns** - Reusable patterns with success rates and usage stats
- **pattern_usage** - Pattern application tracking across projects
- **anti_patterns** - Known failure modes with detection methods
- **agent_performance** - Agent effectiveness per project
- **prompt_versions** - Agent prompt evolution history
- **threshold_evolution** - Threshold tuning over time
- **learning_insights** - Extracted insights from retrospectives
- **experiments** - A/B test configurations for optimization
- **experiment_results** - Individual A/B test outcomes

Full schema: `schema.sql`

## Pattern Library

### What is a Pattern?

A **pattern** is a proven, reusable solution to a common problem. Patterns are extracted from successful project implementations.

**Extraction Criteria:**
1. ✅ Implementation was successful (tests passed, no bugs)
2. ✅ Complexity ≥ 500 (medium or complex)
3. ✅ Likely to recur in other projects
4. ✅ Has clear boundaries (can be templated)

### Pattern Domains

Current patterns organized by:
- `authentication` - Auth systems (JWT, OAuth, sessions)
- `api-design` - REST, GraphQL, WebSocket patterns
- `database` - Schema design, migrations, ORMs
- `testing` - Test structures, mocking strategies
- `cicd` - CI/CD pipeline configurations
- `security` - Security implementations
- `performance` - Optimization techniques

### Using Patterns

**Search for patterns:**
```bash
/patterns search domain=authentication
/patterns search keywords=jwt,token
```

**Get pattern details:**
```bash
/patterns get auth-jwt-pattern-001
```

**Get recommendations:**
```bash
/patterns recommend "Build a REST API with JWT auth"
```

### Creating Patterns

Patterns are **automatically extracted** by the learning-orchestrator agent during Phase 6 (Learning).

**Manual creation:**
1. Create `.claude/knowledge/patterns/my-pattern.md`
2. Add YAML frontmatter (see `auth-jwt.md` for template)
3. Follow pattern structure (Context → Solution → Implementation → Testing)
4. Update index: `/patterns update-index`

## Anti-Patterns

### What is an Anti-Pattern?

An **anti-pattern** is a common mistake or failure mode detected during projects. Anti-patterns are flagged by security-reviewer and code-reviewer agents.

**Detection Methods:**
- Regex patterns (e.g., hardcoded secrets)
- AST analysis (e.g., mutation detection)
- Security scans (e.g., OWASP Top 10)

**Severity Levels:**
- **CRITICAL** - Security vulnerabilities, data loss risks
- **HIGH** - Performance issues, major bugs
- **MEDIUM** - Code quality issues, maintainability
- **LOW** - Style violations, minor inconsistencies

### Using Anti-Patterns

Anti-patterns are automatically checked during:
- Phase 3: Implementation (code-reviewer, security-reviewer)
- Phase 4: QA (security-reviewer)
- Phase 6: Learning (learning-orchestrator)

## Threshold Optimization

### What are Thresholds?

Numerical parameters that guide the orchestrator:
- **Complexity Thresholds** - Simple (0-500), Medium (501-1500), Complex (1501+)
- **Context Budgets** - Green (<100K), Yellow (100-150K), Red (>150K)
- **Time Budgets** - Per-phase duration estimates
- **Commit Limits** - Max files (10), max LOC (500)
- **Coverage Targets** - Test coverage % by project type

### Optimization Process

**Minimum Requirement:** 5 completed projects for statistical significance

**Process:**
1. Analyze actual vs estimated metrics across all projects
2. Calculate accuracy, variance, outliers
3. Recommend threshold adjustments with confidence levels
4. Require user approval before applying changes

**Run optimization:**
```bash
/optimize
```

**Frequency:**
- After first 5 projects: Baseline optimization
- Every 10 projects: Incremental tuning
- After major workflow changes: Re-calibration

## MCP Integration

The knowledge base is accessed via **Model Context Protocol** servers:

### 1. sqlite-knowledge-base

Query and update project metrics.

**Tools:**
- `query` - Execute SQL queries
- `execute` - Insert/update records
- `describe_table` - Get table schema

**Configuration:**
```json
{
  "sqlite-knowledge-base": {
    "command": "npx",
    "args": ["@modelcontextprotocol/server-sqlite", "--db-path", "~/.claude/knowledge/orchestrator.db"]
  }
}
```

### 2. filesystem-patterns

Read/write pattern library files.

**Tools:**
- `read_file` - Read pattern markdown
- `write_file` - Create new patterns
- `list_directory` - Browse patterns

**Configuration:**
```json
{
  "filesystem-patterns": {
    "command": "npx",
    "args": [
      "@modelcontextprotocol/server-filesystem",
      "~/.claude/knowledge/patterns",
      "~/.claude/knowledge/anti-patterns"
    ]
  }
}
```

### 3. github-analytics (Optional)

Discover patterns across GitHub repositories.

**Use Case:** Analyze how other projects solve similar problems

**Configuration:**
```json
{
  "github-analytics": {
    "command": "npx",
    "args": ["@modelcontextprotocol/server-github"],
    "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}" }
  }
}
```

## Learning Workflow

### Automatic Learning (Recommended)

If `auto_learn: true` in `.claude/plugins/learning.local.md`:

```
Project Execution (Phases 0-5)
  ↓
Verification Passes (Phase 5)
  ↓
Learning Phase Triggered (Phase 6)
  ↓
Learning Report Generated
  ↓
Knowledge Base Updated
  ↓
Project Complete
```

### Manual Learning

If auto-learn disabled or retroactively analyzing projects:

```bash
/reflect
```

This triggers the learning-orchestrator agent to:
1. Read `docs/METRICS.md` and `docs/COMPLETION-REPORT.md`
2. Analyze performance vs targets
3. Extract patterns and anti-patterns
4. Generate `docs/LEARNING-REPORT.md`
5. Update SQLite database

## Metrics Evolution

### Maturity Stages

| Projects | Stage | Capabilities | Autonomy |
|----------|-------|--------------|----------|
| 1 | Baseline | Collecting initial data | 70-80% |
| 5 | Emerging | First threshold optimization | 80-85% |
| 10 | Growing | Pattern reuse begins | 85-90% |
| 25 | Mature | Stable thresholds, rich pattern library | 90-93% |
| 50 | Advanced | Agent prompt evolution active | 93-95% |
| 100+ | Expert | 30+ patterns, 95%+ autonomy | 95%+ |

### Success Metrics

**Short-Term (10 projects):**
- Knowledge base stores 10 project records
- Pattern library has 3+ patterns
- First threshold optimization
- Analytics show improvement trends

**Medium-Term (50 projects):**
- Autonomy score +10% vs baseline
- Pattern reuse rate: 30%+
- Threshold accuracy: 90%+
- Agent prompts evolved 2+ times

**Long-Term (100+ projects):**
- Autonomy score: 95%+
- Pattern library: 30+ proven patterns
- Threshold accuracy: 95%+
- Time savings: 20%+ from pattern reuse
- 5+ agent evolution cycles

## Maintenance

### Backup Database

```bash
# Create timestamped backup
cp .claude/knowledge/orchestrator.db \
   .claude/knowledge/orchestrator.db.backup.$(date +%Y%m%d_%H%M%S)
```

### Rebuild Index

If pattern library index becomes corrupted:

```bash
/patterns update-index
```

### Database Queries

Useful queries for analysis:

```bash
# Total projects
sqlite3 orchestrator.db "SELECT COUNT(*) FROM projects WHERE completed_at IS NOT NULL;"

# Pattern usage statistics
sqlite3 orchestrator.db "SELECT name, times_used, success_rate FROM patterns ORDER BY times_used DESC;"

# Threshold evolution history
sqlite3 orchestrator.db "SELECT * FROM threshold_evolution ORDER BY changed_at DESC LIMIT 10;"

# Agent performance summary
sqlite3 orchestrator.db "SELECT agent_name, AVG(success_rate) as avg_success FROM agent_performance GROUP BY agent_name;"
```

### Clear All Data (Reset)

⚠️ **WARNING:** This deletes all accumulated learnings.

```bash
# Backup first!
cp orchestrator.db orchestrator.db.backup

# Reinitialize
rm orchestrator.db
.claude/scripts/init-knowledge-base.sh
```

## Research Foundation

This knowledge base architecture is based on 2026 AI agent research:

**Key Insights:**
- Autonomous AI agent market: $35-52B by 2030 (Source: Deloitte)
- 1,445% surge in multi-agent system adoption (2024-2025)
- Meta-learning consistently outperforms traditional ML
- Human-on-the-loop governance is the production standard
- Context curation is the critical skill

**References:**
- [Deloitte AI Agent Orchestration 2026](https://www.deloitte.com/us/en/insights/industry/technology/technology-media-and-telecom-predictions/2026/ai-agent-orchestration.html)
- [7 Agentic AI Trends 2026](https://machinelearningmastery.com/7-agentic-ai-trends-to-watch-in-2026/)
- [Meta-Learning Research](https://link.springer.com/article/10.1007/s40747-021-00591-8)

## Questions?

- Check `.claude/agents/learning-orchestrator.md` for learning phase details
- Check `.claude/agents/pattern-library.md` for pattern search implementation
- Check `.claude/agents/threshold-optimizer.md` for optimization logic
- Run `/reflect --help` or `/patterns --help` for skill documentation

---

**Remember:** Knowledge compounds. Every project makes the orchestrator smarter.
