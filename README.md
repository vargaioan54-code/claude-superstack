# Claude Code Superstack

One-click installer for a powerful Claude Code setup on Windows.

## What it installs

| Layer  | Tool                       | Role                                          |
|--------|----------------------------|-----------------------------------------------|
| Base   | Node.js LTS                | Runtime (via winget)                          |
| Base   | Git + GitHub CLI           | Version control                               |
| CLI    | `@anthropic-ai/claude-code`| Official Claude Code CLI                      |
| MCP    | sequential-thinking        | Chain-of-thought reasoning                    |
| MCP    | context7 (Upstash)         | Fresh library/framework docs                  |
| MCP    | playwright                 | Browser automation, screenshots               |
| MCP    | fetch                      | HTTP requests, URL content                    |
| MCP    | memory                     | Persistent knowledge graph                    |
| MCP    | filesystem                 | Sandboxed file access (Desktop scope)         |
| MCP    | github                     | Repos, issues, PRs                            |
| MCP    | claude-flow                | Swarm orchestration, 90+ tools (ruvnet)       |
| Config | `~/.claude/CLAUDE.md`      | Global instructions                           |

## Install (Windows, one-liner)

Open **PowerShell as Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr -useb https://raw.githubusercontent.com/REPO_URL/main/install-claude-superstack.ps1 | iex
```

The real URL will be in `INJECTIE-COPY-PASTE.txt` after this repo is published.

## Manual install

1. Download `install-claude-superstack.ps1`
2. Open PowerShell as Administrator
3. Run:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\install-claude-superstack.ps1
   ```

## After install

```powershell
claude            # start Claude Code
claude mcp list   # verify 8 MCP servers registered
```

## Troubleshooting

See `INJECTIE-COPY-PASTE.txt` for common issues.
