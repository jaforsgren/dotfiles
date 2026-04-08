#!/bin/bash
set -e

echo "Exporting Homebrew packages, casks, and taps..."

brew list --formula > brew_packages.txt
brew list --cask > brew_casks.txt
brew tap > brew_taps.txt

echo "Export completed!"
echo "Files created: brew_packages.txt, brew_casks.txt, brew_taps.txt"
