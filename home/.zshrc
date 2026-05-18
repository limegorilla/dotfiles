# ---------------------------------------------------------------------------------------------------------------------
# Dotfiles location -- used by the `dotfiles` alias and to find personal scripts.
# Set DOTFILES_DIR before sourcing this file to override the default.
# ---------------------------------------------------------------------------------------------------------------------
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# ---------------------------------------------------------------------------------------------------------------------
# Powerlevel10k - Instant Prompt
# ---------------------------------------------------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---------------------------------------------------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------------------------------------------------
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
export HOMEBREW_CASK_OPTS=--no-quarantine

# ---------------------------------------------------------------------------------------------------------------------
# Zinit
# ---------------------------------------------------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ---------------------------------------------------------------------------------------------------------------------
# Zinit - Plugins
# ---------------------------------------------------------------------------------------------------------------------
if [[ -z "$SSH_CONNECTION" && -z "$SSH_TTY" ]]; then
  zinit ice depth=1
  zinit light romkatv/powerlevel10k
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  zinit light zsh-users/zsh-syntax-highlighting
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light Aloxaf/fzf-tab
else
  PROMPT='%n@%m:%~ %# '
fi

zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

autoload -Uz compinit && compinit
command -v op >/dev/null && eval "$(op completion zsh)" && compdef _op op

zinit cdreplay -q

# ---------------------------------------------------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------------------------------------------------
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ---------------------------------------------------------------------------------------------------------------------
# Completion styling
# ---------------------------------------------------------------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ---------------------------------------------------------------------------------------------------------------------
# PATH (personal scripts live in $DOTFILES_DIR/bin)
# ---------------------------------------------------------------------------------------------------------------------
[[ -d "$DOTFILES_DIR/bin" ]] && export PATH="$DOTFILES_DIR/bin:$PATH"

# ---------------------------------------------------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------------------------------------------------
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias ssh='TERM_SIMPLE=1 ssh'

# Manage the dotfiles repo from anywhere: `dotfiles update`, `dotfiles brew`, etc.
alias dotfiles="make -C $DOTFILES_DIR"

# ---------------------------------------------------------------------------------------------------------------------
# Shell integrations
# ---------------------------------------------------------------------------------------------------------------------
command -v fzf    >/dev/null && eval "$(fzf --zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

# ---------------------------------------------------------------------------------------------------------------------
# Orbstack
# ---------------------------------------------------------------------------------------------------------------------
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# ---------------------------------------------------------------------------------------------------------------------
# Editor
# ---------------------------------------------------------------------------------------------------------------------
export EDITOR=nvim

# ---------------------------------------------------------------------------------------------------------------------
# Bun
# ---------------------------------------------------------------------------------------------------------------------
export BUN_INSTALL="$HOME/.bun"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ---------------------------------------------------------------------------------------------------------------------
# Extra PATH entries (Postgres@17, LM Studio, Bun)
# ---------------------------------------------------------------------------------------------------------------------
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH:$HOME/.lmstudio/bin:$BUN_INSTALL/bin"
