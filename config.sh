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

# Create the sparse-checkout file: include everything (/*), then exclude
# Windows-only files by *pattern* rather than naming each file. Any new
# Windows file that matches these shapes is excluded automatically, so the
# two OS install scripts don't drift out of sync.
mkdir -p "$HOME/.dotfiles/info"
cat > "$HOME/.dotfiles/info/sparse-checkout" << EOF
/*
!*.ps1
!AppData/
!Documents/WindowsPowerShell/
!.config/oh-my-posh/
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
