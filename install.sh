#!/bin/bash

# Claude for Designers — Installer
# Usage: curl -sL https://raw.githubusercontent.com/kobiagi-builder/claude-for-designers/main/install.sh | bash
#
# Clones the repo into the CURRENT directory and configures MCP servers.
# Run this from an empty folder where you want your project to live.

set -e

REPO_URL="https://github.com/kobiagi-builder/claude-for-designers.git"

echo ""
echo "  Claude for Designers — Installer"
echo "  ================================="
echo ""

# -------------------------------------------------------------------
# 1. Check Git (only hard requirement for cloning)
# -------------------------------------------------------------------

if ! command -v git &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    xcode-select --install 2>/dev/null || true
    echo "  A system dialog should appear asking to install Command Line Tools."
    echo "  Click 'Install' and wait for it to finish, then run this command again."
    exit 0
  else
    echo "  [x] Git is required. Install it and try again."
    exit 1
  fi
fi
echo "  [ok] Git found"

# -------------------------------------------------------------------
# 2. Check Node.js (needed for MCP servers via npx)
# -------------------------------------------------------------------

# Expand PATH for non-interactive shell
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
for dir in \
  "$HOME/.nvm/versions/node"/*/bin \
  "/usr/local/bin" \
  "/opt/homebrew/bin"; do
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) [ -d "$dir" ] && export PATH="$dir:$PATH" ;;
  esac
done

if ! command -v node &> /dev/null; then
  echo ""
  echo "  [x] Node.js is required for the Figma and Playwright connections."
  echo "      Install it from https://nodejs.org (v18 or later) and try again."
  exit 1
fi
echo "  [ok] Node.js $(node -v) found"

# -------------------------------------------------------------------
# 3. Clone the repo into the current directory
# -------------------------------------------------------------------

# Check if current directory is empty (besides hidden files like .DS_Store)
if [ -n "$(ls -A 2>/dev/null | grep -v '.DS_Store')" ]; then
  echo ""
  echo "  This folder is not empty."
  read -p "  Continue anyway? Files may be overwritten. (y/n): " CONTINUE </dev/tty
  if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
    echo "  Cancelled."
    exit 1
  fi
fi

echo ""
echo "  Cloning repository..."
git clone --quiet "$REPO_URL" _tmp_clone
# Move contents (including hidden files) into current directory, then clean up
shopt -s dotglob 2>/dev/null || true
mv _tmp_clone/* _tmp_clone/.* . 2>/dev/null || true
rmdir _tmp_clone 2>/dev/null || true
echo "  [ok] Repository cloned"

# -------------------------------------------------------------------
# 4. Ask for Figma API key and write .mcp.json
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

cat > .mcp.json << MCPEOF
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
        "@playwright/mcp"
      ]
    }
  }
}
MCPEOF

echo ""
echo "  [ok] Figma configured"
echo "  [ok] Playwright configured"

# -------------------------------------------------------------------
# 5. Open in Cursor or VS Code automatically
# -------------------------------------------------------------------

FULL_PATH="$(pwd)"

echo ""
echo "  ================================="
echo "  Setup complete!"
echo "  ================================="
echo ""

OPENED=false
if command -v cursor &> /dev/null; then
  echo "  Opening in Cursor..."
  cursor "$FULL_PATH"
  OPENED=true
elif command -v code &> /dev/null; then
  echo "  Opening in VS Code..."
  code "$FULL_PATH"
  OPENED=true
fi

if [ "$OPENED" = true ]; then
  echo ""
  echo "  Start a Claude chat and paste any Figma link."
else
  echo "  Open this folder in Cursor or VS Code:"
  echo ""
  echo "    $FULL_PATH"
  echo ""
  echo "  Then start a Claude chat and paste any Figma link."
fi
echo ""
