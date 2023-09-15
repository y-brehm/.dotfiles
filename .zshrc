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
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export VISUAL=nvim
export EDITOR="$VISUAL"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CONAN_REVISIONS_ENABLED=1
export TERM=xterm-256color
export PATH="$HOMEBREW_PREFIX/opt/python@3.9/libexec/bin:$PATH"

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
        # PLACE Linux specific commands here
    ;;

esac
