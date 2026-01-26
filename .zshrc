# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# --- Plugins ---
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "romkatv/powerlevel10k"
plug "hlissner/zsh-autopair"
plug "MichaelAquilina/zsh-you-should-use"
plug "jeffreytse/zsh-vi-mode"
plug "zsh-users/zsh-history-substring-search"

if [[ "$(uname -s)" == "Darwin" ]]; then
    plug "wintermi/zsh-brew"
elif [[ "$(uname -s)" == "Linux" ]] && [[ "$(uname -m)" != "armv"* ]] && [[ "$(uname -m)" != "aarch64" ]]; then
    if command -v brew >/dev/null; then
        plug "wintermi/zsh-brew"
    fi
fi

# --- Keybindings ---
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# --- P10k Theme ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Completions ---
autoload -Uz compinit
compinit

# --- Environment Variables ---
export VISUAL=nvim
export EDITOR="$VISUAL"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CONAN_REVISIONS_ENABLED=1
export TERM=xterm-256color

# --- PATH Setup ---
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# --- Carapace ---
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
if command -v carapace >/dev/null; then
    source <(carapace _carapace)
fi
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

# --- Aliases ---
if command -v lsd >/dev/null; then
    alias ls="lsd"
fi
alias vim="nvim"

alias git_rinse="git clean -xfd && git submodule foreach --recursive git clean -xfd && git reset --hard && git submodule foreach --recursive git reset --hard && git submodule update --init --recursive"
alias config="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
# alias kitdiff="git difftool --no-symlinks --dir-diff"
alias ll='ls -lG'

# --- Functions ---
venv() {
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
    else
        echo "Error: No venv activation script found in .venv/"
        return 1
    fi
}

create_venv() {
    python3 -m venv .venv && venv
}

install_req() {
    pip install -r requirements.txt && \
    [ -f "dev_requirements.txt" ] && pip install -r dev_requirements.txt
}

cc_vim() {
    conan install . -s build_type=Debug --install-folder=cmake-build-debug
    
    local cmake_args=("-G" "Ninja" "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" "-DCMAKE_BUILD_TYPE=Debug" "-B" "cmake-build-debug" ".")
    if [[ "$(uname -s)" == "Darwin" ]] && [[ "$(uname -m)" == "arm64" ]]; then
        cmake_args+=("-DCMAKE_OSX_ARCHITECTURES=arm64")
    fi
    cmake "${cmake_args[@]}" && ln -sf "$(pwd)/cmake-build-debug/compile_commands.json" "$(pwd)/"
}

ciab() {
    conan install . -s build_type=Debug --install-folder=cmake-build-debug
    cmake -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=Debug -B cmake-build-debug .
    ln -sf "$(pwd)/cmake-build-debug/compile_commands.json" "$(pwd)/"
    cmake --build cmake-build-debug --target "${1:-all}"
}

pip_manage_urls() {
    local action="$1"
    local url="$2"
    local config_file="$HOME/.pip/pip.conf"
    
    if [[ "$action" == "add" ]]; then
        if [[ -z "$url" ]]; then
            echo "Usage: pip_manage_urls add <url>"
            return 1
        fi
        mkdir -p "$(dirname "$config_file")"
        if [[ ! -f "$config_file" ]]; then
            cat > "$config_file" << EOF
[global]
extra-index-url = $url
EOF
        else
            if grep -q "extra-index-url" "$config_file"; then
                if ! grep -q "$url" "$config_file"; then
                    sed -i.bak "s|extra-index-url = \(.*\)|extra-index-url = \1 $url|" "$config_file"
                fi
            else
                echo "extra-index-url = $url" >> "$config_file"
            fi
        fi
        echo "Added $url to pip configuration"
    elif [[ "$action" == "remove" ]]; then
        if [[ -f "$config_file" ]]; then
            sed -i.bak "s| $url||g; s|$url ||g; s|^extra-index-url = $url$||" "$config_file"
            echo "Removed $url from pip configuration"
        fi
    else
        echo "Usage: pip_manage_urls {add|remove} <url>"
        return 1
    fi
}

# --- OS-Specific Configuration ---
case "$(uname -s)" in
    Darwin)
        # --- macOS Specific ---
        export HOMEBREW_PREFIX="/opt/homebrew"
        if [[ -d "$HOMEBREW_PREFIX" ]]; then
            export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
        fi
    ;;

    Linux)
        if [[ "$(uname -m)" != "armv"* ]] && [[ "$(uname -m)" != "aarch64" ]]; then
            if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            elif [[ -d "$HOME/.linuxbrew" ]]; then
                eval "$($HOME/.linuxbrew/bin/brew shellenv)"
            fi
        fi
        if uname -r | grep -q "WSL"; then
            # Load SSH keys with keychain if available
            if command -v keychain >/dev/null; then
                local ssh_keys=()
                # Check for common SSH key patterns
                for key_file in "$HOME/.ssh/work_id_ed25519" "$HOME/.ssh/personal_id_ed25519" "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_rsa"; do
                    if [[ -f "$key_file" ]]; then
                        ssh_keys+=("$key_file")
                    fi
                done
                # Load found keys
                if [ ${#ssh_keys[@]} -gt 0 ]; then
                    /usr/bin/keychain -q --nogui "${ssh_keys[@]}"
                    source $HOME/.keychain/$(hostname)-sh
                fi
            fi
            alias explorer='explorer.exe .'
        fi
    ;;
esac

# --- Load local/private config ---
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
