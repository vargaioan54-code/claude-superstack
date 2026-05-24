# ═══════════════════════════════════════════════════════════════
#   CLAUDE CODE SUPERSTACK - Windows Installer
#   Run in PowerShell as Administrator:
#     Set-ExecutionPolicy Bypass -Scope Process -Force
#     .\install-claude-superstack.ps1
# ═══════════════════════════════════════════════════════════════

$ErrorActionPreference = "Continue"
Write-Host ""
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CLAUDE CODE SUPERSTACK INSTALLER (Windows)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ─── 1. Node.js (prerequisite) ────────────────────────────────
Write-Host "[1/6] Checking Node.js..." -ForegroundColor Yellow
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Node.js LTS via winget..." -ForegroundColor Gray
    winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "  Node.js found: $(node --version)" -ForegroundColor Green
}

# ─── 2. Git + GitHub CLI ──────────────────────────────────────
Write-Host "[2/6] Checking Git + gh..." -ForegroundColor Yellow
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    winget install -e --id GitHub.cli --accept-source-agreements --accept-package-agreements
}

# ─── 3. Claude Code CLI ───────────────────────────────────────
Write-Host "[3/6] Installing Claude Code..." -ForegroundColor Yellow
npm install -g @anthropic-ai/claude-code

# ─── 4. MCP Servers (REAL, official) ──────────────────────────
Write-Host "[4/6] Adding MCP servers..." -ForegroundColor Yellow

# Sequential thinking - chain-of-thought reasoning
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking

# Context7 - up-to-date library docs (Upstash)
claude mcp add context7 -- npx -y @upstash/context7-mcp

# Playwright - browser automation
claude mcp add playwright -- npx -y @playwright/mcp@latest

# Fetch - HTTP requests + URL content
claude mcp add fetch -- npx -y @modelcontextprotocol/server-fetch

# Memory - persistent knowledge graph
claude mcp add memory -- npx -y @modelcontextprotocol/server-memory

# Filesystem - sandboxed file access (Desktop scope)
$desktop = [Environment]::GetFolderPath("Desktop")
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem $desktop

# GitHub - repos, issues, PRs (needs GITHUB_TOKEN env var to auth)
claude mcp add github -- npx -y @modelcontextprotocol/server-github

# Claude Flow - swarm orchestration + 90+ tools (ruvnet)
claude mcp add claude-flow -- npx -y claude-flow@alpha mcp start

# ─── 5. Global CLAUDE.md config ───────────────────────────────
Write-Host "[5/6] Writing global CLAUDE.md..." -ForegroundColor Yellow
$claudeDir = "$env:USERPROFILE\.claude"
if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }

@'
# Claude Global Config

## Mode
Concise. Action-first. No fluff. Read before edit. Edit before write.

## Available MCP Servers
- sequential-thinking — chain-of-thought reasoning
- context7 — fresh library/framework docs (use BEFORE writing code with external libs)
- playwright — browser automation, screenshots, scraping
- fetch — HTTP requests, URL content
- memory — persistent knowledge graph across sessions
- filesystem — sandboxed file access
- github — repos, issues, PRs (needs $env:GITHUB_TOKEN)
- claude-flow — swarm orchestration, 90+ tools

## Rules
- Never commit secrets. Validate at boundaries.
- Prefer dedicated tools over Bash (Read/Edit/Grep/Glob).
- For UI/frontend changes: start dev server, test in browser before reporting done.
- For unfamiliar libraries: query context7 first.

## Quick Commands
- claude mcp list                    — show registered MCP servers
- claude mcp remove <name>           — remove an MCP server
- npx claude-flow@alpha --help       — swarm tools
'@ | Out-File -FilePath "$claudeDir\CLAUDE.md" -Encoding utf8

# ─── 6. Verify ────────────────────────────────────────────────
Write-Host "[6/6] Verifying..." -ForegroundColor Yellow
Write-Host ""
Write-Host "════ Registered MCP servers ════" -ForegroundColor Cyan
claude mcp list

Write-Host ""
Write-Host "════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  DONE!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart PowerShell" -ForegroundColor White
Write-Host "  2. Run: claude" -ForegroundColor White
Write-Host "  3. Login with your Anthropic account" -ForegroundColor White
Write-Host ""
Write-Host "Optional (for GitHub MCP):" -ForegroundColor Yellow
Write-Host "  gh auth login" -ForegroundColor White
Write-Host "  [Environment]::SetEnvironmentVariable('GITHUB_TOKEN', (gh auth token), 'User')" -ForegroundColor White
Write-Host ""
