#!/usr/bin/env bash
#
# Installs dependencies from the Brewfile and links this repo's config files
# into $HOME. Safe to re-run: existing files are backed up, never replaced
# in place.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # The installer doesn't touch the current shell's PATH, so load it here.
    for brew_candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_candidate" ]; then
            eval "$("$brew_candidate" shellenv)"
            break
        fi
    done
fi

if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew installation did not succeed; cannot continue." >&2
    exit 1
fi

echo "Homebrew is available at $(command -v brew)."

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------
echo "Installing dependencies from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ---------------------------------------------------------------------------
# Link the config files
# ---------------------------------------------------------------------------
link_config() {
    local source_file="$DOTFILES_DIR/$1"
    local target_file="$HOME/$2"

    if [ ! -f "$source_file" ]; then
        echo "Error: $source_file not found. Run this from a full clone of the repo." >&2
        exit 1
    fi

    if [ -L "$target_file" ] && [ "$(readlink "$target_file")" = "$source_file" ]; then
        echo "  ~/$2 is already linked."
        return
    fi

    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        local backup="$target_file.backup.$(date +%Y%m%d%H%M%S)"
        echo "  Existing ~/$2 found. Backing it up to $(basename "$backup")."
        mv "$target_file" "$backup"
    fi

    ln -s "$source_file" "$target_file"
    echo "  Linked ~/$2 -> $source_file"
}

# Capture the git identity before ~/.gitconfig is replaced, so that moving to
# the tracked config doesn't leave you committing as nobody.
EXISTING_GIT_NAME="$(git config --global user.name || true)"
EXISTING_GIT_EMAIL="$(git config --global user.email || true)"

echo "Linking config files..."
link_config zshrc .zshrc
link_config gitconfig .gitconfig
link_config gitignore_global .gitignore_global

# ---------------------------------------------------------------------------
# Git identity
# ---------------------------------------------------------------------------
# The tracked gitconfig deliberately contains no name or email so it can be
# shared publicly. Identity goes in ~/.gitconfig.local, which stays untracked.
GITCONFIG_LOCAL="$HOME/.gitconfig.local"

if [ ! -f "$GITCONFIG_LOCAL" ]; then
    if [ -n "$EXISTING_GIT_NAME" ] || [ -n "$EXISTING_GIT_EMAIL" ]; then
        echo "Migrating your git identity into ~/.gitconfig.local..."
        cat >"$GITCONFIG_LOCAL" <<EOF
[user]
	name = $EXISTING_GIT_NAME
	email = $EXISTING_GIT_EMAIL
EOF
    else
        echo "No git identity found. Writing a template to ~/.gitconfig.local..."
        cat >"$GITCONFIG_LOCAL" <<'EOF'
# Untracked, machine-specific git settings. Included by the tracked gitconfig.
[user]
	name = Your Name
	email = you@example.com
EOF
    fi
fi

# --includes is needed here: it defaults to off when a specific config file is
# named (as --global does), so without it the identity in ~/.gitconfig.local is
# invisible and this check would always fire.
CURRENT_GIT_EMAIL="$(git config --global --includes user.email || true)"

if [ -z "$CURRENT_GIT_EMAIL" ] || [ "$CURRENT_GIT_EMAIL" = "you@example.com" ]; then
    echo
    echo "  ACTION NEEDED: set your name and email in ~/.gitconfig.local"
else
    echo "Git identity: $(git config --global --includes user.name) <$CURRENT_GIT_EMAIL>"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
# Note: this script runs under bash, so it can't source the zsh config itself.
cat <<'MSG'

Dotfile setup complete.

Start a new shell to pick up the changes:

    exec zsh

MSG
