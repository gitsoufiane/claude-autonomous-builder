---
id: anti-hardcoded-secrets-001
name: Hardcoded Secrets
severity: CRITICAL
times_caught: 0
detection_method: regex
created_at: 2026-01-31
---

# Anti-Pattern: Hardcoded Secrets

## Description

Embedding sensitive credentials, API keys, tokens, or secrets directly in source code instead of using environment variables or secure secret management systems.

## Severity: CRITICAL

**Why Critical:**
- Secrets committed to git are **permanently** in history (even after deletion)
- Public repositories expose secrets to the entire internet
- Automated bots scan GitHub for exposed secrets within minutes
- Credential rotation requires code changes and redeployment

## Detection Methods

### Regex Patterns

```bash
# API keys
grep -rE "(api[_-]?key|apikey)\s*=\s*['\"][a-zA-Z0-9_\-]{20,}['\"]" src/

# JWT secrets
grep -rE "(jwt[_-]?secret|secret[_-]?key)\s*=\s*['\"].+['\"]" src/

# Database credentials
grep -rE "(password|pwd|passwd)\s*=\s*['\"].+['\"]" src/

# AWS keys
grep -rE "(aws[_-]?access[_-]?key|aws[_-]?secret)" src/

# Generic secrets
grep -rE "(secret|token|password)\s*=\s*['\"][^$]" src/
```

### AST-Based Detection (TypeScript/JavaScript)

```javascript
// Detect: const secret = "literal-value"
// Pattern: VariableDeclaration with Identifier matching /secret|key|token|password/i
//          and Literal initializer (not EnvironmentVariable)
```

### Tools

- **git-secrets**: Prevents committing secrets to git
- **truffleHog**: Scans git history for secrets
- **detect-secrets**: Pre-commit hook for secret detection
- **GitHub Secret Scanning**: Automatic scanning for public repos

## Examples of This Anti-Pattern

### ❌ Example 1: Hardcoded API Key

```typescript
// WRONG
const openaiApiKey = 'sk-proj-abc123def456ghi789jkl'

async function callOpenAI(prompt: string) {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    headers: {
      'Authorization': `Bearer ${openaiApiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ model: 'gpt-4', messages: [{ role: 'user', content: prompt }] })
  })
  return response.json()
}
```

**Issues:**
- API key visible in source code
- If committed to git, it's permanently in history
- No way to rotate key without code change

### ❌ Example 2: Hardcoded Database Password

```typescript
// WRONG
const dbConfig = {
  host: 'localhost',
  port: 5432,
  username: 'admin',
  password: 'SuperSecret123!', // Hardcoded password
  database: 'myapp'
}
```

### ❌ Example 3: Hardcoded JWT Secret

```typescript
// WRONG
const jwtSecret = 'my-super-secret-jwt-key'

export const generateToken = (payload: any) => {
  return jwt.sign(payload, jwtSecret, { expiresIn: '1h' })
}
```

### ❌ Example 4: Config File with Secrets

```json
// config.json - WRONG
{
  "stripe": {
    "secretKey": "sk_live_51Abc123..."
  },
  "sendgrid": {
    "apiKey": "SG.abc123..."
  }
}
```

## Correct Implementation

### ✅ Example 1: Environment Variables

```typescript
// CORRECT
const openaiApiKey = process.env.OPENAI_API_KEY

if (!openaiApiKey) {
  throw new Error('OPENAI_API_KEY environment variable is not set')
}

