#!/usr/bin/env bash
# Install Xcode Command Line Tools and Homebrew if they're not already present.
# Safe to re-run.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "scripts/bootstrap.sh: not running on macOS, skipping." >&2
  exit 0
fi

# ---------------------------------------------------------------------------------------------------------------------
# Xcode Command Line Tools
# ---------------------------------------------------------------------------------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools (a GUI prompt will appear)"
  xcode-select --install
  echo "    Re-run 'make install' once the Command Line Tools finish installing."
  exit 1
fi

# ---------------------------------------------------------------------------------------------------------------------
# Rosetta 2 (Apple Silicon only)
# ---------------------------------------------------------------------------------------------------------------------
if [[ "$(uname -m)" == "arm64" ]]; then
  if ! /usr/bin/pgrep -q oahd; then
    echo "==> Installing Rosetta 2"
    softwareupdate --install-rosetta --agree-to-license
  fi
fi

# ---------------------------------------------------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------------------------------------------------
if ! command -v brew >/dev/null; then
  echo "==> Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add brew to PATH for the current shell (also handled by .zshrc afterwards)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

echo "==> Bootstrap complete"
