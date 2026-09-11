# Dotfiles

A Zsh configuration for macOS: history search, completions, syntax highlighting,
autosuggestions, and Git shortcuts. `setup.sh` installs the dependencies and
symlinks the config into place.

## Layout

```
dotfiles/
├── zshrc       # the config — edit this, it's what ~/.zshrc points at
├── setup.sh    # installs dependencies and creates the symlink
└── README.md
```

`~/.zshrc` is a **symlink** to `zshrc` in this repo, so any change you make to
your shell config is immediately version-controlled. There is no generated copy
to keep in sync.

## Prerequisites

- macOS with Zsh (the default since Catalina).
- Homebrew. If it isn't installed, `setup.sh` installs it for you.

Both Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`) prefixes are
supported automatically.

## Installation

```bash
git clone <repository-url> ~/projects/dotfiles
cd ~/projects/dotfiles
./setup.sh
exec zsh
```

The script is safe to re-run. If `~/.zshrc` already exists it is moved to
`~/.zshrc.backup.<timestamp>` before the symlink is created — nothing is
overwritten in place.

## Features

### Git shortcuts

| Alias | Command      |
| ----- | ------------ |
| `gst` | `git status` |
| `gc`  | `git commit` |
| `gl`  | `git log`    |
| `gaa` | `git add .`  |
| `gp`  | `git push`   |

### General shortcuts

| Alias | Command  |
| ----- | -------- |
| `ll`  | `ls -la` |
| `..`  | `cd ..`  |

### History search

Type a prefix and press ↑ / ↓ to walk through matching commands — type `mvn`,
press ↑, and you'll cycle through your previous `mvn` invocations with the
cursor left at the end of the line.

### History behaviour

- 50,000 entries, stored in `~/.zsh_history` with timestamps.
- Shared live across concurrent shell sessions.
- Consecutive duplicates are dropped, and duplicates are evicted first when the
  file fills up.
- A command typed with a leading space is not recorded.
- History expansions like `!!` are loaded onto the command line for review
  rather than executed immediately.

### Completions

Tab completion is case-insensitive, and repeated tabs open a menu you can arrow
through. Homebrew's completion functions (`git`, `brew`, …) are picked up
automatically. The completion cache is rebuilt at most once a day, so new shells
start fast.

### Syntax highlighting

Commands, arguments, paths, and errors are coloured as you type.

### Autosuggestions

Suggestions from your history appear in grey ahead of the cursor. Press → or
`Ctrl-Space` to accept.

## Customization

Edit `zshrc` in this repo and run `exec zsh` — the symlink means there's nothing
to reinstall. Commit when you're happy with it.

For anything machine-specific that shouldn't be committed (work tokens, one-off
`PATH` entries), create `~/.zshrc.local`. It's sourced at the end of the config
if it exists and is not tracked by this repo.

## Troubleshooting

**Syntax highlighting or autosuggestions not working**

Confirm the formulae are present and that Homebrew is on your `PATH`:

```bash
brew list --formula | grep zsh-
echo "$HOMEBREW_PREFIX"
```

If `HOMEBREW_PREFIX` is empty, your shell hasn't picked up Homebrew — start a
new shell with `exec zsh`, or reinstall the formulae with:

```bash
brew reinstall zsh-syntax-highlighting zsh-autosuggestions
```

**Reverting to your previous config**

`setup.sh` leaves backups in place. To restore one:

```bash
rm ~/.zshrc
mv ~/.zshrc.backup.<timestamp> ~/.zshrc
```

## License

Available under the [MIT License](LICENSE).
