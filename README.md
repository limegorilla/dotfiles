# Dotfiles

My personal macOS setup. Brew is the source of truth for every CLI, GUI app, and
plugin. macOS configuration and dotfile symlinks are managed by a small
`Makefile`, with personal scripts in `bin/`.

> [!WARNING]
> These are tailored to my workflow (1Password for SSH/Git signing, Ghostty as
> terminal, Powerlevel10k, etc). Don't apply them blindly to your own machine.

## Quick start

On a fresh Mac:

```sh
git clone git@github.com:limegorilla/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

If you don't have git yet, the bootstrap script will install the Xcode Command
Line Tools first; run `make install` again afterwards.

On an existing Mac, to re-apply everything safely:

```sh
dotfiles update          # available once .zshrc is sourced
# or, before the alias is loaded:
make -C ~/.dotfiles update
```

## Layout

```
dotfiles/
├── Makefile             # all entry points (make help for the list)
├── Brewfile             # single source of truth for every installed app/CLI
├── home/                # stowed into $HOME (`make stow`)
│   ├── .zshrc
│   ├── .gitconfig
│   ├── .gitignore_global
│   ├── .p10k.zsh
│   ├── .ssh/config
│   └── .config/nvim/
├── macos/               # idempotent macOS configuration scripts
│   ├── defaults.sh      # global system defaults (Finder, firewall, ...)
│   ├── dock.sh          # dock layout
│   └── apps.sh          # per-app preferences (Safari, Mail, ...)
├── bin/                 # personal scripts, added to $PATH via .zshrc
│   └── eod              # end-of-day git status across ~/Developer
├── lib/                 # shared shell helpers
│   └── dock_operations.sh
├── scripts/             # one-shot helpers used by the Makefile
│   ├── bootstrap.sh     # Xcode CLT, Rosetta, Homebrew
│   └── doctor.sh        # diagnose setup problems
└── fonts/               # bundled fonts, copied into ~/Library/Fonts
```

## Makefile targets

Run `make help` for the live list. Highlights:

| Target          | What it does                                             |
| --------------- | -------------------------------------------------------- |
| `make install`  | Bootstrap, brew, stow, fonts, macos, apps (first run)    |
| `make update`   | Re-apply everything (safe to repeat on existing Macs)    |
| `make brew`     | `brew bundle` against the Brewfile                       |
| `make brew-dump`| Overwrite Brewfile with current brew state (review!)     |
| `make stow`     | Symlink `home/` into `$HOME`                             |
| `make restow`   | Re-create symlinks (after pulling changes, for example)  |
| `make adopt`    | Move existing `$HOME` files **into** the repo (careful)  |
| `make fonts`    | Copy bundled fonts into `~/Library/Fonts`                |
| `make macos`    | `defaults.sh` + `dock.sh`                                |
| `make apps`     | `apps.sh`                                                |
| `make doctor`   | Sanity-check the environment                             |

Once `.zshrc` is sourced, the same targets are available via the `dotfiles`
alias (e.g. `dotfiles update`, `dotfiles doctor`).

## The `bin/` directory

Anything in `bin/` is on `$PATH` after the shell is sourced. Add a new script by
dropping a file in, marking it executable, and starting it with a useful
shebang (`#!/usr/bin/env bash` for shell, etc.).

### `eod` — end-of-day report

Walks every git repository under `~/Developer` and lists anything with
uncommitted changes, unpushed commits, or no upstream branch. Run it before
shutting down for the day:

```sh
eod                 # scans ~/Developer
eod ~/code          # scan a different tree
```

## Conventions

- **Every package is installed via Brew or the Mac App Store.** Manual installs
  (`curl | bash`, `npm i -g`, ...) belong in a script, not in folklore.
- **Every setup script is idempotent.** Re-running `make update` on an existing
  Mac should never break the system or require manual cleanup.
- **macOS-only.** No `if linux` branches. If that changes, introduce
  `linux/defaults.sh` and split the Makefile targets.

## Adopting on an existing Mac

If you already have a `~/.zshrc`, `~/.gitconfig`, etc., `make stow` will refuse
to overwrite them. Two options:

1. Back them up, delete them, and `make stow`.
2. Run `make adopt` to **move** the existing files into `home/`, then review the
   diff and reset anything you don't actually want to track.
