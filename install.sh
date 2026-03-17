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
# 1. Install missing prerequisites automatically
# -------------------------------------------------------------------

# --- Git ---
if ! command -v git &> /dev/null; then
  echo "  [..] Git not found — installing..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: trigger Xcode Command Line Tools (includes git)
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

  # Install nvm if not present
  if [ -z "$NVM_DIR" ] || [ ! -s "$NVM_DIR/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    # Load nvm into current shell
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  else
    . "$NVM_DIR/nvm.sh"
  fi

  nvm install 20
  nvm use 20
  echo "  [ok] Node.js $(node -v) installed via nvm"
else
  echo "  [ok] Node.js $(node -v) found"
fi

# --- Claude Code ---
if ! command -v claude &> /dev/null; then
  echo "  [..] Claude Code not found — installing..."
  npm install -g @anthropic-ai/claude-code
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
  read -p "  Overwrite it? (y/n): " OVERWRITE
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
# 3. Launch Claude Code with /prep
# -------------------------------------------------------------------

echo ""
echo "  ================================="
echo "  Almost done!"
echo "  ================================="
echo ""
echo "  Claude Code is opening now."
echo "  It will ask for your Figma API key to finish setup."
echo ""

cd "$FOLDER_NAME"
claude "/prep"