async function callOpenAI(prompt: string) {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    headers: {
      'Authorization': `Bearer ${openaiApiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ model: 'gpt-4', messages: [{ role: 'user', content: prompt }] })
  })
  return response.json()
}
```

**Best Practices:**
1. ✅ Read from `process.env`
2. ✅ Fail fast if not set (startup validation)
3. ✅ Document required env vars in `.env.example`

### ✅ Example 2: .env File (Development)

```bash
# .env (add to .gitignore!)
OPENAI_API_KEY=sk-proj-abc123def456ghi789jkl
DATABASE_PASSWORD=SuperSecret123!
JWT_SECRET=generated-with-openssl-rand-base64-32
STRIPE_SECRET_KEY=sk_live_51Abc123...
```

```javascript
// Load environment variables (e.g., using dotenv)
import 'dotenv/config'

const config = {
  openai: {
    apiKey: process.env.OPENAI_API_KEY!
  },
  database: {
    password: process.env.DATABASE_PASSWORD!
  },
  jwt: {
    secret: process.env.JWT_SECRET!
  }
}
```

**Critical:**
- ✅ Add `.env` to `.gitignore`
- ✅ Create `.env.example` with placeholder values
- ✅ Document all required env vars in README

### ✅ Example 3: Secret Management (Production)

```typescript
// Use a secret management service in production
import { SecretManagerServiceClient } from '@google-cloud/secret-manager'

async function getSecret(secretName: string): Promise<string> {
  const client = new SecretManagerServiceClient()
  const [version] = await client.accessSecretVersion({
    name: `projects/${PROJECT_ID}/secrets/${secretName}/versions/latest`
  })
  return version.payload?.data?.toString() || ''
}

// Usage
const jwtSecret = await getSecret('jwt-secret')
```

**Production Options:**
- AWS Secrets Manager
- Google Cloud Secret Manager
- Azure Key Vault
- HashiCorp Vault
- Doppler
- 1Password Secrets Automation

## Remediation Steps

### If Secret Already Committed

**⚠️ DO NOT just delete the file and commit!**

Secrets remain in git history. You must:

1. **Immediately Rotate the Secret**
   - Generate new API key/password
   - Update production systems with new secret
   - Revoke old secret

2. **Remove from Git History**
   ```bash
   # Use BFG Repo-Cleaner (easier)
   brew install bfg
   bfg --replace-text passwords.txt repo.git
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive

   # Or use git-filter-repo
   git filter-repo --path secrets.txt --invert-paths
   ```

3. **Force Push (if safe)**
   ```bash
   git push --force-with-lease
   ```

4. **Notify Team**
   - Inform all developers of the force push
   - Ensure everyone re-clones the repository

### Prevention

1. **Pre-commit Hooks**
   ```bash
   # Install git-secrets
   brew install git-secrets

   # Install hooks
   git secrets --install
   git secrets --register-aws

   # Add custom patterns
   git secrets --add 'sk-proj-[a-zA-Z0-9]{32,}'
   git secrets --add 'sk_live_[a-zA-Z0-9]{32,}'
   ```

2. **CI/CD Checks**
   ```yaml
   # .github/workflows/security.yml
   name: Security Scan
   on: [push, pull_request]
   jobs:
     secrets-scan:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: truffleHog
           uses: trufflesecurity/trufflehog@main
           with:
             path: ./
             base: ${{ github.event.repository.default_branch }}
             head: HEAD
   ```

3. **IDE Integration**
   - GitGuardian extension for VS Code
   - IntelliJ Secret Detection plugin

## Real-World Impact

### Case Study: Uber 2016 Breach

- **What:** Private AWS keys committed to GitHub
- **Impact:** 57 million user records stolen
- **Cost:** $148 million settlement

### Case Study: Codecov 2021

- **What:** Exposed Docker image with secrets
- **Impact:** Hundreds of customer environments compromised
- **Cost:** Massive reputational damage

## Statistics

- **GitHub:** Detects 10+ million secrets per year
- **Automated Bots:** Scan within 5 minutes of public commit
- **Average Time to Exploit:** < 1 hour for exposed cloud credentials

## Related Patterns

- `environment-configuration` - Proper config management
- `secret-rotation` - Regular credential rotation
- `least-privilege-access` - Minimize secret permissions

## Automated Detection

This anti-pattern is automatically detected by:
- **security-reviewer** agent (CRITICAL severity)
- Pre-commit hooks (if configured)
- GitHub Secret Scanning
- CI/CD security scans

## Version History

- **v1.0** (2026-01-31): Initial anti-pattern documented

## References

- [OWASP: Sensitive Data Exposure](https://owasp.org/www-project-top-ten/2017/A3_2017-Sensitive_Data_Exposure)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning)
- [12-Factor App: Config](https://12factor.net/config)
