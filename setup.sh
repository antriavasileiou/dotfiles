#!/bin/bash

# Install Homebrew if not already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Install dependencies
echo "Installing dependencies..."
brew install zsh-syntax-highlighting zsh-autosuggestions

# Create or overwrite the .zshrc file
ZSHRC="$HOME/.zshrc"

cat >"$ZSHRC" <<'EOF'
# Enable command completions and history search
autoload -Uz compinit && compinit
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Custom aliases for Git shortcuts
alias gst="git status"
alias gc="git commit"
alias gl="git log"
alias gaa="git add ."
alias gp="git push"

# General aliases (optional)
alias ll="ls -la"
alias ..="cd .."

# Better history control
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_DUPS  # Ignore duplicate commands
setopt SHARE_HISTORY     # Share history across sessions

# Load completions for Git (if not already available)
if type _git &>/dev/null; then
    autoload -Uz compinit && compinit
    zstyle ':completion:*:*:git:*' script ~/.zshrc
fi

# Source Homebrew shell completions (if installed)
if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
fi

# zsh-syntax-highlighting: Highlight commands and syntax
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# zsh-autosuggestions: Suggest commands from history as you type
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    bindkey '^ ' autosuggest-accept  # Bind Ctrl-Space to accept suggestion
fi

# Prompt customization (with colors)
PROMPT='%F{cyan}%n@%m %F{blue}%~%f %# '
EOF

echo "Configuration written to $ZSHRC."

# Apply the changes
echo "Sourcing $ZSHRC..."
source "$ZSHRC"

echo "Dotfile setup complete! Restart your terminal to ensure all changes take effect."
