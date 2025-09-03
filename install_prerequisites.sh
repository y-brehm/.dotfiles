#!/usr/bin/env bash

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS and architecture
detect_platform() {
    OS="unknown"
    ARCH=$(uname -m)
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        # Check if it's WSL
        if grep -q Microsoft /proc/version 2>/dev/null; then
            IS_WSL=true
        fi
    fi
    
    # Determine if ARM
    if [[ "$ARCH" == "arm"* ]] || [[ "$ARCH" == "aarch64" ]]; then
        IS_ARM=true
    fi
    
    log_info "Detected: OS=$OS, ARCH=$ARCH, ARM=${IS_ARM:-false}, WSL=${IS_WSL:-false}"
}

# Setup ZSH as default shell
setup_zsh() {
    if [[ "$SHELL" != */zsh ]]; then
        log_info "Setting ZSH as default shell..."
        if command -v zsh >/dev/null 2>&1; then
            chsh -s $(which zsh)
            log_info "ZSH set as default shell. You'll need to log out and back in for this to take effect."
        else
            log_warn "ZSH not yet installed, will be installed with other packages"
        fi
    else
        log_info "ZSH is already the default shell"
    fi
}

# Install package manager
setup_package_manager() {
    if [[ "$OS" == "macos" ]] || ([[ "$OS" == "linux" ]] && [[ "$IS_ARM" != "true" ]]); then
        # Use Homebrew for macOS and regular Linux
        if ! command -v brew >/dev/null 2>&1; then
            log_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Add to PATH for Linux
            if [[ "$OS" == "linux" ]]; then
                if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
                    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                elif [[ -d "$HOME/.linuxbrew" ]]; then
                    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
                fi
            fi
        fi
        PKG_MANAGER="brew"
        PKG_INSTALL_CMD="brew install"
    elif [[ "$OS" == "linux" ]] && [[ "$IS_ARM" == "true" ]]; then
        # Use apt for ARM Linux
        if ! command -v apt-get >/dev/null 2>&1; then
            log_error "apt-get not found on ARM Linux system"
            exit 1
        fi
        
        # Install essentials first
        log_info "Installing essential packages..."
        sudo apt-get update
        sudo apt install git zsh build-essential curl unzip wget python3-pip python3-venv -y
        
        # Setup locale
        log_info "Setting up locale..."
        sudo locale-gen en_US.UTF-8
        
        PKG_MANAGER="apt"
        PKG_INSTALL_CMD="sudo apt-get install -y"
    fi
    
    log_info "Package manager: $PKG_MANAGER"
}

# Data-driven package definitions
declare -A PACKAGES_BREW=(
    ["core"]="git git-lfs zsh curl unzip wget"
    ["shell_tools"]="lsd carapace fzf zoxide ripgrep fd lazygit zsh-history-substring-search"
    ["dev_tools"]="cmake ninja conan neovim luarocks"
    ["python"]="python@3.13"
    ["node"]="node"
)

declare -A PACKAGES_APT=(
    ["core"]="git git-lfs zsh curl unzip wget"
    ["shell_tools"]="lsd carapace-bin fzf ripgrep fd-find"
    ["dev_tools"]="cmake ninja-build neovim"
    ["python"]="python3 python3-pip python3-venv"
    ["node"]="nodejs npm"
    ["lua"]="liblua5.1-0-dev"
    ["wsl_specific"]="keychain"
)

# Install packages based on package manager
install_packages() {
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        for category in "${!PACKAGES_BREW[@]}"; do
            log_info "Installing $category packages..."
            for package in ${PACKAGES_BREW[$category]}; do
                if ! brew list "$package" &>/dev/null; then
                    $PKG_INSTALL_CMD "$package"
                else
                    log_info "$package already installed"
                fi
            done
        done
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        for category in "${!PACKAGES_APT[@]}"; do
            # Skip WSL-specific unless we're in WSL
            if [[ "$category" == "wsl_specific" ]] && [[ "$IS_WSL" != "true" ]]; then
                continue
            fi
            
            log_info "Installing $category packages..."
            for package in ${PACKAGES_APT[$category]}; do
                $PKG_INSTALL_CMD "$package"
            done
        done
        
        # Install tools not in apt repos
        install_apt_special_cases
    fi
}

