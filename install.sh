#!/usr/bin/env bash
# WorkSpaceFramework Installer
# Usage:
#   bash /path/to/install.sh /path/to/project   # direct install
#   bash /path/to/install.sh                     # interactive (prompts for directory)
#   curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash  # remote install
#
# Supports two modes:
#   Local:  Script runs from a cloned framework repo — uses local files
#   Remote: Script piped from URL — clones the repo to a temp directory

set -e

REPO_URL="https://github.com/southbendin/WorkSpaceFramework.git"
REMOTE_MODE=false
TEMP_DIR=""

# --- Cleanup handler for remote mode ---
cleanup() {
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

# --- Mode detection ---
# When piped via `curl | bash`, $0 is typically "bash" or "/bin/bash" and
# dirname resolves to a system path, not the framework repo
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"

if [ ! -f "$SCRIPT_DIR/install.sh" ] || [ "$0" = "bash" ] || [ "$0" = "/bin/bash" ] || [ "$0" = "sh" ] || [ "$0" = "/bin/sh" ]; then
  REMOTE_MODE=true
  echo "WorkSpaceFramework Remote Installer"
  echo "===================================="
  echo "Fetching latest framework from GitHub..."
  echo ""

  TEMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'wsf-install')"
  if ! git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null; then
    echo "Error: Failed to clone framework repository."
    echo "Check your network connection and that git is installed."
    exit 1
  fi
  FRAMEWORK_DIR="$TEMP_DIR"
else
  FRAMEWORK_DIR="$SCRIPT_DIR"
fi

# --- Target directory resolution ---
TARGET_DIR="${1:-}"

if [ -z "$TARGET_DIR" ]; then
  # Interactive mode: prompt for target directory
  echo "No target directory specified."
  echo ""
  printf "Enter the target project directory: "
  read -r TARGET_DIR

  # Expand ~ to home directory
  TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

  if [ -z "$TARGET_DIR" ]; then
    echo "No directory provided. Installation cancelled."
    exit 0
  fi
fi

# Validate target directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Target directory '$TARGET_DIR' does not exist."
  echo "Create it first, then re-run the installer."
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# --- Confirmation ---
echo ""
echo "WorkSpaceFramework Installer"
echo "============================"
if [ "$REMOTE_MODE" = false ]; then
  echo "Framework: $FRAMEWORK_DIR"
fi
echo "Target:    $TARGET_DIR"
echo ""

printf "Install WorkSpaceFramework into $TARGET_DIR? [Y/n] "
read -r confirm
if [ -n "$confirm" ] && ! echo "$confirm" | grep -qi '^y'; then
  echo "Installation cancelled."
  exit 0
fi

# --- Guards ---
RESOLVED_FRAMEWORK="$(cd "$FRAMEWORK_DIR" && pwd)"
if [ "$RESOLVED_FRAMEWORK" = "$TARGET_DIR" ]; then
  echo "Error: Cannot install framework into itself."
  exit 1
fi

if [ -f "$TARGET_DIR/.claude/rules/roles-and-governance.md" ]; then
  echo "Framework already installed in $TARGET_DIR"
  echo "Use '/setup update' from within the project to pull updates."
  exit 1
fi

# --- Create directory structure ---
echo "Creating directory structure..."
mkdir -p "$TARGET_DIR/.claude/rules"
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/.claude/templates/project-rules"
mkdir -p "$TARGET_DIR/.claude/templates/extensions"
mkdir -p "$TARGET_DIR/.claude/work/items"
mkdir -p "$TARGET_DIR/.claude/work/archive"
mkdir -p "$TARGET_DIR/.claude/artifacts"
mkdir -p "$TARGET_DIR/.claude/temp"
mkdir -p "$TARGET_DIR/.claude/memory"
mkdir -p "$TARGET_DIR/.claude/voice-inbox"
mkdir -p "$TARGET_DIR/.claude/providers"
mkdir -p "$TARGET_DIR/.claude/patterns/sessions"
mkdir -p "$TARGET_DIR/.claude/patterns/insights"
mkdir -p "$TARGET_DIR/.claude/scripts"

# Copy rules
echo "Copying rules (12 files)..."
cp "$FRAMEWORK_DIR/.claude/rules/"*.md "$TARGET_DIR/.claude/rules/"

# Copy commands
echo "Copying commands (18 files)..."
cp "$FRAMEWORK_DIR/.claude/commands/"*.md "$TARGET_DIR/.claude/commands/"

# Copy providers
echo "Copying providers (4 files)..."
cp "$FRAMEWORK_DIR/.claude/providers/"*.md "$TARGET_DIR/.claude/providers/"

