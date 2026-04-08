export PATH=/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/Library/pnpm:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin

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
export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
