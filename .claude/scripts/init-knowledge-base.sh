#!/usr/bin/env bash
# Initialize the Orchestrator Knowledge Base
# Creates SQLite database and pattern library structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_DIR="${SCRIPT_DIR}/../knowledge"
DB_FILE="${KNOWLEDGE_DIR}/orchestrator.db"
SCHEMA_FILE="${KNOWLEDGE_DIR}/schema.sql"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Initializing Orchestrator Knowledge Base...${NC}"

# Create knowledge directory structure
echo "Creating directory structure..."
mkdir -p "${KNOWLEDGE_DIR}/patterns"
mkdir -p "${KNOWLEDGE_DIR}/anti-patterns"
mkdir -p "${KNOWLEDGE_DIR}/experiments"

# Check if SQLite is available
if ! command -v sqlite3 &> /dev/null; then
    echo -e "${RED}ERROR: sqlite3 is not installed${NC}"
    echo "Please install SQLite 3:"
    echo "  macOS: brew install sqlite3"
    echo "  Ubuntu/Debian: sudo apt-get install sqlite3"
    echo "  CentOS/RHEL: sudo yum install sqlite"
    exit 1
fi

# Create or update database
if [ -f "${DB_FILE}" ]; then
    echo -e "${YELLOW}Database already exists at ${DB_FILE}${NC}"
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Backing up existing database..."
        cp "${DB_FILE}" "${DB_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        rm "${DB_FILE}"
    else
        echo "Skipping database creation."
        exit 0
    fi
fi

echo "Creating database from schema..."
sqlite3 "${DB_FILE}" < "${SCHEMA_FILE}"

# Verify database creation
if [ ! -f "${DB_FILE}" ]; then
    echo -e "${RED}ERROR: Failed to create database${NC}"
    exit 1
fi

# Test database connectivity
echo "Testing database connectivity..."
VERSION=$(sqlite3 "${DB_FILE}" "SELECT sqlite_version();")
echo -e "${GREEN}✓ SQLite version: ${VERSION}${NC}"

# Count tables
TABLE_COUNT=$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM sqlite_master WHERE type='table';")
echo -e "${GREEN}✓ Created ${TABLE_COUNT} tables${NC}"

# Create index.json for pattern library
INDEX_FILE="${KNOWLEDGE_DIR}/index.json"
if [ ! -f "${INDEX_FILE}" ]; then
    echo "Creating pattern index..."
    cat > "${INDEX_FILE}" << 'EOF'
{
  "version": "1.0.0",
  "last_updated": null,
  "patterns": [],
  "anti_patterns": [],
  "stats": {
    "total_patterns": 0,
    "total_anti_patterns": 0,
    "total_projects": 0
  }
}
EOF
    echo -e "${GREEN}✓ Created pattern index${NC}"
fi

# Create .gitkeep files to preserve empty directories
touch "${KNOWLEDGE_DIR}/patterns/.gitkeep"
touch "${KNOWLEDGE_DIR}/anti-patterns/.gitkeep"
touch "${KNOWLEDGE_DIR}/experiments/.gitkeep"

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Knowledge Base Initialization Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Database: ${DB_FILE}"
echo "Patterns: ${KNOWLEDGE_DIR}/patterns/"
echo "Anti-patterns: ${KNOWLEDGE_DIR}/anti-patterns/"
echo ""
echo "Next steps:"
echo "  1. Configure MCP servers in .claude/.mcp.json"
echo "  2. Run your first project: /orchestrator 'Your project idea'"
echo "  3. Review learning report: docs/LEARNING-REPORT.md"
echo ""
echo -e "${YELLOW}Note: Install MCP servers with:${NC}"
echo "  npm install -g @modelcontextprotocol/server-sqlite"
echo "  npm install -g @modelcontextprotocol/server-filesystem"