# Copy skills (preserve directory structure)
echo "Copying skills (13 skills + registry + context)..."
for skill_dir in "$FRAMEWORK_DIR/.claude/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  mkdir -p "$TARGET_DIR/.claude/skills/$skill_name"
  cp -r "$skill_dir"* "$TARGET_DIR/.claude/skills/$skill_name/"
done
cp "$FRAMEWORK_DIR/.claude/skills/REGISTRY.md" "$TARGET_DIR/.claude/skills/"
cp "$FRAMEWORK_DIR/.claude/skills/CONTEXT.md" "$TARGET_DIR/.claude/skills/"

# Copy templates
echo "Copying templates (12 files)..."
cp "$FRAMEWORK_DIR/.claude/templates/"*.template "$TARGET_DIR/.claude/templates/"
cp "$FRAMEWORK_DIR/.claude/templates/project-rules/"*.template "$TARGET_DIR/.claude/templates/project-rules/"

# Copy extension pre-fill files
if [ -d "$FRAMEWORK_DIR/.claude/templates/extensions" ]; then
  cp "$FRAMEWORK_DIR/.claude/templates/extensions/"*.md "$TARGET_DIR/.claude/templates/extensions/"
fi

# Copy scripts
echo "Copying scripts..."
cp "$FRAMEWORK_DIR/.claude/scripts/"* "$TARGET_DIR/.claude/scripts/"
chmod +x "$TARGET_DIR/.claude/scripts/"*.sh 2>/dev/null || true

# BOARD.md is generated from item files on first /work use — not copied

# Create gitkeep files
touch "$TARGET_DIR/.claude/work/items/.gitkeep"
touch "$TARGET_DIR/.claude/work/archive/.gitkeep"
touch "$TARGET_DIR/.claude/artifacts/.gitkeep"
touch "$TARGET_DIR/.claude/temp/.gitkeep"
touch "$TARGET_DIR/.claude/memory/.gitkeep"
touch "$TARGET_DIR/.claude/voice-inbox/.gitkeep"
touch "$TARGET_DIR/.claude/patterns/sessions/.gitkeep"
touch "$TARGET_DIR/.claude/patterns/insights/.gitkeep"

# Add gitignore entries if .gitignore exists
if [ -f "$TARGET_DIR/.gitignore" ]; then
  if ! grep -q ".claude/temp/" "$TARGET_DIR/.gitignore" 2>/dev/null; then
    echo "" >> "$TARGET_DIR/.gitignore"
    echo "# Claude Code framework" >> "$TARGET_DIR/.gitignore"
    echo ".claude/temp/" >> "$TARGET_DIR/.gitignore"
    echo ".claude/voice-inbox/*.txt" >> "$TARGET_DIR/.gitignore"
    echo ".claude/voice-inbox/*.md" >> "$TARGET_DIR/.gitignore"
    echo "!.claude/voice-inbox/.gitkeep" >> "$TARGET_DIR/.gitignore"
    echo ".claude/work/BOARD.md" >> "$TARGET_DIR/.gitignore"
    echo ".claude/patterns/sessions/*.jsonl" >> "$TARGET_DIR/.gitignore"
    echo "!.claude/patterns/sessions/.gitkeep" >> "$TARGET_DIR/.gitignore"
    echo ".claude/patterns/PATTERNS.md" >> "$TARGET_DIR/.gitignore"
    echo "Updated .gitignore"
  fi
fi

# Copy settings if none exist
if [ ! -f "$TARGET_DIR/.claude/settings.local.json" ]; then
  # Read template, replace placeholders, write output
  SETTINGS_FILE="$TARGET_DIR/.claude/settings.local.json"
  sed -e "s|{{PROJECT_PATH}}|$TARGET_DIR|g" \
      -e '/{{ADDITIONAL_PERMISSIONS}}/d' \
      "$FRAMEWORK_DIR/.claude/templates/settings.local.json.template" > "$SETTINGS_FILE"
  echo "Created settings.local.json (local provider — run /setup to add provider permissions)"
else
  echo "Kept existing settings.local.json"
fi

echo ""
echo "================================"
echo "Framework installed successfully!"
echo "================================"
echo ""
echo "Files copied:"
echo "  .claude/rules/           (12 behavioral rules)"
echo "  .claude/commands/        (18 slash commands)"
echo "  .claude/providers/       (4 work provider files)"
echo "  .claude/skills/          (13 expert skills + registry + context)"
echo "  .claude/templates/       (12 project templates)"
echo "  .claude/work/            (work tracking — BOARD.md generated on first use)"
echo "  .claude/patterns/        (interaction analytics — sessions + insights)"
echo "  .claude/scripts/         (statusline monitor)"
echo ""
echo "Next steps:"
echo "  1. Open Claude Code in $TARGET_DIR"
echo "  2. Run /setup to start the discovery interview"
echo "  3. Claude interviews you about the project and generates your roadmap"
echo ""
