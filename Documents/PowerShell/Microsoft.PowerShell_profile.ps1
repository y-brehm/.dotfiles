oh-my-posh init pwsh --config ~/.config/oh-my-posh/powerlevel10k_lean.omp.json | Invoke-Expression

# Emit OSC 7 (working-dir reporting) so WezTerm knows our cwd. oh-my-posh owns
# the `prompt` function, so wrap it to prepend the sequence each redraw. This is
# what lets WezTerm open splits and the Ctrl+Shift+D dev layout in the dir the
# shell is actually in (e.g. after `y` cd's the shell on yazi exit).
$__base_prompt = $function:prompt
function prompt {
    $p = ($PWD.ProviderPath -replace '\\', '/') -replace ' ', '%20'
    $osc7 = "$([char]27)]7;file://$env:COMPUTERNAME/$p$([char]27)\"
    "$osc7$(& $__base_prompt)"
}

# Set EDITOR for Claude Code and other CLI tools
$env:EDITOR = "nvim"

# Function to manage dotfiles
function config {
    git --git-dir=$HOME\.dotfiles --work-tree=$HOME $args
}

# Pull dotfiles and re-sync Neovim plugins to the committed lazy-lock.json.
# lazy.nvim does not auto-revert installed plugins to the lockfile, so plugins
# can silently drift behind the committed lock after a pull on another machine.
function dotpull {
    config pull
    if ($LASTEXITCODE -eq 0) {
        nvim --headless +"Lazy! restore" +qa
    }
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

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
