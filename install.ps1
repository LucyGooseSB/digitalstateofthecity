# WorkSpaceFramework Installer for PowerShell
# Usage:
#   .\install.ps1 -TargetDir "C:\path\to\project"   # direct install
#   .\install.ps1                                     # interactive (prompts for directory)
#   irm https://raw.githubusercontent.com/.../install.ps1 | iex  # remote install
#
# Supports two modes:
#   Local:  Script runs from a cloned framework repo — uses local files
#   Remote: Script piped from URL — clones the repo to a temp directory

param(
    [string]$TargetDir
)

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/southbendin/WorkSpaceFramework.git"
$RemoteMode = $false
$TempDir = $null

# --- Mode detection ---
# When piped via `irm | iex`, $MyInvocation.MyCommand.Path is empty
if (-not $MyInvocation.MyCommand.Path) {
    $RemoteMode = $true
    Write-Host "WorkSpaceFramework Remote Installer" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "Fetching latest framework from GitHub..." -ForegroundColor Yellow
    Write-Host ""

    $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "wsf-install-$(Get-Random)"
    git clone --depth 1 $REPO_URL $TempDir 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to clone framework repository." -ForegroundColor Red
        Write-Host "Check your network connection and that git is installed."
        exit 1
    }
    $FrameworkDir = $TempDir
} else {
    $FrameworkDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

# --- Cleanup handler for remote mode ---
function Remove-TempDir {
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    }
}

