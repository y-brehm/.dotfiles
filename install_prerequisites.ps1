# Windows development environment prerequisites.
# Mirror of install_prerequisites.sh for Unix. Uses Chocolatey for the main
# toolchain, with tool-native installers where choco is unsuitable
# (tree-sitter via npm, conan via uv, yazi via winget per its docs, and
# neovide + nightly WezTerm via scoop — see Install-ScoopApps).
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
    # Mason ([Core utils] in :checkhealth) shells out to these archivers. curl,
    # tar and 7z come from Windows/other packages; unzip/gzip/wget do not, so
    # add them here to silence the warnings and let every Mason package install.
    mason_utils = @("unzip", "gzip", "wget")
    shell_tools = @("ripgrep", "fd", "fzf", "lazygit", "zoxide", "lsd")
    python      = @("python")
    node        = @("nodejs")
    # WezTerm is installed via scoop (nightly), not choco — see Install-ScoopApps.
    # Rust toolchain (cargo, rustc, rustfmt, clippy). rustaceanvim drives
    # rust-analyzer (installed via Mason) but needs a real toolchain to build,
    # run and test. rustup also lets rust-analyzer find the std-library source.
    rust        = @("rustup.install")
    # ImageMagick provides `magick`, used by snacks.image / render-markdown to
    # render images inline in graphics-capable terminals (WezTerm).
    image       = @("imagemagick.app")
}

# PowerShell Gallery modules imported by the PowerShell profile (not choco
# packages). Without these a fresh machine errors on every new shell.
$PSGalleryModules = @("PSFzf", "posh-git")

# Probe command each choco package provides. Used to detect a pre-existing
# install from ANY source (scoop, winget, a standalone installer) so we never
# stack a second, choco-managed copy on top of a tool you already have. That
# duplication causes nondeterministic PATH shadowing - the exact problem this
# guard prevents.
$ChocoProbe = @{
    "git" = "git"; "git-lfs" = "git-lfs"; "llvm" = "clang"; "cmake" = "cmake";
    "ninja" = "ninja"; "neovim" = "nvim"; "luarocks" = "luarocks";
    "unzip" = "unzip"; "gzip" = "gzip"; "wget" = "wget"; "ripgrep" = "rg";
    "fd" = "fd"; "fzf" = "fzf"; "lazygit" = "lazygit"; "zoxide" = "zoxide";
    "lsd" = "lsd"; "python" = "python"; "nodejs" = "node";
    "rustup.install" = "rustup"; "imagemagick.app" = "magick"
}

function Install-ChocoPackages {
    # Snapshot what Chocolatey already manages so re-runs are true no-ops.
    $chocoInstalled = @{}
    foreach ($line in (choco list --limit-output 2>$null)) {
        $id = ($line -split '\|')[0]
        if ($id) { $chocoInstalled[$id.ToLower()] = $true }
    }
    foreach ($category in $ChocoPackages.Keys) {
        Log-Info "Installing $category packages..."
        foreach ($pkg in $ChocoPackages[$category]) {
            if ($chocoInstalled.ContainsKey($pkg.ToLower())) {
                Log-Info "  $pkg already managed by Chocolatey; skipping"
                continue
            }
            $probe = $ChocoProbe[$pkg]
            if ($probe -and (Get-Command $probe -ErrorAction SilentlyContinue)) {
                Log-Info "  $pkg already present as '$probe' (installed outside Chocolatey); skipping to avoid a duplicate"
                continue
            }
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

function Install-ScoopApps {
    # neovide (GUI Neovim) + nightly WezTerm, both via scoop.
    #
    # Why scoop and not choco/winget: neither packages WezTerm *nightly*, and we
    # need it. On Windows, Claude Code's Ctrl+G ("edit prompt in editor") hands
    # the ConPTY to the child editor. Terminal nvim crashes stable WezTerm on
    # that handoff and can't receive input even on nightly; neovide opens in its
    # own window and sidesteps it. So the working combo is nightly WezTerm as the
    # terminal + neovide as $EDITOR (set in the PowerShell profile).
    #
    # scoop refuses to run elevated and these are user-scope GUI apps, so this
    # step cannot run inside the elevated choco bootstrap. When we're admin (the
    # normal case here), print the one-liner to run in a NON-admin shell instead.
    $apps = "scoop bucket add extras; scoop bucket add versions; scoop install neovide wezterm-nightly"
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Log-Warn "scoop not found. In a NON-admin shell, install scoop then the apps:"
        Log-Warn "  irm get.scoop.sh | iex"
        Log-Warn "  $apps"
        return
    }
    if (Test-Admin) {
        Log-Warn "neovide + nightly WezTerm need scoop, which won't run elevated."
        Log-Warn "In a NON-admin shell run:"
        Log-Warn "  $apps"
        return
    }
    Log-Info "Installing neovide + nightly WezTerm via scoop..."
    scoop bucket add extras 2>$null
    scoop bucket add versions 2>$null
    scoop install neovide wezterm-nightly
}

# Resolve pwsh.exe even when a just-installed copy isn't on this session's PATH
# yet (winget drops it in Program Files\PowerShell\7). Returns $null if absent.
function Get-PwshPath {
    $cmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $default = Join-Path $env:ProgramFiles "PowerShell\7\pwsh.exe"
    if (Test-Path $default) { return $default }
    return $null
}

function Install-PowerShell7 {
    # The interactive shell is now PowerShell 7: WezTerm launches pwsh and the
    # profile lives in Documents\PowerShell. Install it via winget (preferred for
    # supply-chain trust) rather than choco. Windows PowerShell 5.1 ships with
    # Windows but PS7 does not, so a fresh machine needs this explicitly.
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        Log-Info "PowerShell 7 (pwsh) already installed"
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        Log-Info "Installing PowerShell 7 via winget..."
        winget install --id Microsoft.PowerShell -e --accept-source-agreements --accept-package-agreements
    } else {
        Log-Warn "winget not found; install PowerShell 7 manually (https://aka.ms/powershell)"
    }
}

function Install-RustToolchain {
    # choco's rustup.install installs rustup; ensure a default stable toolchain
    # plus the components rustaceanvim expects (rustfmt for <leader>fb, clippy).
    if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
        Log-Warn "rustup not found; skipping Rust toolchain setup"
        return
    }
    Log-Info "Ensuring a default Rust toolchain (stable + rustfmt, clippy)..."
    rustup default stable
    rustup component add rustfmt clippy
    # rust-analyzer (installed via Mason) resolves std sources from this.
    rustup component add rust-src
}

