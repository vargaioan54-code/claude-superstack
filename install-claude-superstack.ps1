# ═══════════════════════════════════════════════════════════════
#   CLAUDE CODE SUPERSTACK - Windows Installer
#   Run in PowerShell as Administrator:
#     Set-ExecutionPolicy Bypass -Scope Process -Force
#     iwr -useb https://raw.githubusercontent.com/vargaioan54-code/claude-superstack/main/install-claude-superstack.ps1 | iex
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
    winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "  Node.js found: $(node --version)" -ForegroundColor Green
}

# ─── 2. Git + GitHub CLI ──────────────────────────────────────
Write-Host "[2/6] Checking Git + gh..." -ForegroundColor Yellow
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements --silent
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    winget install -e --id GitHub.cli --accept-source-agreements --accept-package-agreements --silent
}
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ─── 3. Claude Code CLI (optional — works alongside VSCode extension) ─
Write-Host "[3/6] Installing Claude Code CLI..." -ForegroundColor Yellow
if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm install -g @anthropic-ai/claude-code 2>&1 | Out-Null
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        Write-Host "  Claude Code CLI installed: $(claude --version)" -ForegroundColor Green
    } else {
        Write-Host "  Claude Code CLI install completed (restart shell to use)" -ForegroundColor Gray
    }
} else {
    Write-Host "  npm not found - skipping (Node.js install pending PATH refresh)" -ForegroundColor Yellow
}

# ─── 4. Register MCP Servers ──────────────────────────────────
Write-Host "[4/6] Registering MCP servers..." -ForegroundColor Yellow

$desktop = [Environment]::GetFolderPath("Desktop")
$useCLI = $false
if (Get-Command claude -ErrorAction SilentlyContinue) { $useCLI = $true }

if ($useCLI) {
    Write-Host "  Using 'claude mcp add' (CLI mode)..." -ForegroundColor Gray
    claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
    claude mcp add context7 -- npx -y @upstash/context7-mcp
    claude mcp add playwright -- npx -y @playwright/mcp@latest
    claude mcp add fetch -- npx -y @modelcontextprotocol/server-fetch
    claude mcp add memory -- npx -y @modelcontextprotocol/server-memory
    claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem $desktop
    claude mcp add github -- npx -y @modelcontextprotocol/server-github
    claude mcp add claude-flow -- npx -y claude-flow@alpha mcp start
} else {
    Write-Host "  No 'claude' CLI found — writing ~/.claude.json directly (VSCode extension mode)..." -ForegroundColor Gray
    $cfgPath = "$env:USERPROFILE\.claude.json"
    if (Test-Path $cfgPath) {
        Copy-Item $cfgPath "$cfgPath.bak" -Force
        $c = Get-Content $cfgPath -Raw | ConvertFrom-Json
    } else {
        if (-not (Test-Path "$env:USERPROFILE\.claude")) { New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude" -Force | Out-Null }
        $c = [PSCustomObject]@{}
    }

    $mcps = @{
        "sequential-thinking" = @{ type = "stdio"; command = "npx"; args = @("-y", "@modelcontextprotocol/server-sequential-thinking") }
        "context7"            = @{ type = "stdio"; command = "npx"; args = @("-y", "@upstash/context7-mcp") }
        "playwright"          = @{ type = "stdio"; command = "npx"; args = @("-y", "@playwright/mcp@latest") }
        "fetch"               = @{ type = "stdio"; command = "npx"; args = @("-y", "@modelcontextprotocol/server-fetch") }
        "memory"              = @{ type = "stdio"; command = "npx"; args = @("-y", "@modelcontextprotocol/server-memory") }
        "filesystem"          = @{ type = "stdio"; command = "npx"; args = @("-y", "@modelcontextprotocol/server-filesystem", $desktop) }
        "github"              = @{ type = "stdio"; command = "npx"; args = @("-y", "@modelcontextprotocol/server-github") }
        "claude-flow"         = @{ type = "stdio"; command = "npx"; args = @("-y", "claude-flow@alpha", "mcp", "start") }
    }
    $c | Add-Member -NotePropertyName mcpServers -NotePropertyValue $mcps -Force
    $c | ConvertTo-Json -Depth 20 | Set-Content $cfgPath -Encoding UTF8
    Write-Host "  Wrote 8 MCP servers to $cfgPath" -ForegroundColor Green
}

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
- claude mcp list                    — show registered MCP servers (CLI)
- npx claude-flow@alpha --help       — swarm tools
- gh auth status                     — verify GitHub auth
'@ | Out-File -FilePath "$claudeDir\CLAUDE.md" -Encoding utf8

# ─── 6. Summary ───────────────────────────────────────────────
Write-Host "[6/6] Done!" -ForegroundColor Yellow
Write-Host ""
Write-Host "════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  INSTALL COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart PowerShell (and VSCode if you use the extension)" -ForegroundColor White
Write-Host "  2. CLI users: run 'claude' then 'claude mcp list'" -ForegroundColor White
Write-Host "  3. VSCode users: reload window — MCP servers load automatically" -ForegroundColor White
Write-Host ""
Write-Host "Optional (for GitHub MCP auth):" -ForegroundColor Yellow
Write-Host "  gh auth login" -ForegroundColor White
Write-Host "  [Environment]::SetEnvironmentVariable('GITHUB_TOKEN', (gh auth token), 'User')" -ForegroundColor White
Write-Host ""
Write-Host "Repo: https://github.com/vargaioan54-code/claude-superstack" -ForegroundColor Cyan
Write-Host ""
