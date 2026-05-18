#!/usr/bin/env bash
# Diagnose obvious setup problems.
set -euo pipefail

PASS="\033[32m✓\033[0m"
FAIL="\033[31m✗\033[0m"
WARN="\033[33m!\033[0m"

problems=0

check() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    printf "$PASS %s\n" "$label"
  else
    printf "$FAIL %s\n" "$label"
    problems=$((problems + 1))
  fi
}

warn_if_missing() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    printf "$PASS %s\n" "$label"
  else
    printf "$WARN %s\n" "$label"
  fi
}

echo "Required tools"
check "brew installed"            "command -v brew"
check "stow installed"            "command -v stow"
check "gsed (gnu-sed) installed"  "command -v gsed"
check "gh (GitHub CLI) installed" "command -v gh"
check "nvim installed"            "command -v nvim"
check "delta installed"           "command -v delta"

echo
echo "Optional tools"
warn_if_missing "node installed"  "command -v node"
warn_if_missing "bun installed"   "command -v bun"
warn_if_missing "pnpm installed"  "command -v pnpm"
warn_if_missing "op (1Password CLI)" "command -v op"

echo
echo "Symlinks"
for f in ~/.zshrc ~/.gitconfig ~/.p10k.zsh ~/.gitignore_global ~/.ssh/config ~/.config/nvim/init.lua; do
  if [[ -L "$f" ]]; then
    printf "$PASS %s -> %s\n" "$f" "$(readlink "$f")"
  elif [[ -e "$f" ]]; then
    printf "$WARN %s exists but is not a symlink\n" "$f"
  else
    printf "$FAIL %s missing\n" "$f"
    problems=$((problems + 1))
  fi
done

echo
echo "Filesystem"
warn_if_missing "~/Developer exists"   "[[ -d $HOME/Developer ]]"

echo
if [[ $problems -eq 0 ]]; then
  printf "$PASS No problems found.\n"
else
  printf "$FAIL %d problem(s) found.\n" "$problems"
  exit 1
fi
