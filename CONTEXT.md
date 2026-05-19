# Dotfiles

Personal macOS configuration (Apple Silicon assumed): dotfiles, shell scripts, packages, fonts, macOS defaults. Public repo. `Makefile` is the entry point; `GNU Stow` symlinks `home/` into `$HOME`; `Brewfile` is the single source of truth for installable software.

> This file is intentionally minimal and is the entry point for AI agents working in this repo. It captures only the invariants and vocabulary needed to make safe edits without re-reading the whole repo. Decisions and their rejected alternatives live in `docs/adr/` and are loaded on demand. **Do not grow this file past one screen.** If a topic needs more, write an ADR or a topic doc under `docs/` and link to it from here.

## Invariants

1. **`Brewfile` is the single source of truth for installable software.** No ad-hoc `brew install`, no `npm i -g`, no `curl | bash`. If you need a tool, add it to `Brewfile` and run `make brew`.
2. **All setup scripts are idempotent.** Re-running `make update` must never break anything or require manual cleanup. New scripts under `scripts/` and `macos/` must hold this property.
3. **Secrets never live in the repo, encrypted or otherwise.** Private material is provided at runtime by 1Password (SSH agent + `op` CLI) or macOS Keychain. See [ADR-0001](docs/adr/0001-secrets-via-1password.md).
4. **macOS-only.** No `if linux` branches. If support is ever added, split the Makefile and introduce a `linux/` tree — don't sprinkle conditionals.
5. **`home/` is the only stow package and is stowed with `--no-folding`.** New dotfiles go under `home/` mirroring their `$HOME` path (e.g. `home/.config/foo/bar` → `~/.config/foo/bar`). `--no-folding` is deliberate so nested config directories aren't collapsed into a single symlink.
6. **`bin/` is auto-prepended to `$PATH` by `.zshrc`.** New personal scripts go in `bin/`, with a shebang and executable bit set.
7. **`dotfiles adopt` is the only sanctioned way to bring an existing local resource into the repo.** Three modes: `--file` (stow-adopt `$HOME` files), `--brew` (track installed formulae/casks), `--mas` (track installed App Store apps). Review the resulting diff before committing — adopted files may contain machine-specific or sensitive data, and adopted Brewfile entries land in a flat `# Adopted` section that you may want to curate by hand.

## Language

**Stow package**: the `home/` directory; what GNU Stow treats as a single unit to symlink. This repo has exactly one.
_Avoid_: "stow directory", "stow target" (the target is `$HOME`).

**Adopt**: bring an existing local resource under the ownership of this repo, so it becomes governed by the dotfiles source of truth rather than living loose on the machine. Currently applies to two resource kinds:
- **`$HOME` files** → `stow --adopt` *moves* the file into `home/` and replaces it with a symlink. Destructive if not reviewed.
- **Installed brew/cask/mas apps** → appends a line to `Brewfile` so the app is tracked. Additive, non-destructive.
The verb is the same because the intent is the same; only the mechanism differs by resource kind. See [ADR-0002](docs/adr/0002-unified-adopt-verb.md).

**Bootstrap**: `scripts/bootstrap.sh`; installs Xcode Command Line Tools, Rosetta 2, and Homebrew. Runs first under `make install`.

**Doctor**: `scripts/doctor.sh`; sanity-checks the local environment (warns if `op`, `stow`, `brew`, etc. are missing). Read-only; safe to run anywhere.

**`dotfiles` alias**: loaded by `.zshrc`; points at `bin/dotfiles`. Handles the `adopt` subcommand directly and falls through to `make -C $DOTFILES_DIR <target>` for everything else, so existing make targets (`dotfiles update`, `dotfiles brew`, …) keep working.

## Pointers

- **Human intro & quickstart** → `README.md`
- **Available targets** → `make help` (the Makefile is self-documenting)
- **Decisions & rejected alternatives** → `docs/adr/`
- **Diagnose a broken local setup** → `make doctor`
