# Clone the bare repository
git clone --bare https://github.com/y-brehm/.dotfiles.git $HOME\.dotfiles

# Define config function for this session
function config {
    git --git-dir=$HOME\.dotfiles --work-tree=$HOME $args
}

# Set up sparse checkout
config config core.sparseCheckout true

# Create the sparse-checkout file with the files to include
# We'll use the inverse approach - specify what to exclude using negative patterns
$sparseCheckoutPath = "$HOME\.dotfiles\info\sparse-checkout"
$sparseCheckoutDir = Split-Path -Path $sparseCheckoutPath -Parent

# Create directory if it doesn't exist
if (-not (Test-Path $sparseCheckoutDir)) {
    New-Item -Path $sparseCheckoutDir -ItemType Directory -Force | Out-Null
}

# Add patterns to sparse-checkout file (exclude specific files/folders)
@"
/*
!README.md
!config.sh
!install_fonts.sh
!.zshrc
!.p10k.zsh
!install_prerequisites.sh
!full_install.sh
!.config/kitty/
"@ | Out-File -FilePath $sparseCheckoutPath -Encoding utf8

# Create a backup directory
New-Item -Path $HOME\.dotfiles-backup -ItemType Directory -Force | Out-Null

# Try checkout
$checkoutResult = config checkout 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Output "Checked out dotfiles from git@github.com:y-brehm/.dotfiles.git"
} else {
    Write-Output "Moving existing dotfiles to ~/.dotfiles-backup"
    
    # Find and move conflicting files
    $conflictingFiles = $checkoutResult | Select-String "^\s+\." | ForEach-Object { 
        [regex]::Match($_, "\s+(.+)").Groups[1].Value 
    }
    
    foreach ($file in $conflictingFiles) {
        $source = Join-Path $HOME $file
        $destination = Join-Path "$HOME\.dotfiles-backup" $file
        $destinationDir = Split-Path $destination -Parent
        
        if (-not (Test-Path $destinationDir)) {
            New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
        }
        
        Move-Item -Path $source -Destination $destination -Force
    }
    
    # Try checkout again
    config checkout
}

# Hide untracked files
config config status.showUntrackedFiles no

# Create symbolic links for Neovim
$nvimConfigSource = "$HOME\.config\nvim"
$nvimConfigDestination = "$env:LOCALAPPDATA\nvim"

Write-Output "Setting up Neovim symbolic links..."

# Check if the Neovim configuration folder exists in the dotfiles
if (Test-Path $nvimConfigSource) {
    # Create parent directory if it doesn't exist
    $nvimConfigParent = Split-Path -Path $nvimConfigDestination -Parent
    if (-not (Test-Path $nvimConfigParent)) {
        New-Item -Path $nvimConfigParent -ItemType Directory -Force | Out-Null
    }
    
    # Create the symbolic link
    Write-Output "Creating symbolic link for Neovim configuration..."
    New-Item -ItemType SymbolicLink -Path $nvimConfigDestination -Target $nvimConfigSource -Force
    
    Write-Output "Neovim configuration linked to $nvimConfigDestination"
} else {
    Write-Output "Warning: Neovim configuration not found in dotfiles at $nvimConfigSource"
}

Write-Output "Dotfiles setup complete. macOS-specific files have been excluded."
