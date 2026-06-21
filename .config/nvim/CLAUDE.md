# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a comprehensive Neovim configuration using the Lazy.nvim plugin manager. The configuration follows a modular structure:

- `init.lua`: Main entry point that loads Lazy.nvim and core configuration
- `lua/config/`: Core configuration modules (options, keymaps, custom actions)
- `lua/plugins/`: Individual plugin configurations organized by functionality
- `lua/overseer/template/user/`: Custom Overseer task templates

## Key Components

### Plugin Manager
Uses Lazy.nvim with automatic bootstrapping. Plugin specifications are in `lua/plugins/` with lazy loading enabled for most plugins.

### Task Execution System
Primary task execution uses Overseer.nvim integrated with ToggleTerm:
- Overseer manages long-running tasks with UI
- Tasks open in horizontal terminal splits (not floating)
- Custom templates for C++/Conan workflows

### Development Environment
Configured for C++ and Rust development with:
- **C++**: CMake integration via cmake-tools.nvim, Conan package manager support, clangd LSP with extensions
- **Rust**: rustaceanvim for rust-analyzer integration, cargo support, automatic DAP setup
- **Debugging**: DAP debugging for C++ (codelldb), Python (debugpy), and Rust (codelldb)

### Key Plugin Categories
- **LSP**: nvim-lspconfig, Mason for server management
- **Completion**: nvim-cmp with multiple sources
- **UI**: Catppuccin theme, Neo-tree, Telescope, Edgy for window management
- **Git**: Gitsigns, Diffview
- **Testing**: Neotest with Python adapter

## Common Commands

### Task Management (Overseer)
- `<leader>ot` - Toggle Overseer UI
- `<leader>oa` - Run available tasks
- `<leader>ocd` - Run Conan install (Debug)
- `<leader>ocr` - Run Conan install (Release)
- `<leader>obd` - Full build Debug (Conan install + CMake configure + build)
- `<leader>obr` - Full build Release (Conan install + CMake configure + build)
- `<leader>ola` - Launch host application (custom action)

### CMake Integration

#### Basic CMake Commands
- `<leader>cmg` - Generate build system (configure)
- `<leader>cmb` - Build project
- `<leader>cmr` - Run launch target
- `<leader>cmd` - Debug launch target
- `<leader>cmt` - Select build target
- `<leader>cml` - Select launch target
- `<leader>cmv` - Select build type/variant (only for non-preset workflows)
- `<leader>cmp` - Select configure preset (for preset-based workflows)

#### Recommended Workflow for Conan Projects
For projects using Conan with CMakePresets (cmake_layout in conanfile), use the Overseer full build tasks:

**One-Command Build (Recommended)**
- `<leader>obd` - Complete Debug build (Conan install + CMake configure + build + symlink compile_commands.json)
- `<leader>obr` - Complete Release build (Conan install + CMake configure + build + symlink compile_commands.json)

These tasks handle everything in one go: installing dependencies, configuring CMake with the correct preset, creating the compile_commands.json symlink for LSP, and building the project.

**Manual Workflow (if needed)**
1. `<leader>ocd` or `<leader>ocr` - Run Conan install
2. `<leader>cmp` - Select matching preset (conan-debug or conan-release)
3. `<leader>cmg` - Generate build system
4. `<leader>cmb` - Build project

**Note**: Build variant selection (`<leader>cmv`) only works for non-preset workflows. When using CMake presets, select the correct preset with `<leader>cmp` instead.

### Rust Development (rustaceanvim)

#### Running and Testing
- `<leader>rr` - Rust Runnables (run main, examples, etc.)
- `<leader>rd` - Rust Debuggables (debug with DAP)
- `<leader>rt` - Rust Testables (run tests)

#### Code Actions and Navigation
- `<leader>ca` - Rust Code Actions
- `<leader>ce` - Explain Error
- `<leader>cR` - Render Diagnostics
- `K` - Hover Actions (extended)
- `<leader>rM` - Go to Parent Module
- `<leader>rc` - Open Cargo.toml

#### Macro and Advanced Features
- `<leader>rm` - Expand Macro
- `<leader>rp` - Rebuild Proc Macros
- `<leader>rg` - View Crate Graph
- `<leader>rv` - View Syntax Tree
- `<leader>rh` - View HIR (High-level Intermediate Representation)
- `<leader>ri` - View MIR (Mid-level Intermediate Representation)

#### Code Manipulation
- `J` - Join Lines (Rust-aware)
- `<leader>rmu` - Move Item Up
- `<leader>rmd` - Move Item Down
- `<leader>fb` - Format Buffer (rustfmt)

**Important Notes:**
- rustaceanvim automatically configures rust-analyzer (DO NOT configure it separately through lspconfig)
- rust-analyzer is installed via Mason
- DAP debugging uses the same codelldb adapter as C++
- Run `:RustLsp` to see all available commands

### Development Workflow
- Space is the leader key
- Uses system clipboard by default (`clipboard = 'unnamedplus'`)
- 4-space indentation, no swap files
- Relative line numbers enabled

## Custom Task Templates

### Conan Integration
Located in `lua/overseer/template/user/`:
- `conan_debug.lua` - Conan install only (Debug build type)
- `conan_release.lua` - Conan install only (Release build type)
- `conan_cmake_debug.lua` - Full workflow: Conan install + CMake configure + build (Debug)
- `conan_cmake_release.lua` - Full workflow: Conan install + CMake configure + build (Release)
- Automatically available when `conanfile.py` or `conanfile.txt` is present
- Full workflow tasks also create symlink for `compile_commands.json` for LSP integration

### Host Application Launcher
Custom action in `lua/config/custom_actions.lua` allows launching arbitrary executables through Overseer with UI prompt.

## Platform Support
Cross-platform configuration with Windows-specific PowerShell integration for shell commands.