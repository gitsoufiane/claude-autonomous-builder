---
name: patterns
description: Search and retrieve solution patterns from the knowledge base
---

# /patterns - Pattern Library Search

Search for reusable solution patterns to accelerate development.

## Usage

```bash
# Search by domain
/patterns domain=authentication

# Search by keywords
/patterns keywords=jwt,token

# Search by complexity
/patterns complexity=medium

# Get specific pattern
/patterns get auth-jwt-pattern-001

# Get recommendations for a project
/patterns recommend "Build a REST API with JWT authentication"

# Show statistics
/patterns stats

# Update pattern index
/patterns update-index
```

## Commands

### search

Find patterns matching criteria.

**Syntax:**
```bash
/patterns search [domain=<domain>] [keywords=<keywords>] [complexity=<level>]
```

**Examples:**
```bash
/patterns search domain=authentication
/patterns search keywords=jwt,auth,token
/patterns search complexity=medium
/patterns search domain=api-design keywords=rest
```

**Output:**
```markdown
# Pattern Search Results

Query: domain=authentication

Found 2 patterns:

## 1. JWT Authentication Pattern ⭐⭐⭐
- **ID:** auth-jwt-pattern-001
- **Complexity:** Medium (850)
- **Success Rate:** 95% (12 uses)
- **Estimated Context:** 65K tokens
- **File:** .claude/knowledge/patterns/auth-jwt.md

## 2. OAuth2 Integration Pattern ⭐⭐
- **ID:** auth-oauth2-pattern-001
- **Complexity:** Complex (1650)
- **Success Rate:** 89% (5 uses)
- **Estimated Context:** 125K tokens
- **File:** .claude/knowledge/patterns/auth-oauth2.md
```

### get

Retrieve full pattern details.

**Syntax:**
```bash
/patterns get <pattern-id>
```

**Example:**
```bash
/patterns get auth-jwt-pattern-001
```

**Output:**
Full markdown content of the pattern, including:
- Context and use cases
- Solution architecture
- File structure
- Implementation steps
- Code examples
- Testing strategy
- Common pitfalls
- Lessons learned

### recommend

Get pattern recommendations for a project description.

**Syntax:**
```bash
/patterns recommend "<project-description>"
```

**Examples:**
```bash
/patterns recommend "Build a REST API with user authentication"
/patterns recommend "E-commerce site with real-time inventory updates"
/patterns recommend "CLI tool for database migrations"
```

**Output:**
```markdown
# Pattern Recommendations

Project: "Build a REST API with user authentication"

## Highly Relevant (3 patterns)

### 1. JWT Authentication Pattern ⭐⭐⭐
- **Relevance:** Matches "authentication", "user", "api"
- **Complexity:** Medium (850)
- **Success Rate:** 95%
- **Estimated Context:** 65K tokens

**Why:** Standard pattern for stateless API authentication

### 2. REST API CRUD Pattern ⭐⭐⭐
- **Relevance:** Matches "api", "rest"
- **Complexity:** Simple (450)
- **Success Rate:** 97%
- **Estimated Context:** 40K tokens

**Why:** Foundation for RESTful APIs

### 3. Rate Limiting Pattern ⭐⭐
- **Relevance:** Matches "api" (complementary)
- **Complexity:** Simple (350)
- **Success Rate:** 94%
- **Estimated Context:** 30K tokens

**Why:** Essential for production APIs

**Total Estimated Context:** ~135K tokens (within budget ✅)

Use `/patterns get <pattern-id>` to view full details.
```

### stats

Display pattern library statistics.

**Syntax:**
```bash
/patterns stats
/patterns stats domain=authentication
```

**Output:**
```markdown
# Pattern Library Statistics

**Total Patterns:** 15
**Total Anti-Patterns:** 8
**Total Projects Analyzed:** 23

## By Domain

| Domain | Patterns | Avg Success Rate | Avg Times Used |
|--------|----------|------------------|----------------|
| authentication | 4 | 93% | 8.5 |
| api-design | 6 | 95% | 12.3 |
| database | 3 | 91% | 6.7 |
| security | 2 | 97% | 5.0 |

## Most Used Patterns

1. REST CRUD Pattern (18 uses, 97% success)
2. JWT Auth Pattern (12 uses, 95% success)
3. PostgreSQL Schema (10 uses, 92% success)

## Least Successful Patterns (< 90%)

1. Microservices Pattern (85% success, 6 uses)
   - Issue: High complexity, context overflow
   - Recommendation: Split into smaller patterns
```

### update-index

Rebuild pattern library index after adding/modifying patterns.