try {

# --- Target directory resolution ---
if (-not $TargetDir) {
    # Interactive mode: prompt for target directory
    Write-Host "No target directory specified." -ForegroundColor Yellow
    Write-Host ""

    # Try folder picker dialog first (Windows Forms)
    $usedPicker = $false
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = "Select the project directory to install WorkSpaceFramework into"
        $dialog.ShowNewFolderButton = $true
        $result = $dialog.ShowDialog()
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $TargetDir = $dialog.SelectedPath
            $usedPicker = $true
        } else {
            Write-Host "Installation cancelled." -ForegroundColor Yellow
            exit 0
        }
    } catch {
        # Windows Forms not available (e.g., PowerShell Core on Linux) — fall back to text prompt
    }

    if (-not $usedPicker) {
        $TargetDir = Read-Host "Enter the target project directory"
        if (-not $TargetDir) {
            Write-Host "No directory provided. Installation cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
}

# Validate target directory exists
if (-not (Test-Path $TargetDir -PathType Container)) {
    Write-Host "Error: Target directory '$TargetDir' does not exist." -ForegroundColor Red
    Write-Host "Create it first, then re-run the installer."
    exit 1
}

$TargetDir = (Resolve-Path $TargetDir).Path

# --- Confirmation ---
Write-Host ""
Write-Host "WorkSpaceFramework Installer" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
if (-not $RemoteMode) {
    Write-Host "Framework: $FrameworkDir"
}
Write-Host "Target:    $TargetDir"
Write-Host ""

$confirm = Read-Host "Install WorkSpaceFramework into $TargetDir? [Y/n]"
if ($confirm -and $confirm -notmatch '^[Yy]') {
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    exit 0
}

# --- Guards ---
$resolvedFramework = (Resolve-Path $FrameworkDir).Path
if ($resolvedFramework -eq $TargetDir) {
    Write-Host "Error: Cannot install framework into itself." -ForegroundColor Red
    exit 1
}

if (Test-Path "$TargetDir\.claude\rules\roles-and-governance.md") {
    Write-Host "Framework already installed in $TargetDir" -ForegroundColor Yellow
    Write-Host "Use '/setup update' from within the project to pull updates."
    exit 1
}

# --- Create directory structure ---
Write-Host "Creating directory structure..."
$dirs = @(
    ".claude\rules",
    ".claude\commands",
    ".claude\skills",
    ".claude\templates\project-rules",
    ".claude\work\items",
    ".claude\work\archive",
    ".claude\artifacts",
    ".claude\temp",
    ".claude\memory",
    ".claude\voice-inbox",
    ".claude\providers",
    ".claude\patterns\sessions",
    ".claude\patterns\insights",
    ".claude\scripts"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path "$TargetDir\$dir" -Force | Out-Null
}

# Copy rules
Write-Host "Copying rules (12 files)..."
Copy-Item "$FrameworkDir\.claude\rules\*.md" "$TargetDir\.claude\rules\" -Force

# Copy commands
Write-Host "Copying commands (18 files)..."
Copy-Item "$FrameworkDir\.claude\commands\*.md" "$TargetDir\.claude\commands\" -Force

# Copy providers
Write-Host "Copying providers (4 files)..."
Copy-Item "$FrameworkDir\.claude\providers\*.md" "$TargetDir\.claude\providers\" -Force

# Copy skills (preserve directory structure)
Write-Host "Copying skills (13 skills + registry + context)..."
Get-ChildItem "$FrameworkDir\.claude\skills" -Directory | ForEach-Object {
    $skillName = $_.Name
    New-Item -ItemType Directory -Path "$TargetDir\.claude\skills\$skillName" -Force | Out-Null
    Copy-Item "$($_.FullName)\*" "$TargetDir\.claude\skills\$skillName\" -Recurse -Force
}
Copy-Item "$FrameworkDir\.claude\skills\REGISTRY.md" "$TargetDir\.claude\skills\" -Force
Copy-Item "$FrameworkDir\.claude\skills\CONTEXT.md" "$TargetDir\.claude\skills\" -Force

# Copy templates
Write-Host "Copying templates (7 files)..."
Copy-Item "$FrameworkDir\.claude\templates\*.template" "$TargetDir\.claude\templates\" -Force
Copy-Item "$FrameworkDir\.claude\templates\project-rules\*.template" "$TargetDir\.claude\templates\project-rules\" -Force

# Copy scripts
Write-Host "Copying scripts..."
Copy-Item "$FrameworkDir\.claude\scripts\*" "$TargetDir\.claude\scripts\" -Force

# BOARD.md is generated from item files on first /work use — not copied

# Create gitkeep files
$gitkeeps = @(
    ".claude\work\items\.gitkeep",
    ".claude\work\archive\.gitkeep",
    ".claude\artifacts\.gitkeep",
    ".claude\temp\.gitkeep",
    ".claude\memory\.gitkeep",
    ".claude\voice-inbox\.gitkeep",
    ".claude\patterns\sessions\.gitkeep",
    ".claude\patterns\insights\.gitkeep"
)
foreach ($gk in $gitkeeps) {
    if (-not (Test-Path "$TargetDir\$gk")) {
        New-Item -ItemType File -Path "$TargetDir\$gk" -Force | Out-Null
    }
}

# Add gitignore entries
if (Test-Path "$TargetDir\.gitignore") {
    $gitignore = Get-Content "$TargetDir\.gitignore" -Raw -ErrorAction SilentlyContinue
    if ($gitignore -notmatch "\.claude/temp/") {
        Add-Content "$TargetDir\.gitignore" "`n# Claude Code framework`n.claude/temp/`n.claude/voice-inbox/*.txt`n.claude/voice-inbox/*.md`n!.claude/voice-inbox/.gitkeep`n.claude/work/BOARD.md`n.claude/patterns/sessions/*.jsonl`n!.claude/patterns/sessions/.gitkeep`n.claude/patterns/PATTERNS.md"
        Write-Host "Updated .gitignore"
    }
}

# Copy settings if none exist
if (-not (Test-Path "$TargetDir\.claude\settings.local.json")) {
    $settings = Get-Content "$FrameworkDir\.claude\templates\settings.local.json.template" -Raw
    $settings = $settings -replace '\{\{PROJECT_PATH\}\}', ($TargetDir -replace '\\', '/')
    # Remove the ADDITIONAL_PERMISSIONS placeholder line (local provider default)
    $settings = $settings -replace '(?m)^\s*\{\{ADDITIONAL_PERMISSIONS\}\}\s*\r?\n', ''
    Set-Content "$TargetDir\.claude\settings.local.json" $settings -NoNewline
    Write-Host "Created settings.local.json (local provider — run /setup to add provider permissions)"
} else {
    Write-Host "Kept existing settings.local.json"
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "Framework installed successfully!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files copied:"
Write-Host "  .claude\rules\           (12 behavioral rules)"
Write-Host "  .claude\commands\        (18 slash commands)"
Write-Host "  .claude\providers\       (4 work provider files)"
Write-Host "  .claude\skills\          (13 expert skills + registry + context)"
Write-Host "  .claude\templates\       (7 project templates)"
Write-Host "  .claude\work\            (work tracking — BOARD.md generated on first use)"
Write-Host "  .claude\patterns\        (interaction analytics — sessions + insights)"
Write-Host "  .claude\scripts\         (statusline monitor)"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open Claude Code in $TargetDir"
Write-Host "  2. Run /setup to start the discovery interview"
Write-Host "  3. Claude interviews you about the project and generates your roadmap"
Write-Host ""

} finally {
    # Clean up temp directory in remote mode (both success and failure)
    Remove-TempDir
}
