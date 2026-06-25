# Dotfiles — Claude Instructions

## Repository setup
- Bare git repo at `~/.dotfiles`, work-tree is `$HOME`
- **Use the `config` alias for all git operations**, not plain `git`:
  ```bash
  config status
  config add .zshrc
  config commit -m "..."
  config push
  ```
  The alias expands to: `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`
- Remote: `git@github.com:y-brehm/.dotfiles.git` (SSH, owner-only writes)
- Sparse checkout (non-cone, `/*` + exclusions) — everything under `$HOME` is in scope *except* the `!`-negated paths in `~/.dotfiles/info/sparse-checkout` (currently `*.ps1`, `AppData/`, `Documents/WindowsPowerShell/`, `.config/oh-my-posh/`). New files elsewhere are trackable without editing that file.
- `showUntrackedFiles = no` — untracked files are hidden by default in `config status`

## Tracked files
| Area | Path(s) |
|---|---|
| Shell | `~/.zshrc`, `~/.p10k.zsh` |
| Git | `~/.gitconfig`, `~/.gitignore` |
| Neovim | `~/.config/nvim/` |
| WezTerm | `~/.config/wezterm/wezterm.lua` |
| pip / uv | `~/.config/pip/pip.conf`, `~/.config/uv/uv.toml` |
| Scripts | `~/bin/concat_files`, `~/config.sh`, `~/full_install.sh`, `~/install_fonts.sh`, `~/install_prerequisites.sh` |
| Windows (sparse-excluded on macOS) | `AppData/…`, `Documents/PowerShell/…` (PowerShell 7 profile), `config.ps1`, `install_fonts.ps1` |

## Key conventions
- Editor: `nvim`. On macOS/Linux it's `$EDITOR` / `$VISUAL`. On **Windows** `$EDITOR=neovide` (GUI) instead — Claude Code's Ctrl+G editor handoff crashes WezTerm / can't receive input with terminal nvim under ConPTY; git still uses nvim via `core.editor`.
- Terminal: **WezTerm** (`~/.config/wezterm/wezterm.lua`) is the goto terminal on all platforms. **Windows Terminal and Kitty are deprecated** — no longer tracked or maintained. On **Windows** use the **nightly** WezTerm (installed via scoop) — stable WezTerm crashes on Claude Code's Ctrl+G; see `install_prerequisites.ps1` (`Install-ScoopApps`).
- Shell: `zsh` with [Zap](https://github.com/zap-zsh/zap) plugin manager and Powerlevel10k prompt
- Package manager: Homebrew (`/opt/homebrew` on macOS arm64, linuxbrew on Linux x86)
- Build system for C++ projects: Conan + CMake + Ninja
- Python envs: `.venv/` via `venv()` / `create_venv()` helpers in `.zshrc`
- Private/machine-local shell config goes in `~/.zshrc.local` (not tracked)

## Neovim setup
- Config entry: `~/.config/nvim/init.lua` (LazyVim-based)
- Plugins live under `~/.config/nvim/lua/plugins/`
- Overseer task templates: `~/.config/nvim/lua/overseer/template/user/`
- Notable plugins: rustaceanvim, clangd_extensions, dap, neotest, telescope, toggleterm, oil, snacks, diffview, cmake-tools, claude-code
