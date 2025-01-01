# Dotfiles Setup Script

This repository provides a shell script to set up a customized `.zshrc` file with command completions, history search, syntax highlighting, autosuggestions, and Git shortcuts on macOS. The script also installs required dependencies using Homebrew.

## Features

- **Command Completions and History Search**:
  - Navigate through command history using up/down arrows based on typed keywords.

- **Git Shortcuts**:
  - `gst` for `git status`
  - `gc` for `git commit`
  - `gl` for `git log`

- **Syntax Highlighting**:
  - Highlights commands, arguments, paths, and errors in the terminal.

- **Autosuggestions**:
  - Suggests commands from history as you type.

## Prerequisites

- macOS with Zsh (default on macOS Catalina and later).
- Homebrew installed. If not, the script will install it.

## Installation

1. Clone this repository or copy the script file `setup_dotfiles.sh`.

   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. Make the script executable:

   ```bash
   chmod +x setup_dotfiles.sh
   ```

3. Run the script:

   ```bash
   ./setup_dotfiles.sh
   ```

4. Restart your terminal to apply the changes.

## How It Works

1. **Homebrew Installation**:
   - If Homebrew is not installed, the script downloads and installs it.

2. **Dependencies Installation**:
   - Installs `zsh-syntax-highlighting` and `zsh-autosuggestions` using Homebrew.

3. **Dotfile Configuration**:
   - Creates or updates the `.zshrc` file in the user’s home directory with the following:
     - Command completions and history search.
     - Aliases for Git commands.
     - Syntax highlighting and autosuggestions.
     - Custom prompt.

4. **Immediate Application**:
   - Sources the `.zshrc` file to apply changes immediately.

## Example Usage

- **Command History Search**:
  - Type `mvn` and press the up arrow to find previous commands starting with `mvn`.

- **Git Shortcuts**:
  - `gst` displays the current Git status.
  - `gc` opens the Git commit prompt.
  - `gl` shows the Git log.

- **Autosuggestions**:
  - As you type, suggested commands from your history will appear in light gray. Press the right arrow or `Ctrl-Space` to accept.

## Customization

Feel free to edit the `.zshrc` file after running the script to add more aliases, environment variables, or further customizations.

## Troubleshooting

- If syntax highlighting or autosuggestions are not working, ensure the dependencies are correctly installed via Homebrew:

  ```bash
  brew reinstall zsh-syntax-highlighting zsh-autosuggestions
  ```

- Check that your `.zshrc` file sources the plugins correctly.

## License

This project is open source and available under the [MIT License](LICENSE).

