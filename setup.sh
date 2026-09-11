#!/usr/bin/env bash
#
# Installs shell dependencies and links this repo's `zshrc` to ~/.zshrc.
# Safe to re-run: an existing ~/.zshrc is backed up, never silently replaced.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ZSHRC="$DOTFILES_DIR/zshrc"
TARGET_ZSHRC="$HOME/.zshrc"

if [ ! -f "$SOURCE_ZSHRC" ]; then
    echo "Error: $SOURCE_ZSHRC not found. Run this script from a full clone of the repo." >&2
    exit 1
fi

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
for formula in zsh-syntax-highlighting zsh-autosuggestions; do
    if brew list --formula "$formula" &>/dev/null; then
        echo "$formula is already installed."
    else
        echo "Installing $formula..."
        brew install "$formula"
    fi
done

# ---------------------------------------------------------------------------
# Link the config
# ---------------------------------------------------------------------------
if [ -L "$TARGET_ZSHRC" ] && [ "$(readlink "$TARGET_ZSHRC")" = "$SOURCE_ZSHRC" ]; then
    echo "$TARGET_ZSHRC is already linked to $SOURCE_ZSHRC."
elif [ -e "$TARGET_ZSHRC" ] || [ -L "$TARGET_ZSHRC" ]; then
    BACKUP="$TARGET_ZSHRC.backup.$(date +%Y%m%d%H%M%S)"
    echo "Existing $TARGET_ZSHRC found. Backing it up to $BACKUP."
    mv "$TARGET_ZSHRC" "$BACKUP"
    ln -s "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
    echo "Linked $TARGET_ZSHRC -> $SOURCE_ZSHRC."
else
    ln -s "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
    echo "Linked $TARGET_ZSHRC -> $SOURCE_ZSHRC."
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
