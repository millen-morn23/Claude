# Installs Claude Code, the Firecrawl MCP and skills, and this repo's skills.
# Right-click this file and choose "Run with PowerShell".

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User') + ";$HOME\.local\bin"
}

function Step($text) { Write-Host "`n=== $text ===" -ForegroundColor Cyan }

Step "1/5 Installing Git and Node.js (skipped if already installed)"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
}
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
}
Refresh-Path

Step "2/5 Installing Claude Code"
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    irm https://claude.ai/install.ps1 | iex
}
Refresh-Path

Step "3/5 Adding the Firecrawl MCP (a browser window opens to sign in)"
claude mcp add --scope user --transport http firecrawl https://mcp.firecrawl.dev/v2/mcp-oauth
claude mcp login firecrawl

Step "4/5 Installing Firecrawl skills"
npx -y skills add firecrawl/skills --skill firecrawl-build -g -y
npx -y firecrawl-cli@latest init --all --browser

Step "5/5 Downloading your repo"
Set-Location "$HOME\Documents"
if (-not (Test-Path Claude)) {
    git clone https://github.com/millen-morn23/Claude.git
}
Set-Location Claude
git fetch origin claude/beautiful-lovelace-u0oco8
git checkout claude/beautiful-lovelace-u0oco8

Write-Host "`nAll done. Starting Claude - type /mcp and /plugin to check everything is there." -ForegroundColor Green
claude
Read-Host "Press Enter to close"
