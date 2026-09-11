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
# Directory navigation
# ---------------------------------------------------------------------------
setopt AUTO_CD           # Type a directory name on its own to cd into it
setopt AUTO_PUSHD        # Every cd pushes onto the directory stack
setopt PUSHD_IGNORE_DUPS # Don't stack the same directory twice
setopt PUSHD_SILENT      # Don't print the stack on every cd

# With AUTO_PUSHD, `cd -<Tab>` offers a numbered menu of recent directories.

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
# Git
alias gst="git status"
alias gc="git commit"
alias gl="git log"
alias gaa="git add ."
alias gp="git push"
alias gb="git branch"
alias gco="git checkout"
alias gsw="git switch"
alias gd="git diff"
alias glg="git log --oneline --graph --decorate --all"
# --force-with-lease refuses the push if someone else has pushed since your
# last fetch, unlike a bare --force which would overwrite their work.
alias gpf="git push --force-with-lease"

# General
alias ll="ls -la"
alias ..="cd .."

# ---------------------------------------------------------------------------
# Prompt
# ---------------------------------------------------------------------------
# vcs_info populates $vcs_info_msg_0_ with the current branch and its state.
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '+'    # staged changes
zstyle ':vcs_info:*' unstagedstr '!'  # unstaged changes
zstyle ':vcs_info:git:*' formats       ' %F{magenta}%b%f%F{yellow}%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{magenta}%b%f %F{red}(%a)%f%F{yellow}%u%c%f'

# check-for-changes doesn't report untracked files, so add a '?' ourselves.
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
+vi-git-untracked() {
    if git rev-parse --is-inside-work-tree &>/dev/null &&
        [ -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -1)" ]; then
        hook_com[unstaged]+='%F{yellow}?%f'
    fi
}

precmd_vcs_info() { vcs_info }
precmd_functions+=(precmd_vcs_info)

# PROMPT_SUBST re-expands the prompt each time it's drawn, so the branch
# updates as you move between repos.
setopt PROMPT_SUBST
PROMPT='%F{cyan}%n@%m %F{blue}%~%f${vcs_info_msg_0_} %# '

# ---------------------------------------------------------------------------
# Plugins
# ---------------------------------------------------------------------------
# zsh-autosuggestions: suggest commands from history as you type.
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    bindkey '^ ' autosuggest-accept  # Ctrl-Space accepts the suggestion
fi

# fzf: fuzzy finder.
#   Ctrl-R  search history         Ctrl-T  insert a file path
#   Alt-C   cd into a subdirectory
# Ctrl-R replaces zsh's default reverse search; the prefix search bound to
# up/down above is untouched.
if command -v fzf &>/dev/null; then
    # fzf 0.48+ ships its integration via `fzf --zsh`; older versions keep it
    # in the Homebrew prefix.
    if fzf --zsh &>/dev/null; then
        source <(fzf --zsh)
    elif [ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "$HOMEBREW_PREFIX/opt/fzf/shell" ]; then
        source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
        source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
    fi

    export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --info=inline"
    # Show a preview pane when picking files with Ctrl-T.
    export FZF_CTRL_T_OPTS="--preview 'cat {} 2>/dev/null | head -200'"
    # Show the full command, untruncated, when searching history.
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:3:hidden:wrap --bind='?:toggle-preview'"

    # Respect .gitignore and skip .git when fd is available.
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
    fi
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
