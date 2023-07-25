#!/bin/bash

OS=`uname`
if [[ "$OS" == "Linux" ]]; then
    echo "Installing fonts on Linux"
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing fonts on macOS"
    cd ~/Library/Fonts
else
    echo "Unsupported operating system"
    exit 1
fi  

# RobotoMono
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/RobotoMono/Light/RobotoMonoNerdFontMono-Light.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/RobotoMono/Regular/RobotoMonoNerdFontMono-Regular.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/RobotoMono/Italic/RobotoMonoNerdFontMono-Italic.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/RobotoMono/Bold-Italic/RobotoMonoNerdFontMono-BoldItalic.ttf

# FiraCode 
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Bold/FiraCodeNerdFontMono-Bold.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Light/FiraCodeNerdFontMono-Light.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Medium/FiraCodeNerdFontMono-Medium.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFontMono-Regular.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Retina/FiraCodeNerdFontMono-Retina.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/SemiBold/FiraCodeNerdFontMono-SemiBold.ttf

# CodeNewRoman
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/CodeNewRoman/Regular/CodeNewRomanNerdFontMono-Regular.otf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/CodeNewRoman/Italic/CodeNewRomanNerdFontMono-Italic.otf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/CodeNewRoman/Bold/CodeNewRomanNerdFontMono-Bold.otf

