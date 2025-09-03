#!/usr/bin/env bash

echo "==================================="
echo "Development Environment Setup"
echo "==================================="

# 1. Install prerequisites and tools
echo "Step 1: Installing prerequisites and development tools..."
curl -fsSL https://raw.githubusercontent.com/y-brehm/.dotfiles/main/install_prerequisites.sh | bash

# 2. Setup dotfiles
echo "Step 2: Setting up dotfiles..."
curl -fsSL https://raw.githubusercontent.com/y-brehm/.dotfiles/main/config.sh | bash

# 3. Install fonts
echo "Step 3: Installing fonts..."
curl -fsSL https://raw.githubusercontent.com/y-brehm/.dotfiles/main/install_fonts.sh | bash

# 4. Setup Neovim plugins
echo "Step 4: Initializing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa

echo "==================================="
echo "Setup complete!"
echo "Please restart your terminal or run: source ~/.zshrc"
echo "==================================="
