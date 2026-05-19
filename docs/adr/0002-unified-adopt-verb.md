---
status: accepted
---

# `adopt` is one verb for all "make this local resource owned by the repo" actions

The original `make adopt` meant "run `stow --adopt`": move existing `$HOME` files into `home/` and replace them with symlinks. When support was added for tracking already-installed brew formulae, casks, and MAS apps in the `Brewfile`, the same verb was extended rather than introducing a new one. The intent is identical in both cases — "this resource exists locally; bring it under the dotfiles source of truth" — so `dotfiles adopt --file` / `--brew` / `--mas` share one command. Bare `dotfiles adopt` is a hard error so the destructive file case can never be a silent default.

## Considered alternatives

- **Separate verbs (`adopt` for files, `track` for Brewfile).** Rejected: the destructive-vs-additive split is a property of the *mechanism*, not the *intent*. Two verbs would force every reader to learn the same idea twice, and the CLI surface would grow faster than the underlying concept.
- **Keep `make adopt` for files, add `dotfiles apps add` for Brewfile.** This was the original sketch. Rejected once it became clear the two operations are the same conceptual move, and that `apps` already names the per-app preferences target (`macos/apps.sh`), so reusing it would shadow an unrelated command.

## Consequences

- Mode flags (`--file`, `--brew`, `--mas`) are mandatory. There is no default mode; `dotfiles adopt` with no flag prints help and exits non-zero.
- The CONTEXT.md definition of "Adopt" is broader than it used to be and explicitly enumerates both resource kinds. Adding a third resource kind in future (e.g., a `cargo` adoptable list) is a matter of adding a mode flag rather than coining a new verb.
- The `dotfiles` shell alias is no longer a pure `make` wrapper — `bin/dotfiles` dispatches subcommands itself and only falls through to `make` for unrecognised ones. This is an implementation detail of how rich CLI shape coexists with the make-based recipe layer.
