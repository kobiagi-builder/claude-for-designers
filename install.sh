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
# 1. Check prerequisites
# -------------------------------------------------------------------

# Check git
if ! command -v git &> /dev/null; then
  echo "  [x] Git is not installed."
  echo "      Install it from https://git-scm.com/downloads and try again."
  exit 1
fi
echo "  [ok] Git found"

# Check Node.js
if ! command -v node &> /dev/null; then
  echo "  [x] Node.js is not installed."
  echo "      Install it from https://nodejs.org (v18 or later) and try again."
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  echo "  [x] Node.js v18+ is required (you have v$(node -v))."
  echo "      Update at https://nodejs.org and try again."
  exit 1
fi
echo "  [ok] Node.js $(node -v) found"

# Check Claude Code
if ! command -v claude &> /dev/null; then
  echo "  [x] Claude Code is not installed."
  echo "      Install it from https://docs.anthropic.com/en/docs/claude-code/overview"
  exit 1
fi
echo "  [ok] Claude Code found"

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
echo "  Installation complete!"
echo "  ================================="
echo ""
echo "  Claude Code is opening now."
echo "  It will ask for your Figma API key to finish setup."
echo ""

cd "$FOLDER_NAME"
claude "/prep"
