---
status: accepted
---

# Secrets live in 1Password & macOS Keychain, never in the repo

This is a public repo (`limegorilla/dotfiles`). Anything committed is world-readable, forever, even after deletion. The constraint shaped the decision: private material is *never* committed — not even encrypted — and is instead provided at runtime by 1Password (SSH agent socket, `op-ssh-sign` for git commit signing, `op` CLI for ad-hoc retrieval) and macOS Keychain.

The only "key" tracked in-repo is the SSH **public** signing key in `home/.gitconfig` — public keys are not secrets and are equivalent to a username.

## Considered alternatives

- **Private repo.** Rejected: public sharing has value (other people can learn from / lift snippets), and the rule "no secrets in repo, ever" is harder to enforce when "just for now, it's private anyway" is available as an excuse.
- **Encrypted-in-repo (SOPS / age / git-crypt).** Rejected: the complexity tax (key management, decryption hooks, recovery if the master key is lost) is not worth paying when 1Password is already installed, unlocked, and integrated with the OS on every machine this repo runs on. Reconsider if a future host (e.g. a Linux VM, a CI runner) ever needs secrets and can't talk to 1Password.

## Enforcement

Documentation alone is too fragile for a public repo where one mistake means a history rewrite plus key rotation. Belt and braces:

1. **`gitleaks` pre-commit hook**, installed by `make hooks` (and chained into `make install`). Fast local feedback before anything is staged.
2. **`gitleaks` CI job** in `.github/workflows/`. Catches anything that slips past local hooks, including PRs from forks.
3. **Allowlist** for `home/.gitconfig` so the public SSH signing key doesn't trip the scanner.

## Consequences

- 1Password and the `op` CLI are hard install dependencies. `scripts/doctor.sh` warns when either is missing.
- First-time setup on a fresh Mac requires 1Password to be installed *and unlocked* before `git commit` works (because commit signing goes through `op-ssh-sign`).
- If 1Password is ever swapped out (say, for a different password manager), the swap is downstream of this ADR — the rule "no secrets in the repo, encrypted or otherwise" survives the swap.