# Special installations for apt-based systems
install_apt_special_cases() {
    # Install lazygit (not in standard apt repos)
    if ! command -v lazygit >/dev/null 2>&1; then
        log_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    fi
    
    # Install zoxide (better version than apt)
    if ! command -v zoxide >/dev/null 2>&1; then
        log_info "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
    
    # Install conan via pip
    if ! command -v conan >/dev/null 2>&1; then
        log_info "Installing conan via pip..."
        pip3 install --user conan
    fi
    
    # Install luarocks
    if ! command -v luarocks >/dev/null 2>&1; then
        log_info "Installing luarocks..."
        sudo apt-get install -y luarocks
    fi
}

# Setup Python environment for Neovim
setup_python_env() {
    log_info "Setting up Python environment for Neovim..."
    
    # Create directory for virtual environments
    mkdir -p "$HOME/.virtualenvs"
    
    # Create and setup neovim venv
    if [[ ! -d "$HOME/.virtualenvs/neovim" ]]; then
        log_info "Creating Neovim Python virtual environment..."
        python3 -m venv "$HOME/.virtualenvs/neovim"
        
        # Activate and install packages
        source "$HOME/.virtualenvs/neovim/bin/activate"
        pip install --upgrade pip
        pip install pynvim neovim
        deactivate
        
        log_info "Neovim Python environment created at ~/.virtualenvs/neovim"
    else
        log_info "Neovim Python environment already exists"
    fi
}

# Install uv (Python package manager)
install_uv() {
    if ! command -v uv >/dev/null 2>&1; then
        log_info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
            echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    else
        log_info "uv already installed"
    fi
}

# Create necessary directories
setup_directories() {
    log_info "Creating necessary directories..."
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.config"
    
    # Add ~/.local/bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
}

# Verification function
verify_installation() {
    log_info "Verifying installations..."
    
    local required_tools=("git" "zsh" "nvim" "cmake" "ninja" "python3")
    local optional_tools=("lsd" "carapace" "conan" "fzf" "zoxide" "ripgrep" "fd" "lazygit" "uv" "luarocks")
    
    echo ""
    echo "Required tools:"
    for tool in "${required_tools[@]}"; do
        # Special case for fd which might be fd-find
        if [[ "$tool" == "fd" ]] && command -v fd-find >/dev/null 2>&1; then
            log_info "✓ fd (as fd-find) installed"
        elif command -v "$tool" >/dev/null 2>&1; then
            log_info "✓ $tool installed"
        else
            log_error "✗ $tool NOT found"
        fi
    done
    
    echo ""
    echo "Optional tools:"
    for tool in "${optional_tools[@]}"; do
        # Special case for fd which might be fd-find
        if [[ "$tool" == "fd" ]] && command -v fd-find >/dev/null 2>&1; then
            log_info "✓ fd (as fd-find) installed"
        elif command -v "$tool" >/dev/null 2>&1; then
            log_info "✓ $tool installed"
        else
            log_warn "○ $tool not found (optional)"
        fi
    done
    
    # Check Python environment
    if [[ -f "$HOME/.virtualenvs/neovim/bin/python" ]]; then
        log_info "✓ Neovim Python environment configured"
    else
        log_warn "○ Neovim Python environment not found"
    fi
}

# Create fd symlink for fd-find on apt systems
setup_fd_symlink() {
    if [[ "$PKG_MANAGER" == "apt" ]] && command -v fd-find >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        log_info "Creating fd symlink for fd-find..."
        sudo ln -s $(which fd-find) /usr/local/bin/fd
    fi
}

# Main execution
main() {
    log_info "Starting development environment setup..."
    
    detect_platform
    setup_zsh
    setup_package_manager
    setup_directories
    install_packages
    setup_fd_symlink
    setup_python_env
    install_uv
    verify_installation
    
    log_info "Setup complete! You may need to restart your shell or run 'source ~/.zshrc'"
    log_info "Remember to log out and back in for ZSH shell change to take effect"
}

# Run main
main "$@"
