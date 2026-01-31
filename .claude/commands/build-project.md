---
name: build-project
description: Start the autonomous project builder with a project idea
---

# Build Project Command

You have been given a project idea to build autonomously. Follow the workflow defined in CLAUDE.md precisely.

## Your Mission

Transform the user's idea into a fully working project with:
- Complete documentation (PRD, Architecture)
- All features tracked in GitHub Issues
- Production-quality implementation
- Comprehensive tests (80%+ coverage)
- All bugs found and fixed
- Verification passing

## Execution Plan

### Phase 1: Product Definition
Delegate to `product-manager` agent:
> "Analyze this project idea and create a comprehensive PRD. Break it down into features and create GitHub issues for each. The idea is: $ARGUMENTS"

Wait for completion. Verify:
- docs/PRD.md exists
- GitHub issues created with proper labels
- Milestone created

### Phase 2: Architecture
Delegate to `architect` agent:
> "Read the PRD at docs/PRD.md and design the system architecture. Create the project structure, install dependencies, and document everything in docs/ARCHITECTURE.md. Add technical details to each GitHub issue."

Wait for completion. Verify:
- docs/ARCHITECTURE.md exists
- Project structure created
- package.json configured
- tsconfig.json configured

### Phase 3: Implementation
Delegate to `developer` agent:
> "Implement all features from the GitHub issues. Work in priority order (high → medium → low). Write tests alongside implementation. Close issues when complete."

Wait for completion. Verify:
- All feature issues closed
- Tests exist for each feature

### Phase 4: Quality Assurance
Delegate to `qa-engineer` agent:
> "Run the full test suite, check coverage, perform security audit, and test edge cases. Create GitHub issues for any bugs found, prioritized by severity."

Wait for completion. Review:
- Test results
- Coverage percentage
- Bug issues created (if any)

### Phase 5: Bug Fixing (if needed)
If bugs were found, delegate to `developer` agent:
> "Fix all bugs in priority order (critical → high → medium → low). Close each bug issue when fixed."

### Phase 6: Verification Loop
Delegate to `reviewer` agent:
> "Run the full verification loop. Check for open issues, run tests, verify coverage, check documentation, and perform security audit. If anything fails, report what needs to be fixed."

**If verification fails:**
- Return to Phase 5 (developer) to fix issues
- Then run Phase 6 again
- Repeat until all checks pass

**If verification passes:**
- Generate completion report
- Declare project complete

## Important Notes

1. **Be thorough** - Don't rush through phases
2. **Verify each phase** - Check outputs before moving on
3. **Keep looping** - Don't stop until verification passes
4. **Use real GitHub** - Create actual issues, close them properly
5. **Quality over speed** - Write production-quality code

## Starting the Build

Begin by delegating to the product-manager with the user's idea.

The project idea to build is:

---

$ARGUMENTS
