oh-my-posh init pwsh --config ~/.config/oh-my-posh/powerlevel10k_lean.omp.json | Invoke-Expression

# Set EDITOR for Claude Code and other CLI tools
$env:EDITOR = "nvim"

# Function to manage dotfiles
function config {
    git --git-dir=$HOME\.dotfiles --work-tree=$HOME $args
}

function venv { & .\.venv\Scripts\activate.ps1 }

Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
New-Alias -Name ls -Value lsd -Force
New-Alias -Name ll -Value lsd -Force
function lsal {
    lsd --long --all
}
Set-Alias -Name "ls-al" -Value lsal

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Import-Module posh-git
