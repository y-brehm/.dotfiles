# PowerShell script to install Nerd Fonts on Windows
$fontsDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (-not (Test-Path $fontsDir)) {
    New-Item -Path $fontsDir -ItemType Directory -Force
}

# Function to download and install a font
function Install-Font {
    param (
        [string]$url
    )
    
    $fileName = $url.Split('/')[-1]
    Write-Host "Downloading $fileName"
    
    try {
        # Download the font to the local fonts directory
        Invoke-WebRequest -Uri $url -OutFile "$fontsDir\$fileName"
        
        # Copy to Windows Fonts directory and register in registry
        Copy-Item "$fontsDir\$fileName" -Destination "$env:windir\Fonts"
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $fileName -Value $fileName -PropertyType String -Force
        
        Write-Host "Installed $fileName successfully"
    }
    catch {
        Write-Host "Failed to install $fileName : $_"
    }
}

Write-Host "Installing Nerd Fonts on Windows..."

# RobotoMono
Write-Host "Installing RobotoMono fonts..."
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/RobotoMono/Light/RobotoMonoNerdFontMono-Light.ttf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/RobotoMono/Regular/RobotoMonoNerdFontMono-Regular.ttf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/RobotoMono/Italic/RobotoMonoNerdFontMono-Italic.ttf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/RobotoMono/Bold-Italic/RobotoMonoNerdFontMono-BoldItalic.ttf"

# FiraCode
Write-Host "Installing FiraCode fonts..."
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Bold/FiraCodeNerdFontMono-Bold.ttf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Light/FiraCodeNerdFontMono-Light.ttf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Medium/FiraCodeNerdFontMono-Medium.ttf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFontMono-Regular.ttf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Retina/FiraCodeNerdFontMono-Retina.ttf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/SemiBold/FiraCodeNerdFontMono-SemiBold.ttf"

# CodeNewRoman
Write-Host "Installing CodeNewRoman fonts..."
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/CodeNewRoman/Regular/CodeNewRomanNerdFontMono-Regular.otf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/CodeNewRoman/Italic/CodeNewRomanNerdFontMono-Italic.otf"
Install-Font "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/CodeNewRoman/Bold/CodeNewRomanNerdFontMono-Bold.otf"

Write-Host "Font installation complete."
