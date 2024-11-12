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
plug "zap-zsh/sudo"
plug "zsh-users/zsh-history-substring-search"

# configure zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

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
                cmake --build cmake-build-debug"
                # rm ~/Documents/Pd/externals/*pd_darwin 
                # cp externals/Mac/*pd_darwin ~/Documents/Pd/externals"
alias create_venv="python3 -m venv .venv
                   source .venv/bin/activate"
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
        /usr/bin/keychain -q --nogui $HOME/.ssh/work_id_ed25519
        source $HOME/.keychain/$(hostname)-sh
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
