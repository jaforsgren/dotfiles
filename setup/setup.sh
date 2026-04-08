#!/bin/bash

echo "🚀 Installing Brew..."

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

echo "🚀 Setting keyboard mapping..."

# --- 1. Set CapsLock to Escape ---
defaults write -g TISRomanSwitchState -bool true
defaults write com.apple.keyboard.modifiermapping.1452-641-0 -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771113</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>'

DEV_DIR="$HOME/DEV"
if [ ! -d "$DEV_DIR" ]; then
  echo "Creating DEV folder: $DEV_DIR"
  mkdir -p "$DEV_DIR"
fi

# # --- 2. Remap NumLock to ⌘+Space (for layout switching) ---
# echo "Remapping NumLock to switch keyboard layouts..."
# if ! command -v hidutil &> /dev/null; then
#     echo "Error: 'hidutil' not found. This requires macOS 10.12+."
#     exit 1
# fi
#
# # Create a temporary remap file (resets after reboot)
# cat << 'EOF' > /tmp/keyboard_remap.json
# {
#     "UserKeyMapping": [
#         {
#             "HIDKeyboardModifierMappingSrc": 0x700000053,  // NumLock key
#             "HIDKeyboardModifierMappingDst": 0x7000000E0   // Left Command
#         }
#     ]
# }
# EOF
#
# # Apply the remap
# hidutil property --set "$(cat /tmp/keyboard_remap.json)"
#
# # Make it persistent (runs at login)
# echo "Making NumLock remap persistent..."
# cat << 'EOF' >> ~/.bashrc
# # Remap NumLock to ⌘ (for layout switching)
# if command -v hidutil &> /dev/null; then
#     hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000053,"HIDKeyboardModifierMappingDst":0x7000000E0}]}' &> /dev/null
# fi
# EOF

# --- 3. Run another script (if needed) ---

echo "🚀 Installing brews..."

./brew_install.sh

# --- 4. Create .bashrc if missing ---
[ ! -f ~/.bashrc ] && touch ~/.bashrc

# --- 5. Append to .bashrc ---

echo "🚀 Setting up bashrc..."

cat <<'EOF' >>~/.bashrc
# Custom aliases
export PATH="/usr/local/bin:$PATH"
 root .bashrc :
 if [ -f $HOME/DEV/notes/setup/.bashrc ]; then
   . $HOME/DEV/notes/setup/.bashrc
fi
EOF

# --- 6. Download & Extract Wallpapers ---
echo "🚀 Setting up wallpapers..."
WALLPAPER_URL="https://drive.usercontent.google.com/u/0/uc?id=1Zh9WFb7llSvzieWWyeR8a6lqF-dnAFuh&export=download" # CHANGE THIS
PICS_DIR="$HOME/Pictures/Wallpapers"
mkdir -p "$PICS_DIR"
curl -L "$WALLPAPER_URL" -o /tmp/wallpapers.zip
unzip -qo /tmp/wallpapers.zip -d "$PICS_DIR"
rm /tmp/wallpapers.zip

# --- 7. Set Wallpaper Cycling ---
# sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "UPDATE data SET value = '$PICS_DIR'"
# killall Dock

echo "🚀 Setting up Neovim with LazyVim..."

# Install Neovim (if not installed)
if ! command -v nvim &>/dev/null; then
  echo "Installing Neovim..."
  brew install neovim
fi

# Clone your LazyVim config
echo "📦 Cloningconfig..."
git clone git@github.com:jaforsgren/vim-config.git "$NVIM_DIR"

# Install LazyVim dependencies (optional)
if command -v npm &>/dev/null; then
  echo "📌 Installing recommended LSP servers (optional)..."
  npm install -g typescript typescript-language-server pyright
fi

# --- 8. Install LLM Models via Ollama ---
echo "🚀 Setting up ollama..."

if ! command -v ollama &>/dev/null; then
  echo "Ollama not found. Install it from https://ollama.ai"
  exit 1
fi
ollama pull llama2
ollama pull mistral
ollama pulll deepseek-coder-v2
ollama pull qwen2.5-coder

echo "✅ Done! Press NumLock + Space to switch layouts. Reboot to apply all changes."
