export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/local/bin:/usr/local/bin:/Users/johanforsgren/.nvm/versions/node//bin:/usr/local/bin:/Users/johanforsgren/.nvm/versions/node//bin:/usr/local/bin:/Users/johanforsgren/.nvm/versions/node//bin:/Users/johanforsgren/Library/pnpm:/usr/local/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin

# include .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Andriod studio stuff
# /Users/johanforsgren/Library/Android/sdk
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

echo "Bash profile loaded"
# Add .NET Core SDK tools
export PATH="$PATH:/Users/johanforsgren/.dotnet/tools"

# add Pulumi to the PATH
export PATH=$PATH:/Users/johanforsgren/.pulumi/bin
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
