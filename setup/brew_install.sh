#!/bin/bash
set -e

echo "Installing Homebrew packages, casks, and taps..."

if [ -f brew_taps.txt ]; then
    xargs brew tap < brew_taps.txt
else
    echo "No brew_taps.txt found, skipping..."
fi

if [ -f brew_packages.txt ]; then
    xargs brew install --force < brew_packages.txt
else
    echo "No brew_packages.txt found, skipping..."
fi

if [ -f brew_casks.txt ]; then
    xargs brew install --cask --no-quarantine --force < brew_casks.txt
else
    echo "No brew_casks.txt found, skipping..."
fi

echo "Installation completed!"
