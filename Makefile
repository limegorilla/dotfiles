# Entry point for the dotfiles. Every target is safe to re-run.
#
# Typical use:
#   make install   # first-time setup on a fresh Mac
#   make update    # re-apply everything (idempotent)
#   make help      # list available targets

SHELL        := /bin/bash
.SHELLFLAGS  := -eu -o pipefail -c
.DEFAULT_GOAL := help

DOTFILES_DIR  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
STOW_PACKAGE  := home
TARGET_DIR    := $(HOME)
FONT_SRC_DIR  := $(DOTFILES_DIR)/fonts
FONT_DEST_DIR := $(HOME)/Library/Fonts

# ANSI helpers
BOLD := \033[1m
DIM  := \033[2m
RST  := \033[0m

.PHONY: help install update bootstrap brew brew-dump stow unstow restow fonts macos dock apps scripts doctor clean-ds-store

help: ## Show available targets
	@printf "$(BOLD)Dotfiles targets$(RST)\n"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  $(BOLD)%-12s$(RST) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\n$(DIM)Source: $(DOTFILES_DIR)$(RST)\n"

install: bootstrap brew stow fonts macos apps ## First-time setup on a fresh Mac
	@printf "\n$(BOLD)Done.$(RST) Open a new shell to pick up changes.\n"

update: brew restow fonts macos apps ## Re-apply everything (safe to repeat)
	@printf "\n$(BOLD)Updated.$(RST)\n"

bootstrap: ## Install Xcode CLT and Homebrew if missing
	@bash $(DOTFILES_DIR)/scripts/bootstrap.sh

brew: ## Install/sync packages from Brewfile
	brew bundle --file=$(DOTFILES_DIR)/Brewfile

brew-dump: ## Overwrite Brewfile with current brew state (review the diff!)
	brew bundle dump --force --file=$(DOTFILES_DIR)/Brewfile

stow: ## Symlink home/ into your home directory
	stow --dir=$(DOTFILES_DIR) --target=$(TARGET_DIR) --no-folding $(STOW_PACKAGE)

restow: ## Re-create symlinks (safe to repeat)
	stow --dir=$(DOTFILES_DIR) --target=$(TARGET_DIR) --no-folding --restow $(STOW_PACKAGE)

unstow: ## Remove all dotfile symlinks from your home directory
	stow --dir=$(DOTFILES_DIR) --target=$(TARGET_DIR) --no-folding --delete $(STOW_PACKAGE)

fonts: ## Install bundled fonts into ~/Library/Fonts
	@mkdir -p "$(FONT_DEST_DIR)"
	@count=0; \
	while IFS= read -r -d '' f; do \
	  name=$$(basename "$$f"); \
	  if [[ ! -f "$(FONT_DEST_DIR)/$$name" ]]; then \
	    cp "$$f" "$(FONT_DEST_DIR)/$$name"; \
	    count=$$((count+1)); \
	  fi; \
	done < <(find "$(FONT_SRC_DIR)" \( -name '*.otf' -o -name '*.ttf' \) -print0); \
	printf "Fonts: installed %d new file(s) into %s\n" "$$count" "$(FONT_DEST_DIR)"

macos: ## Apply macOS system defaults (idempotent)
	bash $(DOTFILES_DIR)/macos/defaults.sh
	DOTFILES_DIR=$(DOTFILES_DIR) bash $(DOTFILES_DIR)/macos/dock.sh

apps: ## Configure per-app preferences (Amphetamine, Safari, Mail, ...)
	bash $(DOTFILES_DIR)/macos/apps.sh

doctor: ## Diagnose obvious setup problems
	@bash $(DOTFILES_DIR)/scripts/doctor.sh

clean-ds-store: ## Remove .DS_Store files from the repo
	@find $(DOTFILES_DIR) -name .DS_Store -not -path '*/.git/*' -print -delete