**Syntax:**
```bash
/patterns update-index
```

**When to Use:**
- After manually adding pattern files
- After editing pattern frontmatter
- If index becomes corrupted

**Output:**
```markdown
# Pattern Index Updated

**Patterns:** 15 (+2 new)
**Anti-Patterns:** 8 (+1 new)

**New Patterns:**
- websocket-realtime (medium)
- graphql-api (complex)

**Modified Patterns:**
- auth-jwt (success rate updated: 95% → 96%)

Index saved to: .claude/knowledge/index.json
```

## Available Domains

Current patterns cover:

- **authentication** - Auth systems (JWT, OAuth, sessions)
- **api-design** - REST, GraphQL, WebSocket APIs
- **database** - Schema design, migrations, ORMs
- **testing** - Test strategies and patterns
- **cicd** - CI/CD pipeline configurations
- **security** - Security implementations
- **performance** - Optimization techniques
- **architecture** - System design patterns

## Pattern Quality Indicators

### Success Rate
- 95%+ : Highly reliable, battle-tested
- 85-94%: Proven, but context-dependent
- < 85%: Use with caution, may need refinement

### Times Used
- 10+ : Well-established, broadly applicable
- 5-9 : Moderately proven
- < 5 : New or niche, needs more validation

### Complexity
- **Simple (0-500):** Quick implementation, low risk
- **Medium (501-1500):** Moderate effort, well-scoped
- **Complex (1501+):** High effort, should be split into sub-patterns

## When to Use Patterns

### ✅ Good Use Cases

- Implementing common features (auth, CRUD, real-time)
- Accelerating development with proven solutions
- Ensuring consistency across projects
- Learning best practices
- Estimating complexity accurately

### ❌ Poor Use Cases

- Copy-pasting without understanding
- Forcing patterns on inappropriate problems
- Skipping tests because pattern "already works"
- Ignoring project-specific requirements

## Integration with Agents

### Product Manager

When creating issues:
```
@pattern-library recommend "<feature-description>"
```

Uses pattern complexity estimates to improve issue complexity scores.

### Developer

When implementing features:
```
@pattern-library search keywords=<domain>
@pattern-library get <pattern-id>
```

Loads proven solutions to accelerate implementation.

### Learning Orchestrator

After projects:
```
@pattern-library update-index
```

Keeps index synchronized with newly extracted patterns.

## Creating New Patterns

Patterns are automatically extracted by the **learning-orchestrator** agent when:
1. Feature implementation succeeds (tests pass, no bugs)
2. Complexity score ≥ 500 (medium or higher)
3. Solution is likely to recur in other projects
4. Implementation has clear boundaries

To manually create a pattern:

1. **Create markdown file:**
   ```bash
   .claude/knowledge/patterns/my-pattern.md
   ```

2. **Add YAML frontmatter:**
   ```yaml
   ---
   id: my-pattern-001
   domain: api-design
   name: My Pattern Name
   complexity: medium
   success_rate: 1.0
   times_used: 0
   keywords: ["keyword1", "keyword2"]
   created_at: 2026-01-31
   last_updated: 2026-01-31
   ---
   ```

3. **Follow template structure:**
   - Context (when to use)
   - Solution (implementation steps)
   - File structure
   - Code examples
   - Testing strategy
   - Common pitfalls
   - Success criteria

4. **Update index:**
   ```bash
   /patterns update-index
   ```

See `.claude/knowledge/patterns/auth-jwt.md` for full example.

## Troubleshooting

### "No patterns found"

**Cause:** Empty pattern library or narrow search criteria

**Fix:**
```bash
# Check if patterns exist
ls .claude/knowledge/patterns/*.md

# Try broader search
/patterns stats

# Update index
/patterns update-index
```

### "Pattern file not found"

**Cause:** Index references non-existent file

**Fix:**
```bash
# Rebuild index
/patterns update-index
```

### "Index corrupted"

**Cause:** Malformed JSON in index.json

**Fix:**
```bash
# Backup existing index
cp .claude/knowledge/index.json .claude/knowledge/index.json.bak

# Rebuild from pattern files
/patterns update-index
```

## Success Criteria

- [ ] Pattern search returns relevant results
- [ ] Recommendations match project requirements
- [ ] Full pattern details are accurate and helpful
- [ ] Statistics provide useful insights
- [ ] Index stays synchronized with pattern files

## Related Skills

- `/reflect` - Extract patterns from completed projects
- `/optimize` - Optimize thresholds based on pattern usage

---

**Remember:** Patterns are knowledge distilled from experience. Use them to stand on the shoulders of past projects.
