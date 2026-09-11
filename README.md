# Dotfiles

A Zsh and Git configuration for macOS: fuzzy finding, history search,
completions, syntax highlighting, autosuggestions, a git-aware prompt, and
sensible Git defaults. `setup.sh` installs the dependencies and symlinks
everything into place.

## Layout

```
dotfiles/
├── Brewfile           # dependencies, installed via `brew bundle`
├── zshrc              # shell config      -> ~/.zshrc
├── gitconfig          # git config        -> ~/.gitconfig
├── gitignore_global   # global ignores    -> ~/.gitignore_global
├── setup.sh           # installs and links everything
└── README.md
```

Each file is **symlinked** into `$HOME`, so any change you make to your live
config is immediately version-controlled. There are no generated copies to keep
in sync.

## Prerequisites

- macOS with Zsh (the default since Catalina).
- Homebrew. If it isn't installed, `setup.sh` installs it for you.

Both Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`) prefixes are
supported automatically.

## Installation

```bash
git clone git@github.com:antriavasileiou/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./setup.sh
exec zsh
```

The script is safe to re-run. Any existing config file is moved to
`<name>.backup.<timestamp>` before the symlink is created — nothing is
overwritten in place.

On a machine that already has a Git identity configured, `setup.sh` migrates it
into `~/.gitconfig.local` for you. On a fresh machine it writes a template there
and tells you to fill it in:

```ini
[user]
	name = Your Name
	email = you@example.com
```

## Shell features

### Prompt

```
antria@Antrias-MacBook-Pro ~/projects/dotfiles main!? %
```

The branch appears in magenta whenever you're inside a repo, followed by its
state:

| Marker | Meaning              |
| ------ | -------------------- |
| `+`    | staged changes       |
| `!`    | unstaged changes     |
| `?`    | untracked files      |
| `(…)`  | rebase/merge running |

### Fuzzy finding (fzf)

| Key      | Does                                              |
| -------- | ------------------------------------------------- |
| `Ctrl-R` | Fuzzy-search your whole shell history             |
| `Ctrl-T` | Fuzzy-find a file and insert its path at the cursor |
| `Alt-C`  | Fuzzy-find a subdirectory and `cd` into it        |

`Ctrl-T` shows a preview of the file. In `Ctrl-R`, press `?` to expand a long
command. This replaces Zsh's default reverse search; the prefix search on ↑/↓
below is unaffected.

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

### Syntax highlighting and autosuggestions

Commands, arguments, paths, and errors are coloured as you type. Suggestions
from your history appear in grey ahead of the cursor — press → or `Ctrl-Space`
to accept.

### Directory navigation

Type a directory name on its own to `cd` into it — no `cd` needed. Every `cd`
is also recorded on the directory stack, so `cd -<Tab>` gives you a numbered
menu of where you've recently been.

### Aliases

| Alias | Command                                    |
| ----- | ------------------------------------------ |
| `gst` | `git status`                               |
| `gc`  | `git commit`                               |
| `gl`  | `git log`                                  |
| `glg` | `git log --oneline --graph --decorate --all` |
| `gd`  | `git diff`                                 |
| `gb`  | `git branch`                               |
| `gco` | `git checkout`                             |
| `gsw` | `git switch`                               |
| `gaa` | `git add .`                                |
| `gp`  | `git push`                                 |
| `gpf` | `git push --force-with-lease`              |
| `ll`  | `ls -la`                                   |
| `..`  | `cd ..`                                    |

`gpf` uses `--force-with-lease` rather than `--force`: it refuses the push if
someone else has pushed since your last fetch, instead of silently overwriting
their work.

## Git features

The tracked `gitconfig` sets these defaults:

- **`push.autoSetupRemote`** — first push on a new branch just works, no
  `--set-upstream`.
- **`pull.rebase`** — pulling replays your commits on top instead of creating a
  merge commit.
- **`fetch.prune`** — local refs for deleted remote branches are cleaned up.
- **`rebase.autoStash`** — uncommitted work is stashed and restored around a
  rebase.
- **`rerere`** — records how you resolved a conflict and replays it if the same
  conflict reappears.
- **`merge.conflictStyle = zdiff3`** — conflict markers include the original
  text, not just the two sides.
- **`diff.algorithm = histogram`** and **`colorMoved`** — more readable diffs,
  with moved blocks distinguished from real changes.
- **`help.autocorrect`** — a typo'd command runs the correction after 1s.

`gitignore_global` covers editor and OS noise (`.DS_Store`, `.idea/`, `.vscode/`)
so individual projects don't each need to.

## Customization

Edit `zshrc` or `gitconfig` in this repo and run `exec zsh` — the symlinks mean
there's nothing to reinstall. Commit when you're happy.

To add a tool, add a line to the `Brewfile` and re-run `./setup.sh`.

For anything machine-specific that shouldn't be committed:

| File                | Purpose                                            |
| ------------------- | -------------------------------------------------- |
| `~/.zshrc.local`    | Work tokens, one-off `PATH` entries, local aliases |
| `~/.gitconfig.local`| Git identity, per-machine Git settings             |

Both are sourced automatically if present and neither is tracked by this repo.

## Troubleshooting

**Syntax highlighting, autosuggestions, or fzf not working**

Confirm the formulae are present and that Homebrew is on your `PATH`:

```bash
brew bundle check --file=Brewfile
echo "$HOMEBREW_PREFIX"
```

If `HOMEBREW_PREFIX` is empty, your shell hasn't picked up Homebrew — start a
new shell with `exec zsh`, or reinstall with `brew bundle --file=Brewfile`.

**Git is committing under the wrong name**

`git config --global user.email` will look empty, because `--global` doesn't
follow the `include` directive by default. Ask the right question instead:

```bash
git config --includes user.email
```

Then correct it in `~/.gitconfig.local`.

**The prompt feels slow in a large repo**

The branch state is computed on every prompt. In a very large working tree, drop
`check-for-changes` to `false` in the `vcs_info` block of `zshrc` — you'll keep
the branch name but lose the `+!?` markers.

**Reverting to your previous config**

`setup.sh` leaves backups in place. To restore one:

```bash
rm ~/.zshrc
mv ~/.zshrc.backup.<timestamp> ~/.zshrc
```

## License

Available under the [MIT License](LICENSE).