# Set $LANG so Neovim reports a UTF-8 locale. Without it :checkhealth flags
# "Locale does not support UTF-8" and some unicode glyphs may not render.
function Set-Utf8Locale {
    if ([Environment]::GetEnvironmentVariable("LANG", "User")) {
        Log-Info "LANG already set for the user"
        return
    }
    Log-Info "Setting LANG=en_US.UTF-8 (User) for a UTF-8 locale in Neovim"
    [Environment]::SetEnvironmentVariable("LANG", "en_US.UTF-8", "User")
    $env:LANG = "en_US.UTF-8"
}

function Install-PowerShellModules {
    # The PowerShell profile imports these Gallery modules (PSFzf for fzf
    # keybindings, posh-git for git status in the prompt). They must land in
    # PowerShell 7's module path (Documents\PowerShell\Modules), which differs
    # from Windows PowerShell 5.1's (Documents\WindowsPowerShell\Modules). Run
    # the install *through pwsh* so -Scope CurrentUser resolves to PS7's path
    # even when this bootstrap script is launched from 5.1.
    $names = ($PSGalleryModules | ForEach-Object { "'" + $_ + "'" }) -join ','
    $body = @"
`$ErrorActionPreference = 'Stop'
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
}
if ((Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}
foreach (`$m in @($names)) {
    if (Get-Module -ListAvailable -Name `$m) {
        Write-Host "[INFO] `$m module already installed" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Installing `$m module from the PowerShell Gallery..." -ForegroundColor Green
        Install-Module -Name `$m -Scope CurrentUser -Force -AcceptLicense -Repository PSGallery
    }
}
"@
    $pwsh = Get-PwshPath
    if ($pwsh) {
        Log-Info "Installing PowerShell modules into the PS7 module path: $($PSGalleryModules -join ', ')"
        & $pwsh -NoLogo -NoProfile -Command $body
    } else {
        Log-Warn "pwsh not found; installing modules for the current PowerShell ($($PSVersionTable.PSVersion))"
        Invoke-Expression $body
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
        conan = "conan"; yazi = "yazi"; cargo = "rustup.install"; rustc = "rustup.install";
        magick = "imagemagick.app"; unzip = "unzip"; gzip = "gzip"; wget = "wget";
        wezterm = "wezterm-nightly (scoop)"; neovide = "neovide (scoop)"
    }
    foreach ($cmd in ($tools.Keys | Sort-Object)) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            Log-Info "[ok] $cmd"
        } else {
            Log-Warn "[missing] $cmd ($($tools[$cmd]))"
        }
    }
    # PowerShell 7 (installed via winget, may not be on this session's PATH yet).
    if (Get-PwshPath) { Log-Info "[ok] pwsh (PowerShell 7)" } else { Log-Warn "[missing] pwsh (Microsoft.PowerShell)" }
    # Verify the Gallery modules in PS7 (that's where they were installed and
    # where the profile loads them); fall back to the current shell if no pwsh.
    $pwsh = Get-PwshPath
    foreach ($module in $PSGalleryModules) {
        $present = if ($pwsh) {
            (& $pwsh -NoLogo -NoProfile -Command "[bool](Get-Module -ListAvailable -Name '$module')") -eq 'True'
        } else {
            [bool](Get-Module -ListAvailable -Name $module)
        }
        if ($present) { Log-Info "[ok] $module (module)" } else { Log-Warn "[missing] $module (module)" }
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
Install-ScoopApps
Install-PowerShell7
Install-RustToolchain
Set-Utf8Locale
Install-PowerShellModules
Verify-Installation

Log-Info "Setup complete. Restart your shell so PATH changes take effect."
Log-Warn "C++ projects also need the MSVC build tools (Visual Studio) - install separately if required."
