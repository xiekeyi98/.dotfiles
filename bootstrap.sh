#!/bin/bash
# Bootstrap script for new machines
#
# Read-only (HTTPS):
#   curl -fsSL https://raw.githubusercontent.com/xiekeyi98/.dotfiles/master/bootstrap.sh | bash
#
# With push access (SSH):
#   curl -fsSL https://raw.githubusercontent.com/xiekeyi98/.dotfiles/master/bootstrap.sh | bash -s -- --ssh
#
# Or clone locally then run:
#   bash bootstrap.sh --ssh
set -e

DOTFILES="$HOME/.dotfiles"
REPO_HTTPS="https://github.com/xiekeyi98/.dotfiles.git"
REPO_SSH="git@github.com:xiekeyi98/.dotfiles.git"
REPO_URL="$REPO_HTTPS"

# Parse args
for arg in "$@"; do
    case "$arg" in
        --ssh) REPO_URL="$REPO_SSH" ;;
        *)     echo "Unknown option: $arg"; echo "Usage: bootstrap.sh [--ssh]"; exit 1 ;;
    esac
done

echo "==> Bootstrapping dotfiles..."
echo "    Remote: $REPO_URL"

# Install Homebrew (macOS)
if [[ "$(uname)" == "Darwin" ]] && ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Clone dotfiles
if [ -d "$DOTFILES" ]; then
    echo "==> Dotfiles already cloned, pulling latest..."
    cd "$DOTFILES" && git pull
else
    echo "==> Cloning dotfiles..."
    git clone "$REPO_URL" "$DOTFILES"
fi

# Install Brewfile (macOS)
if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
    echo "==> Installing Homebrew packages..."
    brew bundle install --file="$DOTFILES/Brewfile" --no-lock
fi

# Run install
echo "==> Running install script..."
bash "$DOTFILES/install.sh"

echo ""
echo "==> Done! Please restart your shell or run: source ~/.zshrc"
