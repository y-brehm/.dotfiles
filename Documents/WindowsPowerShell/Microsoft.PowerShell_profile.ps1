oh-my-posh init pwsh --config ~/.config/oh-my-posh/powerlevel10k_lean.omp.json | Invoke-Expression

# Set EDITOR for Claude Code and other CLI tools
$env:EDITOR = "nvim"

# Function to manage dotfiles
function config {
    git --git-dir=$HOME\.dotfiles --work-tree=$HOME $args
}

Import-Module PSFzf

# Set fzf to use fd for file searching (much faster)
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
$env:FZF_CTRL_T_COMMAND = "$env:FZF_DEFAULT_COMMAND"

function y {
	$tmp = (New-TemporaryFile).FullName
	yazi.exe $args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
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
