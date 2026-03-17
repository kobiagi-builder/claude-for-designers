#!/bin/bash

# Claude for Designers — Installer
# Usage: curl -sL https://raw.githubusercontent.com/kobiagi-builder/claude-for-designers/main/install.sh | bash
#
# This script handles everything: installs missing tools, clones the repo,
# asks for the Figma API key, and configures both MCP servers.
# The user only needs to paste one command.

set -e

REPO_URL="https://github.com/kobiagi-builder/claude-for-designers.git"
FOLDER_NAME="claude-for-designers"

# -------------------------------------------------------------------
# Expand PATH to include common tool locations.
# curl | bash runs a non-interactive shell that skips .zshrc, so
# tools installed via nvm, npm, or homebrew may not be on PATH.
# -------------------------------------------------------------------
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

for dir in \
  "$HOME/.nvm/versions/node"/*/bin \
  "$HOME/.npm-global/bin" \
  "/usr/local/bin" \
  "/opt/homebrew/bin" \
  "$HOME/bin" \
  "$HOME/.local/bin"; do
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) [ -d "$dir" ] && export PATH="$dir:$PATH" ;;
  esac
done

echo ""
echo "  Claude for Designers — Installer"
echo "  ================================="
echo ""

# -------------------------------------------------------------------
# 1. Install missing prerequisites automatically
# -------------------------------------------------------------------

# --- Git ---
if ! command -v git &> /dev/null; then
  echo "  [..] Git not found — installing..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    xcode-select --install 2>/dev/null || true
    echo ""
    echo "  A system dialog should appear asking to install Command Line Tools."
    echo "  Click 'Install' and wait for it to finish, then run this command again."
    echo ""
    exit 0
  elif command -v apt-get &> /dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq git
  elif command -v yum &> /dev/null; then
    sudo yum install -y -q git
  else
    echo "  [x] Could not install Git automatically."
    echo "      Install it from https://git-scm.com/downloads and try again."
    exit 1
  fi
fi
echo "  [ok] Git found"

# --- Node.js ---
if ! command -v node &> /dev/null || [ "$(node -v | sed 's/v//' | cut -d. -f1)" -lt 18 ]; then
  echo "  [..] Node.js v18+ not found — installing via nvm..."

  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | BASH_ENV=/dev/null bash
  fi

  . "$NVM_DIR/nvm.sh" < /dev/null 2>/dev/null

  nvm install 20
  nvm use 20

  for dir in "$HOME/.nvm/versions/node"/*/bin; do
    [ -d "$dir" ] && export PATH="$dir:$PATH"
  done

  echo "  [ok] Node.js $(node -v) installed via nvm"
else
  echo "  [ok] Node.js $(node -v) found"
fi

# --- Claude Code ---
if ! command -v claude &> /dev/null; then
  echo "  [..] Claude Code not found — installing..."
  npm install -g @anthropic-ai/claude-code
  NPM_GLOBAL_BIN="$(npm prefix -g 2>/dev/null)/bin"
  export PATH="$NPM_GLOBAL_BIN:$PATH"
  echo "  [ok] Claude Code installed"
else
  echo "  [ok] Claude Code found"
fi

# -------------------------------------------------------------------
# 2. Clone the repo
# -------------------------------------------------------------------

if [ -d "$FOLDER_NAME" ]; then
  echo ""
  echo "  Folder '$FOLDER_NAME' already exists in this directory."
  read -p "  Overwrite it? (y/n): " OVERWRITE </dev/tty
  if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
    rm -rf "$FOLDER_NAME"
  else
    echo "  Cancelled. Remove or rename the existing folder and try again."
    exit 1
  fi
fi

echo ""
echo "  Cloning repository..."
git clone --quiet "$REPO_URL" "$FOLDER_NAME"
echo "  [ok] Repository cloned to ./$FOLDER_NAME"

# -------------------------------------------------------------------
# 3. Configure Figma + Playwright MCP servers
# -------------------------------------------------------------------

echo ""
echo "  ================================="
echo "  Figma Setup"
echo "  ================================="
echo ""
echo "  To connect to Figma, you need a Personal Access Token."
echo ""
echo "  How to get one:"
echo "    1. Open Figma and go to Settings"
echo "    2. Scroll to 'Personal Access Tokens'"
echo "    3. Click 'Generate new token' and copy it"
echo "    4. It starts with figd_"
echo ""

FIGMA_KEY=""
while [ -z "$FIGMA_KEY" ]; do
  read -p "  Paste your Figma API key here: " FIGMA_KEY </dev/tty
  if [ -z "$FIGMA_KEY" ]; then
    echo "  Key cannot be empty. Please try again."
  elif [[ "$FIGMA_KEY" != figd_* ]]; then
    echo ""
    echo "  That doesn't look like a Figma key (should start with figd_)."
    read -p "  Use it anyway? (y/n): " USE_ANYWAY </dev/tty
    if [ "$USE_ANYWAY" != "y" ] && [ "$USE_ANYWAY" != "Y" ]; then
      FIGMA_KEY=""
    fi
  fi
done

# Write .mcp.json inside the cloned project (gitignored, never committed)
cat > "$FOLDER_NAME/.mcp.json" << MCPEOF
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": [
        "-y",
        "figma-developer-mcp",
        "--figma-api-key=${FIGMA_KEY}",
        "--stdio"
      ]
    },
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-playwright"
      ]
    }
  }
}
MCPEOF

echo ""
echo "  [ok] Figma configured"
echo "  [ok] Playwright configured"

# -------------------------------------------------------------------
# 4. Done
# -------------------------------------------------------------------

echo ""
echo "  ================================="
echo "  Setup complete!"
echo "  ================================="
echo ""
echo "  To start, run:"
echo ""
echo "    cd $FOLDER_NAME"
echo "    claude"
echo ""
echo "  Then paste any Figma link and Claude will implement it as code."
echo ""
