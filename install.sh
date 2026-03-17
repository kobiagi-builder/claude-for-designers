#!/bin/bash

# Claude for Designers — Installer
# Usage: curl -sL https://raw.githubusercontent.com/kobiagi-builder/claude-for-designers/main/install.sh | bash

# IMPORTANT: This script is read from stdin via curl | bash.
# Never source external files without redirecting stdin from /dev/null,
# or the sourced file will consume the rest of this script.

set -e

REPO_URL="https://github.com/kobiagi-builder/claude-for-designers.git"
FOLDER_NAME="claude-for-designers"

# -------------------------------------------------------------------
# Expand PATH to include common tool locations.
# curl | bash skips .zshrc/.bash_profile, so tools like node, npm,
# and claude are invisible. We add known directories directly.
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

  # Source nvm with stdin from /dev/null so it doesn't consume our script
  . "$NVM_DIR/nvm.sh" < /dev/null 2>/dev/null

  nvm install 20
  nvm use 20

  # Add the newly installed node to PATH
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
  # Add npm global bin to PATH for this session
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
