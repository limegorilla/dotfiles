#!/usr/bin/env bash
# Per-app configuration. Re-runnable.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macos/apps.sh: not running on macOS, skipping." >&2
  exit 0
fi

echo "==> Configuring apps"

# ---------------------------------------------------------------------------------------------------------------------
# Amphetamine
# ---------------------------------------------------------------------------------------------------------------------
killall Amphetamine >/dev/null 2>&1 || true
defaults write com.if.Amphetamine "Start Session At Launch" -bool true

# ---------------------------------------------------------------------------------------------------------------------
# GPG
# ---------------------------------------------------------------------------------------------------------------------
if command -v gpg-connect-agent >/dev/null; then
  gpg-connect-agent reloadagent /bye >/dev/null 2>&1 || true
fi

# ---------------------------------------------------------------------------------------------------------------------
# Homebrew auto-update (weekly)
# ---------------------------------------------------------------------------------------------------------------------
mkdir -p ~/Library/LaunchAgents
PLIST=~/Library/LaunchAgents/com.github.domt4.homebrew-autoupdate.plist
if [[ ! -f "$PLIST" ]]; then
  touch "$PLIST"
fi
if command -v brew >/dev/null && brew commands | grep -q autoupdate; then
  brew autoupdate delete >/dev/null 2>&1 || true
  brew autoupdate start 604800 --upgrade >/dev/null
fi

# ---------------------------------------------------------------------------------------------------------------------
# Mail
# ---------------------------------------------------------------------------------------------------------------------
killall Mail >/dev/null 2>&1 || true
# Copy email addresses as `foo@example.com`, not `Foo Bar <foo@example.com>`
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# ---------------------------------------------------------------------------------------------------------------------
# Safari (privacy hardening)
# ---------------------------------------------------------------------------------------------------------------------
killall Safari >/dev/null 2>&1 || true
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

# ---------------------------------------------------------------------------------------------------------------------
# Terminal.app
# Configures defaults *without* launching Terminal (AppleScript would).
# Ghostty is the primary terminal -- configure that separately if needed.
# ---------------------------------------------------------------------------------------------------------------------
defaults write com.apple.Terminal "Default Window Settings" -string Basic
defaults write com.apple.Terminal "Startup Window Settings" -string Basic
defaults write com.apple.terminal StringEncodings -array 4

# Required so zsh completion doesn't complain about insecure directories
if command -v brew >/dev/null; then
  chmod -R go-w "$(brew --prefix)/share" || true
fi

# ---------------------------------------------------------------------------------------------------------------------
# TextEdit
# ---------------------------------------------------------------------------------------------------------------------
killall TextEdit >/dev/null 2>&1 || true
defaults write com.apple.TextEdit RichText -bool false
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

echo "==> Apps configured"
