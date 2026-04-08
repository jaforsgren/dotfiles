# Simplify Homebrew Setup Across Devices

```bash
# Export installed formulas, casks, and taps
brew list --formula > brew_packages.txt
brew list --cask > brew_casks.txt
brew tap > brew_taps.txt

# Reinstall on a new system
xargs brew install --force < brew_packages.txt
xargs brew install --cask --no-quarantine --force < brew_casks.txt
xargs brew tap < brew_taps.txt
```

- `--force` bypasses installation prompts.
- `--no-quarantine` prevents macOS security prompts for casks.