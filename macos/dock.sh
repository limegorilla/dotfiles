#!/usr/bin/env bash
# Configure the Dock. Re-runnable: clears the dock then rebuilds it deterministically.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macos/dock.sh: not running on macOS, skipping." >&2
  exit 0
fi

# Resolve repo dir (so we can source the dock helpers regardless of CWD)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# shellcheck source=../lib/dock_operations.sh
source "$REPO_DIR/lib/dock_operations.sh"

echo "==> Configuring Dock"

defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock tilesize -int 43
defaults write com.apple.dock minimize-to-application -bool false
defaults write com.apple.dock launchanim -bool true
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock show-recents -bool false

clear_dock

apps=(
  '/Applications/Helium.app'
  '/Applications/Zed.app'
  '/Applications/Ghostty.app'
  '/System/Applications/Mail.app'
  '/System/Applications/Calendar.app'
  '/System/Applications/Music.app'
  '/Applications/1Password.app'
)
for app in "${apps[@]}"; do
  add_app_to_dock "$app"
done

add_folder_to_dock "$HOME/Downloads"  --arrangement 3 --displayAs 0 --showAs 1
add_folder_to_dock "$HOME/Developer"  --arrangement 1 --displayAs 1 --showAs 2

killall Dock >/dev/null 2>&1 || true
echo "==> Dock configured"
