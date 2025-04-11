#!/usr/bin/env bash

git clone --bare https://github.com/y-brehm/.dotfiles.git $HOME/.dotfiles

# define config alias locally since the dotfiles
# aren't installed on the system yet
function config 
{
   git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

# Set up sparse checkout
config config core.sparseCheckout true

# Create the sparse-checkout file with the files to include
# We'll use the inverse approach - specify what to exclude using negative patterns
mkdir -p "$HOME/.dotfiles/info"
cat > "$HOME/.dotfiles/info/sparse-checkout" << EOF
/*
!install_fonts.ps1
!config.ps1
!Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
!.config/oh-my-posh/powerlevel10k_lean.omp.json
EOF

# Create a backup directory
mkdir -p "$HOME/.dotfiles-backup"

# Try checkout
if config checkout 2>&1 | grep -q "error: The following untracked working tree files would be overwritten by checkout"; then
    echo "Moving existing dotfiles to ~/.dotfiles-backup"
    config checkout 2>&1 | grep -E "^\s+(.+)$" | awk '{print $1}' | xargs -I{} mv ~/{} ~/.dotfiles-backup/{}
    # Try checkout again
    config checkout
fi

# Hide untracked files
config config status.showUntrackedFiles no

if [ -d "$HOME/.config/nvim" ]; then
    echo "Neovim configuration found at ~/.config/nvim"
    echo "No symlink needed for Unix systems as this is the default config location"
else
    echo "Warning: Neovim configuration not found at ~/.config/nvim"
fi

echo "Dotfiles setup complete. Windows-specific files have been excluded."
