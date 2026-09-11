# ~/.zshrc — managed by https://github.com/antria/dotfiles
# This file is a symlink to the `zshrc` in your dotfiles repo. Edit it freely;
# changes are version-controlled automatically.

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
# Works on both Apple Silicon (/opt/homebrew) and Intel (/usr/local).
if [ -z "${HOMEBREW_PREFIX:-}" ]; then
    for brew_candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_candidate" ]; then
            eval "$("$brew_candidate" shellenv)"
            break
        fi
    done
    unset brew_candidate
fi

# ---------------------------------------------------------------------------
# Completions
# ---------------------------------------------------------------------------
# Expose Homebrew's completion functions (git, brew, etc.) before compinit runs.
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]; then
    FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"
fi

autoload -Uz compinit
# Rebuild the completion cache at most once a day instead of on every shell start.
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qNmh-24) ]]; then
    compinit -C -d "${ZDOTDIR:-$HOME}/.zcompdump"
else
    compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
fi

# Case-insensitive matching, and a menu you can arrow through.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
export HISTFILE=~/.zsh_history
export HISTSIZE=50000
export SAVEHIST=50000

setopt EXTENDED_HISTORY       # Record timestamp against each command
setopt HIST_EXPIRE_DUPS_FIRST # Trim duplicates first when the file is full
setopt HIST_IGNORE_DUPS       # Don't record a command run twice in a row
setopt HIST_IGNORE_SPACE      # Leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS     # Tidy up whitespace before saving
setopt HIST_VERIFY            # Expand !! into the line instead of running it blind
setopt SHARE_HISTORY          # Share history across concurrent sessions

# ---------------------------------------------------------------------------
# Key bindings
# ---------------------------------------------------------------------------
# Up/down search history using everything typed before the cursor.
autoload -Uz history-beginning-search-backward-end history-beginning-search-forward-end
zle -N history-beginning-search-backward-end
zle -N history-beginning-search-forward-end

bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end
# Same keys as reported by terminfo, for terminals in application mode.
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-beginning-search-backward-end
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-beginning-search-forward-end

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias gst="git status"
alias gc="git commit"
alias gl="git log"
alias gaa="git add ."
alias gp="git push"

alias ll="ls -la"
alias ..="cd .."

# ---------------------------------------------------------------------------
# Prompt
# ---------------------------------------------------------------------------
PROMPT='%F{cyan}%n@%m %F{blue}%~%f %# '

# ---------------------------------------------------------------------------
# Plugins
# ---------------------------------------------------------------------------
# zsh-autosuggestions: suggest commands from history as you type.
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    bindkey '^ ' autosuggest-accept  # Ctrl-Space accepts the suggestion
fi

# zsh-syntax-highlighting must be sourced last — it wraps every widget defined
# above it, and anything bound afterwards won't be highlighted.
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ---------------------------------------------------------------------------
# Local overrides — machine-specific settings, not tracked in git.
# ---------------------------------------------------------------------------
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
