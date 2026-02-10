# cf-deploy — Deploy Project to Environment

> **Slash command:** `/cf-deploy` or `/deploy`
> **Aliases:** `deploy`, `задеплой`, `деплой`
> **Category:** Deployment

## Description

Deploys a CodeFoundry project to a target environment with validation, testing, and rollback support.

## Usage

```
/cf-deploy [project-name] [environment] [options]
```

### Examples

```
# Interactive mode
/cf-deploy

# Deploy to staging
/cf-deploy my-delivery-bot staging

# Deploy to production with checks
/cf-deploy my-bot production --skip-tests=false --require-approval

# Dry run (no actual deployment)
/cf-deploy my-bot production --dry-run

# Natural language
"Deploy my-delivery-bot to production"
"Задеплой проект my-bot в production"
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project-name` | string | Yes | Project name |
| `environment` | string | No | Target environment (default: staging) |
| `--skip-tests` | flag | No | Skip pre-deployment tests (not recommended) |
| `--require-approval` | flag | No | Require manual approval for production |
| `--dry-run` | flag | No | Simulate deployment without changes |
| `--rollback-on-fail` | flag | No | Auto-rollback on deployment failure |
| `--notify` | flag | No | Send deployment notifications |

## Environments

### Development (dev)
- **Target:** Local development server
- **Pre-deploy:** None
- **Tests:** Optional
- **Approval:** None
- **Rollback:** Manual

### Staging
- **Target:** Staging server
- **Pre-deploy:** Build + lint
- **Tests:** Required (unit + integration)
- **Approval:** None
- **Rollback:** Auto on failure

### Production
- **Target:** Production server
- **Pre-deploy:** Full build + security scan
- **Tests:** Required (all)
- **Approval:** Required
- **Rollback:** Auto + manual option

## Workflow

### 1. Pre-Deployment Checks
```
🔍 Pre-deployment checks for: my-delivery-bot → production

✅ Git status: Clean (on main branch)
✅ Tests: Passing (87% coverage)
✅ Linting: No errors
✅ Security scan: No vulnerabilities
✅ Dependencies: Up to date
✅ Configuration: Valid
```

### 2. Build & Package
```
🔨 Building project...

[███████████] 100% ✅

✅ Build complete
   📦 Size: 45.2 MB
   🐳 Docker image: my-bot:1.0.0
   ⏱️  Build time: 2m 15s
```

### 3. Pre-Deployment Testing
```
🧪 Running pre-deployment tests...

   ✅ Unit tests: 145/145 passed
   ✅ Integration tests: 23/23 passed
   ✅ E2E tests: 8/10 passed
   ⚠️  2 E2E tests skipped (optional features)

📊 Coverage: 87% (target: 85%)
```

### 4. Approval (production only)
```
🔐 Production deployment requires approval

📋 Changes to deploy:
   • Commit: a1b2c3d
   • Branch: main
   • Files changed: 12
   • Lines added: 234
   • Lines removed: 87

Approve deployment? (yes/no/view-diff)
> yes
```

### 5. Deployment
```
🚀 Deploying to production...

[███████████] 100% ✅

✅ Deployment complete
   🌐 URL: https://my-bot.example.com
   📊 Health: Healthy
   ⏱️  Deploy time: 45s
   🔄 Rollback version: v0.9.5
```

### 6. Post-Deployment Verification
```
🏥 Post-deployment checks...

   ✅ Health check: OK
   ✅ Smoke tests: 5/5 passed
   ✅ Metrics: Normal
   ✅ Errors: None detected

🎉 Deployment successful!
```

### 7. Notification (if enabled)
```
📢 Deployment notification sent:
   • Slack: #deployments
   • Email: team@example.com
   • Status: ✅ Success
```

## Deployment Targets

### Docker Deployment
```bash
# Build and push Docker image
docker build -t my-bot:1.0.0 .
docker tag my-bot:1.0.0 registry.example.com/my-bot:1.0.0
docker push registry.example.com/my-bot:1.0.0

# Deploy to Kubernetes
kubectl set image deployment/my-bot \
  my-bot=registry.example.com/my-bot:1.0.0
```

### Docker Compose
```bash
# Update docker-compose.yml
# Deploy to server
docker-compose -f docker-compose.prod.yml up -d
```

### Serverless (AWS Lambda)
```bash
# Package and deploy
serverless deploy --stage production
```

### Traditional Server
```bash
# SSH deployment
ssh user@server "cd /app && git pull && npm run build && pm2 restart app"
```

## Rollback Procedure

### Automatic Rollback
```
❌ Deployment failed!

🔄 Rolling back to previous version...
   ✅ Rollback complete
   📦 Previous version: v0.9.5
   ⏱️  Rollback time: 12s
```

### Manual Rollback
```bash
/cf-deploy my-bot production --rollback-to=v0.9.5
```

## Configuration

Deployment settings in `.claude/settings.json`:

```json
{
  "cf-deploy": {
    "defaultEnvironment": "staging",
    "requireTests": true,
    "requireApproval": {
      "production": true,
      "staging": false,
      "dev": false
    },
    "autoRollback": {
      "production": true,
      "staging": true,
      "dev": false
    },
    "notification": {
      "enabled": true,
      "channels": ["slack", "email"],
      "onSuccess": true,
      "onFailure": true
    }
  }
}
```

## Deployment Status

Check deployment status:
```bash
# Current deployment
/cf-status my-bot --deployment

# Deployment history
/cf-status my-bot --deploy-history

# Rollback versions
/cf-status my-bot --rollback-versions
```

## Error Handling

| Error | Solution |
|-------|----------|
| `TESTS_FAILED` | Fix failing tests or use `--skip-tests` (not recommended) |
| `BUILD_FAILED` | Check build logs, fix errors |
| `CONTAINER_EXISTS` | Stop existing container first |
| `APPROVAL_REQUIRED` | Provide approval or deploy to staging first |
| `ROLLBACK_FAILED` | Manual intervention required |
| `HEALTH_CHECK_FAILED` | Check application logs, fix issues |

## Integration with Gateway

```javascript
// WebSocket message
{
  type: 'chat',
  content: 'Задеплой my-bot в production'
}

// Gateway → Command Executor
{
  intent: 'deploy',
  params: {
    project_name: 'my-bot',
    environment: 'production'
  }
}

// Progress streaming
{
  type: 'progress',
  stage: 'deploying',
  progress: 60,
  message: 'Deploying containers...'
}
```

## Pre-Deployment Checklist

Before deploying to production:

- [ ] All tests passing
- [ ] Code reviewed
- [ ] Security scan clean
- [ ] Dependencies up to date
- [ ] Configuration validated
- [ ] Backups created
- [ ] Rollback plan ready
- [ ] Team notified
- [ ] Maintenance window scheduled (if needed)
- [ ] Monitoring configured

## Post-Deployment Checklist

After deployment:

- [ ] Health checks passing
- [ ] Smoke tests passing
- [ ] Metrics normal
- [ ] Errors monitored
- [ ] User feedback collected
- [ ] Documentation updated
- [ ] Team notified of success

## Related Commands

- `/cf-new` — Create new project
- `/cf-status` — Check deployment status
- `/cf-rollback` — Rollback deployment

## Implementation Notes

This command integrates with:
- `scripts/deploy.sh` — Core deployment script
- `openclaw/gateway/` — AI-First deployment via WebSocket
- `scripts/health-check.sh` — Post-deployment verification
- `.github/workflows/` — CI/CD pipelines

---

**Version:** 1.0.0
**Last updated:** 2025-02-02
