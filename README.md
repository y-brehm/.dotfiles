# .dotfiles

Cross-platform dotfiles and config scripts, managed as a **bare git repository**
with `$HOME` as the work-tree. A [sparse checkout](https://git-scm.com/docs/git-sparse-checkout)
keeps OS-specific files (e.g. PowerShell profiles on Windows, zsh/kitty config on
Unix) out of the wrong platform.

## Layout

| Area | Path(s) |
|---|---|
| Shell (Unix) | `.zshrc`, `.p10k.zsh` |
| Shell (Windows) | `Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`, `.config/oh-my-posh/powerlevel10k_lean.omp.json` |
| Git | `.gitconfig`, `.gitignore` |
| Neovim | `.config/nvim/` (shared) |
| Terminal | `.config/kitty/` (Unix), `AppData/.../WindowsTerminal/.../settings.json` (Windows) |
| pip / uv | `.config/pip/pip.conf`, `.config/uv/uv.toml` |
| Install scripts | `config.{sh,ps1}`, `install_fonts.{sh,ps1}`, `install_prerequisites.{sh,ps1}`, `full_install.sh` |

## Install

### Unix (macOS / Linux)

Full setup (prerequisites + dotfiles + fonts + Neovim plugins):

```bash
curl -fsSL https://raw.githubusercontent.com/y-brehm/.dotfiles/main/full_install.sh | /bin/bash
```

Or step by step:

```bash
curl -fsSL https://raw.githubusercontent.com/y-brehm/.dotfiles/main/config.sh | /bin/bash
curl -fsSL https://raw.githubusercontent.com/y-brehm/.dotfiles/main/install_fonts.sh | /bin/bash
```

### Windows (PowerShell)

Run from an **elevated** PowerShell (Chocolatey needs admin):

```powershell
irm https://raw.githubusercontent.com/y-brehm/.dotfiles/main/install_prerequisites.ps1 | iex
irm https://raw.githubusercontent.com/y-brehm/.dotfiles/main/config.ps1 | iex
irm https://raw.githubusercontent.com/y-brehm/.dotfiles/main/install_fonts.ps1 | iex
nvim --headless "+Lazy! restore" +qa
```

`install_prerequisites.ps1` installs the toolchain (git, compiler, Neovim, CLI
tools) via Chocolatey, plus uv (official installer), tree-sitter (npm), conan
(uv), and yazi (winget). `config.ps1` then clones the repo, applies the sparse
checkout, backs up any conflicting existing files to `~/.dotfiles-backup`, and
symlinks `~/.config/nvim` into `%LOCALAPPDATA%\nvim` so Neovim finds it. The final
`Lazy! restore` installs plugins at the versions pinned in `lazy-lock.json`.

C++ projects additionally need the MSVC build tools (Visual Studio); install those
separately.

## How the install works

Each `config` script:

1. Clones the repo bare into `~/.dotfiles`.
2. Enables `core.sparseCheckout` and writes `~/.dotfiles/info/sparse-checkout`
   with a denylist: include everything (`/*`), then exclude the *other* OS's files
   with pattern-based `!` rules.
3. Checks out into `$HOME`, moving any conflicting pre-existing files to
   `~/.dotfiles-backup`.
4. Sets `status.showUntrackedFiles no` so `$HOME` clutter is hidden.

## Daily use (`config` alias)

The repo defines a `config` alias (in `.zshrc`) for working with the bare repo:

```bash
config status
config add .zshrc
config commit -m "..."
config push
```

The alias expands to `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`.

## Modify (owner only)

Switch the remote to SSH to push (owner-only writes):

```bash
config remote set-url origin git@github.com:y-brehm/.dotfiles.git
```
