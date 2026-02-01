-- Orchestrator Knowledge Base Schema
-- Self-learning system for cross-project continuous improvement

-- ============================================================================
-- PROJECTS: Core project tracking
-- ============================================================================
CREATE TABLE IF NOT EXISTS projects (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    total_duration_minutes INTEGER,
    autonomy_score REAL CHECK(autonomy_score >= 0 AND autonomy_score <= 100),
    features_count INTEGER DEFAULT 0,
    bugs_count INTEGER DEFAULT 0,
    test_coverage REAL CHECK(test_coverage >= 0 AND test_coverage <= 100),
    lines_of_code INTEGER DEFAULT 0,
    verification_loops INTEGER DEFAULT 0,
    diverged BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- ISSUES: GitHub issue tracking with complexity analysis
-- ============================================================================
CREATE TABLE IF NOT EXISTS issues (
    id TEXT PRIMARY KEY,
    project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    github_issue_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    complexity_score INTEGER NOT NULL,
    complexity_category TEXT CHECK(complexity_category IN ('SIMPLE', 'MEDIUM', 'COMPLEX')),
    estimated_context INTEGER,
    actual_context INTEGER,
    estimated_files INTEGER,
    actual_files INTEGER,
    estimated_loc INTEGER,
    actual_loc INTEGER,
    commit_count INTEGER DEFAULT 0,
    was_split BOOLEAN DEFAULT 0,
    split_accuracy BOOLEAN, -- NULL if not split, TRUE if split was correct, FALSE if unnecessary
    time_to_close_minutes INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- PATTERNS: Reusable solution patterns
-- ============================================================================
CREATE TABLE IF NOT EXISTS patterns (
    id TEXT PRIMARY KEY,
    domain TEXT NOT NULL,
    name TEXT NOT NULL,
    pattern_file TEXT NOT NULL,
    description TEXT,
    success_rate REAL DEFAULT 1.0 CHECK(success_rate >= 0 AND success_rate <= 1),
    times_used INTEGER DEFAULT 0,
    avg_complexity INTEGER,
    avg_context INTEGER,
    avg_files INTEGER,
    avg_loc INTEGER,
    keywords TEXT, -- JSON array of keywords
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- PATTERN_USAGE: Track pattern application in projects
-- ============================================================================
CREATE TABLE IF NOT EXISTS pattern_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pattern_id TEXT NOT NULL REFERENCES patterns(id) ON DELETE CASCADE,
    project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    issue_id TEXT REFERENCES issues(id) ON DELETE CASCADE,
    success BOOLEAN NOT NULL,
    context_tokens INTEGER,
    duration_minutes INTEGER,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- ANTI_PATTERNS: Known failure modes to avoid
-- ============================================================================
CREATE TABLE IF NOT EXISTS anti_patterns (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    detection_method TEXT, -- Regex, AST pattern, etc.
    severity TEXT CHECK(severity IN ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW')),
    times_caught INTEGER DEFAULT 0,
    remedy TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_caught TIMESTAMP
);

-- ============================================================================
-- AGENT_PERFORMANCE: Track agent effectiveness
-- ============================================================================
CREATE TABLE IF NOT EXISTS agent_performance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    agent_name TEXT NOT NULL,
    phase_number INTEGER,
    invocation_count INTEGER DEFAULT 1,
    avg_duration_seconds INTEGER,
    success_rate REAL CHECK(success_rate >= 0 AND success_rate <= 1),
    errors_count INTEGER DEFAULT 0,
    context_usage INTEGER, -- Tokens used
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- PROMPT_VERSIONS: Agent prompt evolution tracking
-- ============================================================================
CREATE TABLE IF NOT EXISTS prompt_versions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_name TEXT NOT NULL,
    version_hash TEXT NOT NULL UNIQUE,
    prompt_content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT 0,
    performance_score REAL, -- Calculated from agent_performance
    projects_used INTEGER DEFAULT 0,
    avg_success_rate REAL,
    notes TEXT
);

-- ============================================================================
-- THRESHOLD_EVOLUTION: Track parameter tuning over time
-- ============================================================================
CREATE TABLE IF NOT EXISTS threshold_evolution (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parameter_name TEXT NOT NULL,
    old_value REAL NOT NULL,
    new_value REAL NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    projects_analyzed INTEGER NOT NULL,
    confidence_level REAL CHECK(confidence_level >= 0 AND confidence_level <= 1),
    approved_by TEXT -- 'SYSTEM' or user identifier
);

-- ============================================================================
-- LEARNING_INSIGHTS: Extracted learnings from projects
-- ============================================================================
CREATE TABLE IF NOT EXISTS learning_insights (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    category TEXT CHECK(category IN ('SUCCESS', 'FAILURE', 'PATTERN', 'ANTI_PATTERN', 'THRESHOLD', 'AGENT')),
    insight TEXT NOT NULL,
    actionable BOOLEAN DEFAULT 1,
    implemented BOOLEAN DEFAULT 0,
    priority TEXT CHECK(priority IN ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- EXPERIMENTS: A/B testing for prompt evolution
-- ============================================================================
CREATE TABLE IF NOT EXISTS experiments (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    experiment_type TEXT CHECK(experiment_type IN ('PROMPT', 'THRESHOLD', 'WORKFLOW')),
    control_version TEXT NOT NULL,
    variant_version TEXT NOT NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    status TEXT CHECK(status IN ('RUNNING', 'COMPLETED', 'CANCELLED')),
    winner TEXT CHECK(winner IN ('CONTROL', 'VARIANT', 'INCONCLUSIVE')),
    confidence REAL CHECK(confidence >= 0 AND confidence <= 1),
    notes TEXT
);

-- ============================================================================
-- EXPERIMENT_RESULTS: Individual project results in A/B tests
-- ============================================================================
CREATE TABLE IF NOT EXISTS experiment_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    experiment_id TEXT NOT NULL REFERENCES experiments(id) ON DELETE CASCADE,
    project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    variant TEXT CHECK(variant IN ('CONTROL', 'VARIANT')),
    success BOOLEAN NOT NULL,
    metric_value REAL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDEXES: Performance optimization
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_issues_project ON issues(project_id);
CREATE INDEX IF NOT EXISTS idx_issues_complexity ON issues(complexity_category);
CREATE INDEX IF NOT EXISTS idx_pattern_usage_pattern ON pattern_usage(pattern_id);
CREATE INDEX IF NOT EXISTS idx_pattern_usage_project ON pattern_usage(project_id);
CREATE INDEX IF NOT EXISTS idx_agent_performance_project ON agent_performance(project_id);
CREATE INDEX IF NOT EXISTS idx_agent_performance_agent ON agent_performance(agent_name);
CREATE INDEX IF NOT EXISTS idx_learning_insights_project ON learning_insights(project_id);
CREATE INDEX IF NOT EXISTS idx_learning_insights_category ON learning_insights(category);
CREATE INDEX IF NOT EXISTS idx_experiments_status ON experiments(status);
CREATE INDEX IF NOT EXISTS idx_threshold_evolution_param ON threshold_evolution(parameter_name);

-- ============================================================================
-- VIEWS: Useful analytics queries
-- ============================================================================

-- Project performance summary
CREATE VIEW IF NOT EXISTS v_project_performance AS
SELECT
    p.id,
    p.name,
    p.autonomy_score,
    p.test_coverage,
    p.verification_loops,
    p.total_duration_minutes,
    COUNT(DISTINCT i.id) as total_issues,
    AVG(i.complexity_score) as avg_complexity,
    SUM(CASE WHEN i.was_split THEN 1 ELSE 0 END) as split_count
FROM projects p
LEFT JOIN issues i ON p.id = i.project_id
GROUP BY p.id;

-- Pattern effectiveness
CREATE VIEW IF NOT EXISTS v_pattern_effectiveness AS
SELECT
    p.id,
    p.name,
    p.domain,
    p.times_used,
    p.success_rate,
    AVG(pu.duration_minutes) as avg_duration,
    COUNT(CASE WHEN pu.success = 1 THEN 1 END) * 1.0 / COUNT(*) as actual_success_rate
FROM patterns p
LEFT JOIN pattern_usage pu ON p.id = pu.pattern_id
GROUP BY p.id
HAVING p.times_used > 0;

-- Agent performance trends
CREATE VIEW IF NOT EXISTS v_agent_trends AS
SELECT
    agent_name,
    COUNT(DISTINCT project_id) as projects_used,
    AVG(success_rate) as avg_success_rate,
    AVG(avg_duration_seconds) as avg_duration,
    SUM(invocation_count) as total_invocations,
    SUM(errors_count) as total_errors
FROM agent_performance
GROUP BY agent_name;

-- Threshold accuracy
CREATE VIEW IF NOT EXISTS v_threshold_accuracy AS
SELECT
    i.complexity_category,
    COUNT(*) as total_issues,
    AVG(CASE WHEN i.actual_context IS NOT NULL
        THEN ABS(i.estimated_context - i.actual_context) * 1.0 / i.estimated_context
        ELSE NULL END) as avg_estimation_error,
    SUM(CASE WHEN i.was_split AND i.split_accuracy = 1 THEN 1 ELSE 0 END) * 1.0 /
        NULLIF(SUM(CASE WHEN i.was_split THEN 1 ELSE 0 END), 0) as split_accuracy_rate
FROM issues i
WHERE i.actual_context IS NOT NULL
GROUP BY i.complexity_category;
