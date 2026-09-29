# ============================================================
# Zsh configuration
# Managed by ~/dev-setup
# ============================================================

# ------------------------------------------------------------
# Oh My Zsh
# ------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="af-magic"

plugins=(
  git
)

source "$ZSH/oh-my-zsh.sh"


# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

export EDITOR="nvim"
export VISUAL="nvim"

# uv
if [[ -f "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi


# ------------------------------------------------------------
# fzf
# ------------------------------------------------------------

# fzf shell integration
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi


# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

alias v='nvim'
alias vi='nvim'

alias t='tmux'

alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status'
alias gl='git log --oneline --decorate --graph'
alias gp='git pull'
alias gco='git checkout'
alias gc='git commit'


# ------------------------------------------------------------
# History
# ------------------------------------------------------------

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY


# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

autoload -Uz compinit
compinit


# ------------------------------------------------------------
# Prompt
# ------------------------------------------------------------

# PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f %# '

