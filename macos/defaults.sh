#!/usr/bin/env bash
# Idempotent macOS system defaults.
# Re-run any time with `make macos`.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macos/defaults.sh: not running on macOS, skipping." >&2
  exit 0
fi

echo "==> Applying macOS defaults"

# Close System Settings so it doesn't overwrite our changes
osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true
osascript -e 'tell application "System Preferences" to quit' >/dev/null 2>&1 || true

# ---------------------------------------------------------------------------------------------------------------------
# Global
# ---------------------------------------------------------------------------------------------------------------------
defaults write com.apple.appleseed.FeedbackAssistant Autogather -bool false
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool true
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ---------------------------------------------------------------------------------------------------------------------
# Security
# ---------------------------------------------------------------------------------------------------------------------
# Enable Touch ID for sudo using /etc/pam.d/sudo_local (survives system updates on macOS 14+).
# Fall back to editing /etc/pam.d/sudo if sudo_local isn't supported.
if [[ -f /etc/pam.d/sudo_local.template ]]; then
  if ! sudo grep -q 'pam_tid.so' /etc/pam.d/sudo_local 2>/dev/null; then
    echo "Enabling Touch ID for sudo via /etc/pam.d/sudo_local"
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    sudo sed -i '' 's/^#\(auth.*pam_tid.so\)/\1/' /etc/pam.d/sudo_local
  fi
elif ! sudo grep -q 'pam_tid.so' /etc/pam.d/sudo; then
  echo "Enabling Touch ID for sudo via /etc/pam.d/sudo"
  if ! command -v gsed >/dev/null; then
    echo "ERROR: gsed (gnu-sed) is required. Install via 'brew install gnu-sed'." >&2
    exit 1
  fi
  sudo gsed -i '2iauth        sufficient     pam_tid.so' /etc/pam.d/sudo
fi

# Secure keyboard entry in Terminal-likes (only for apps that are installed)
defaults write -app Terminal SecureKeyboardEntry -bool true
if [[ -d "/Applications/iTerm.app" ]]; then
  defaults write -app iTerm SecureKeyboardEntry -bool true
fi

# Require an administrator password to access system-wide preferences
# https://www.tenable.com/audits/CIS_Apple_macOS_11_v2.0.0_L1
TMP_PLIST=$(mktemp -t system.preferences.plist)
sudo security authorizationdb read system.preferences > "$TMP_PLIST"
sudo defaults write "$TMP_PLIST" shared -bool false
sudo security authorizationdb write system.preferences < "$TMP_PLIST"
rm -f "$TMP_PLIST"

# ---------------------------------------------------------------------------------------------------------------------
# Finder
# ---------------------------------------------------------------------------------------------------------------------
defaults write com.apple.Finder AppleShowAllFiles -bool false
defaults write com.apple.finder QLEnableTextSelection -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder SearchRecentsSavedViewStyle -string "Nlsv"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.finder EmptyTrashSecurely -bool true
killall Finder >/dev/null 2>&1 || true

# ---------------------------------------------------------------------------------------------------------------------
# Firewall
# ---------------------------------------------------------------------------------------------------------------------
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1

# ---------------------------------------------------------------------------------------------------------------------
# Software Update
# ---------------------------------------------------------------------------------------------------------------------
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ScheduleFrequency -int 1
defaults write com.apple.commerce AutoUpdate -bool true

echo "==> macOS defaults applied"
