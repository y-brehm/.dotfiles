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
- Sparse checkout — only explicitly listed paths are checked out (see `~/.dotfiles/info/sparse-checkout`)
- `showUntrackedFiles = no` — untracked files are hidden by default in `config status`

## Tracked files
| Area | Path(s) |
|---|---|
| Shell | `~/.zshrc`, `~/.p10k.zsh` |
| Git | `~/.gitconfig`, `~/.gitignore` |
| Neovim | `~/.config/nvim/` |
| Kitty | `~/.config/kitty/` |
| pip / uv | `~/.config/pip/pip.conf`, `~/.config/uv/uv.toml` |
| Scripts | `~/bin/concat_files`, `~/config.sh`, `~/full_install.sh`, `~/install_fonts.sh`, `~/install_prerequisites.sh` |
| Windows (sparse-excluded on macOS) | `AppData/…`, `Documents/WindowsPowerShell/…`, `config.ps1`, `install_fonts.ps1` |

## Key conventions
- Editor: `nvim` (set as `$EDITOR` / `$VISUAL`)
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
