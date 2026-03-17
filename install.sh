#!/bin/bash

# Claude for Designers — Installer
# Usage: curl -sL https://raw.githubusercontent.com/kobiagi-builder/claude-for-designers/main/install.sh | bash

set -e

REPO_URL="https://github.com/kobiagi-builder/claude-for-designers.git"
FOLDER_NAME="claude-for-designers"

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
# 3. Clone the repo
# -------------------------------------------------------------------

if [ -d "$FOLDER_NAME" ]; then
  echo ""
  echo "  Folder '$FOLDER_NAME' already exists here."
  read -p "  Overwrite it? (y/n): " OVERWRITE </dev/tty
  if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
    rm -rf "$FOLDER_NAME"
  else
    echo "  Cancelled."
    exit 1
  fi
fi

echo ""
echo "  Cloning repository..."
git clone --quiet "$REPO_URL" "$FOLDER_NAME"
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
# 5. Done
# -------------------------------------------------------------------

FULL_PATH="$(cd "$FOLDER_NAME" && pwd)"

echo ""
echo "  ================================="
echo "  Setup complete!"
echo "  ================================="
echo ""
echo "  Next step: Open this folder in Cursor or VS Code:"
echo ""
echo "    $FULL_PATH"
echo ""
echo "  Then start a Claude chat and paste any Figma link."
echo ""
