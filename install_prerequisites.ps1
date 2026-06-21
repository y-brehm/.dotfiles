# Windows development environment prerequisites.
# Mirror of install_prerequisites.sh for Unix. Uses Chocolatey for the main
# toolchain, with tool-native installers where choco is unsuitable
# (tree-sitter via npm, conan via uv, yazi via winget per its docs).
#
# Run from an *elevated* PowerShell (choco needs admin):
#   irm https://raw.githubusercontent.com/y-brehm/.dotfiles/main/install_prerequisites.ps1 | iex

# --- logging helpers ---------------------------------------------------------
function Log-Info  { param([string]$m) Write-Host "[INFO] $m"  -ForegroundColor Green }
function Log-Warn  { param([string]$m) Write-Host "[WARN] $m"  -ForegroundColor Yellow }
function Log-Error { param([string]$m) Write-Host "[ERROR] $m" -ForegroundColor Red }

# --- admin check -------------------------------------------------------------
function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Log-Error "This script needs an elevated shell. Re-run PowerShell as Administrator."
    return
}

# --- ensure Chocolatey -------------------------------------------------------
function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Log-Info "Chocolatey already installed"
        return
    }
    Log-Info "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = `
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Refresh PATH/env in the current session after installs so later steps see them.
function Refresh-Env {
    $chocoProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path $chocoProfile) {
        Import-Module $chocoProfile -ErrorAction SilentlyContinue
        Update-SessionEnvironment
    }
}

# --- data-driven choco package list ------------------------------------------
$ChocoPackages = [ordered]@{
    core        = @("git", "git-lfs")
    compiler    = @("llvm")            # clang; needed by nvim-treesitter to build parsers
    dev_tools   = @("cmake", "ninja", "neovim", "luarocks")
    shell_tools = @("ripgrep", "fd", "fzf", "lazygit", "zoxide", "lsd")
    python      = @("python")
    node        = @("nodejs")
}

# PowerShell Gallery modules imported by the PowerShell profile (not choco
# packages). Without these a fresh machine errors on every new shell.
$PSGalleryModules = @("PSFzf", "posh-git")

function Install-ChocoPackages {
    foreach ($category in $ChocoPackages.Keys) {
        Log-Info "Installing $category packages..."
        foreach ($pkg in $ChocoPackages[$category]) {
            choco install $pkg -y --no-progress
        }
    }
    Refresh-Env
}

# --- tool-native installs ----------------------------------------------------
function Install-Uv {
    # Mirror the Unix script: use uv's official standalone installer (no choco/scoop).
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        Log-Info "uv already installed"
        return
    }
    Log-Info "Installing uv (official installer)..."
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    # The installer drops uv in ~\.local\bin; make it visible in this session.
    $uvBin = "$HOME\.local\bin"
    if ((Test-Path $uvBin) -and ($env:Path -notlike "*$uvBin*")) {
        $env:Path = "$uvBin;$env:Path"
    }
}

function Install-TreeSitterCli {
    if (Get-Command tree-sitter -ErrorAction SilentlyContinue) {
        Log-Info "tree-sitter CLI already installed"
        return
    }
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Log-Info "Installing tree-sitter CLI via npm..."
        npm install -g tree-sitter-cli
    } else {
        Log-Warn "npm not found; skipping tree-sitter CLI (install Node first)"
    }
}

function Install-Conan {
    if (Get-Command conan -ErrorAction SilentlyContinue) {
        Log-Info "conan already installed"
        return
    }
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        Log-Info "Installing conan via uv..."
        uv tool install conan
    } else {
        Log-Warn "uv not found; skipping conan"
    }
}

function Install-Yazi {
    # yazi's docs advise against choco/scoop on Windows; use winget.
    if (Get-Command yazi -ErrorAction SilentlyContinue) {
        Log-Info "yazi already installed"
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        Log-Info "Installing yazi via winget..."
        winget install --id sxyazi.yazi -e --accept-source-agreements --accept-package-agreements
    } else {
        Log-Warn "winget not found; install yazi manually (https://yazi-rs.github.io/docs/installation/)"
    }

    # yazi needs file(1) on Windows; Git for Windows ships it. Wire up YAZI_FILE_ONE.
    $gitFile = "C:\Program Files\Git\usr\bin\file.exe"
    if ((Test-Path $gitFile) -and -not [Environment]::GetEnvironmentVariable("YAZI_FILE_ONE", "User")) {
        Log-Info "Setting YAZI_FILE_ONE to Git's file.exe"
        [Environment]::SetEnvironmentVariable("YAZI_FILE_ONE", $gitFile, "User")
    }
}

function Install-PowerShellModules {
    # The PowerShell profile imports these Gallery modules (PSFzf for fzf
    # keybindings, posh-git for git status in the prompt). They are not choco
    # packages, so install them from the PowerShell Gallery here.
    $missing = $PSGalleryModules | Where-Object { -not (Get-Module -ListAvailable -Name $_) }
    if (-not $missing) {
        Log-Info "PowerShell modules already installed ($($PSGalleryModules -join ', '))"
        return
    }
    # Bootstrap NuGet provider + trust the gallery so installs run unattended.
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
    }
    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne "Trusted") {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    foreach ($module in $missing) {
        Log-Info "Installing $module module from the PowerShell Gallery..."
        Install-Module -Name $module -Scope CurrentUser -Force -AcceptLicense
    }
}

# --- verification ------------------------------------------------------------
function Verify-Installation {
    Log-Info "Verifying installations..."
    $tools = @{
        git = "git"; "git-lfs" = "git-lfs"; nvim = "neovim"; cmake = "cmake";
        ninja = "ninja"; clang = "llvm"; rg = "ripgrep"; fd = "fd"; fzf = "fzf";
        lazygit = "lazygit"; zoxide = "zoxide"; lsd = "lsd"; luarocks = "luarocks";
        node = "nodejs"; python = "python"; uv = "uv"; "tree-sitter" = "tree-sitter-cli";
        conan = "conan"; yazi = "yazi"
    }
    foreach ($cmd in ($tools.Keys | Sort-Object)) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            Log-Info "[ok] $cmd"
        } else {
            Log-Warn "[missing] $cmd ($($tools[$cmd]))"
        }
    }
    foreach ($module in $PSGalleryModules) {
        if (Get-Module -ListAvailable -Name $module) {
            Log-Info "[ok] $module (module)"
        } else {
            Log-Warn "[missing] $module (module)"
        }
    }
}

# --- main --------------------------------------------------------------------
Log-Info "Starting Windows development environment setup..."

Install-Chocolatey
Refresh-Env
Install-ChocoPackages
Install-Uv
Install-TreeSitterCli
Install-Conan
Install-Yazi
Install-PowerShellModules
Verify-Installation

Log-Info "Setup complete. Restart your shell so PATH changes take effect."
Log-Warn "C++ projects also need the MSVC build tools (Visual Studio) - install separately if required."
