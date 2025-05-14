# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "romkatv/powerlevel10k"
plug "hlissner/zsh-autopair"
plug "wintermi/zsh-brew"
plug "MichaelAquilina/zsh-you-should-use"

plug "jeffreytse/zsh-vi-mode"
plug "zsh-users/zsh-history-substring-search"

# source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# configure zsh-history-substring-search
# did not work in wsl
# bindkey '^[[A' history-substring-search-up
# bindkey '^[[B' history-substring-search-down
#
# works in wsl but needs to be checked on macOS
# bindkey "$terminfo[kcuu1]" history-substring-search-up
# bindkey "$terminfo[kcud1]" history-substring-search-down
#
# for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# P10k theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load and initialise completion system
autoload -Uz compinit
compinit

# environment variables
export VISUAL=nvim
export EDITOR="$VISUAL"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CONAN_REVISIONS_ENABLED=1
export TERM=xterm-256color
export PATH="$HOMEBREW_PREFIX/opt/python@3.9/libexec/bin:$PATH"

#llvm clang 13
export LLVM_ROOT="$(brew --prefix llvm@13)"
export LDFLAGS="-L${LLVM_ROOT}/lib -L${LLVM_ROOT}/lib/c++ -Wl,-rpath,${LLVM_ROOT}/lib/c++"

# carapace
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

# Aliases
alias vim="nvim"
alias git_rinse="git clean -xfd
                 git submodule foreach --recursive git clean -xfd
                 git reset --hard
                 git submodule foreach --recursive git reset --hard
                 git submodule update --init --recursive"
alias config="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias kitdiff="git difftool --no-symlinks --dir-diff"
alias ll='ls -lG'
alias build_pd="conan install . -s build_type=Debug --install-folder=cmake-build-debug
                cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -B cmake-build-debug .
                cmake --build cmake-build-debug
                rm ~/Documents/Pd/externals/*pd_darwin 
                cp externals/Mac/*pd_darwin ~/Documents/Pd/externals"

alias create_venv="python3 -m venv .venv
                   source .venv/bin/activate"

alias venv="source .venv/bin/activate"

alias install_req="pip install -r requirements.txt
                   pip install -r dev_requirements.txt"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
 
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# MACOS Linux specific setup
case "$(uname -s)" in

    Darwin)
        # PLACE macOS specific commands here
    ;;

    Linux)
        if uname -r | grep -q "WSL"; then
            /usr/bin/keychain -q --nogui $HOME/.ssh/work_id_ed25519
            /usr/bin/keychain -q --nogui $HOME/.ssh/personal_id_ed25519
            source $HOME/.keychain/$(hostname)-sh
            alias explorer='explorer.exe .'
        fi
        # PLACE Linux specific commands here
    ;;

esac

cc_vim() {
    conan install . -s build_type=Debug --install-folder=cmake-build-debug \
    && cmake -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=Debug -DCMAKE_OSX_ARCHITECTURES=arm64 -B cmake-build-debug . \
    && ln -sf $(pwd)/cmake-build-debug/compile_commands.json $(pwd)/
}

ciab() {
    conan install . -s build_type=Debug --install-folder=cmake-build-debug \
    && cmake -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=Debug -B cmake-build-debug . \
    && ln -sf $(pwd)/cmake-build-debug/compile_commands.json $(pwd)/ \
    && cmake --build cmake-build-debug --target "${1:-all}"
}

pip_manage_urls() {
    local PIP_CONF="$HOME/.config/pip/pip.conf"
    local UV_CONF="$HOME/.config/uv/uv.toml"
    local action=$1
    shift
    local urls=("$@")

    case "$action" in
        "add")
            mkdir -p "$(dirname "$PIP_CONF")"
            [ ! -f "$PIP_CONF" ] && echo "[global]" > "$PIP_CONF"
            [ ! -f "$UV_CONF" ] && echo 'extra-index-url=[]' > "$UV_CONF"
            
            for url in "${urls[@]}"; do
                if ! grep -q "${url}" "$PIP_CONF" 2>/dev/null; then
                    if ! grep -q "extra-index-url" "$PIP_CONF"; then
                        echo "extra-index-url = ${url}" >> "$PIP_CONF"
                    else
                        if grep -q "^extra-index-url = *$" "$PIP_CONF"; then
                            sed -i.bak "s|^extra-index-url = *$|extra-index-url = ${url}|" "$PIP_CONF"
                        else
                            sed -i.bak "s|extra-index-url = \(.*\)|extra-index-url = \1 ${url}|" "$PIP_CONF"
                        fi
                    fi
                fi
                if ! grep -q "${url}" "$UV_CONF" 2>/dev/null; then
                    if grep -q "extra-index-url=\[\]" "$UV_CONF"; then
                        sed -i.bak "s|\[\]|[\"${url}\"]|" "$UV_CONF"
                    else
                        sed -i.bak "s|\[\(.*\)\]|[\1, \"${url}\"]|" "$UV_CONF"
                    fi
                fi
            done
            ;;
        "remove")
            for url in "${urls[@]}"; do
                [ -f "$PIP_CONF" ] && sed -i.bak "s| ${url}||g" "$PIP_CONF"
                if [ -f "$UV_CONF" ]; then
                    # Handle single URL case
                    if grep -q "^\s*extra-index-url=\[\s*\"${url}\"\s*\]" "$UV_CONF"; then
                        echo 'extra-index-url=[]' > "$UV_CONF"
                    else
                        sed -i.bak "s|\"${url}\", *||g" "$UV_CONF"  # Remove if first
                        sed -i.bak "s|, *\"${url}\"||g" "$UV_CONF"  # Remove if not first
                    fi
                fi
            done
            ;;
    esac
}

enable-pip-devpi() { pip_manage_urls add "http://localhost:3141/testuser/dev/+simple/" }
disable-pip-devpi() { pip_manage_urls remove "http://localhost:3141/testuser/dev/+simple/" }

if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
