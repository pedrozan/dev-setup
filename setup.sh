#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# Development Environment Bootstrap
# Ubuntu 24.04+
# =========================================================

PYTHON_VERSION="3.11"
NVIM_INSTALL_DIR="/opt/nvim"

# ---------------------------------------------------------
# Helpers
# ---------------------------------------------------------

info() {
    echo
    echo "==> $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ---------------------------------------------------------
# OS checks
# ---------------------------------------------------------

if [[ ! -f /etc/os-release ]]; then
    echo "ERROR: /etc/os-release not found."
    exit 1
fi

source /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "ERROR: This script supports Ubuntu only."
    echo "Detected: ${PRETTY_NAME:-unknown}"
    exit 1
fi

echo "Detected: $PRETTY_NAME"

# ---------------------------------------------------------
# Architecture
# ---------------------------------------------------------

ARCH="$(dpkg --print-architecture)"

case "$ARCH" in
    amd64)
        NVIM_ARCH="x86_64"
        ;;
    arm64)
        NVIM_ARCH="arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# ---------------------------------------------------------
# PATH
# ---------------------------------------------------------

export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------
# System packages
# ---------------------------------------------------------

info "Installing system packages"

sudo apt-get update

sudo apt-get install -y \
    ca-certificates \
    curl \
    git \
    tmux \
    zsh \
    build-essential \
    unzip \
    ripgrep \
    fd-find \
    fzf \
    jq \
    tree \
    wget \
    gnupg

# ---------------------------------------------------------
# Git
# ---------------------------------------------------------

info "Checking Git"

git --version

# ---------------------------------------------------------
# uv
# ---------------------------------------------------------

info "Installing uv"

if ! command_exists uv; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

export PATH="$HOME/.local/bin:$PATH"

uv --version

# ---------------------------------------------------------
# Python
# ---------------------------------------------------------

info "Installing Python ${PYTHON_VERSION}"

uv python install "$PYTHON_VERSION" --default

python3 --version
python --version

# ---------------------------------------------------------
# Neovim
# ---------------------------------------------------------

info "Installing Neovim"

if ! command_exists nvim; then

    tmp_dir="$(mktemp -d)"

    cleanup() {
        rm -rf "$tmp_dir"
    }

    trap cleanup EXIT

    cd "$tmp_dir"

    case "$NVIM_ARCH" in
        x86_64)
            NVIM_ARCHIVE="nvim-linux-x86_64.tar.gz"
            NVIM_DIR="nvim-linux-x86_64"
            ;;
        arm64)
            NVIM_ARCHIVE="nvim-linux-arm64.tar.gz"
            NVIM_DIR="nvim-linux-arm64"
            ;;
    esac

    curl -LO \
        "https://github.com/neovim/neovim/releases/latest/download/${NVIM_ARCHIVE}"

    if [[ ! -d "$NVIM_INSTALL_DIR" ]]; then
        sudo mkdir -p "$NVIM_INSTALL_DIR"
    fi

    sudo tar \
        -C "$NVIM_INSTALL_DIR" \
        --strip-components=1 \
        -xzf "$NVIM_ARCHIVE"

    sudo ln -sf \
        "$NVIM_INSTALL_DIR/bin/nvim" \
        /usr/local/bin/nvim
fi

nvim --version | head -n 1

# ---------------------------------------------------------
# Claude Code
# ---------------------------------------------------------

info "Installing Claude Code"

if ! command_exists claude; then
    curl -fsSL https://claude.ai/install.sh | bash
fi

export PATH="$HOME/.local/bin:$PATH"

if command_exists claude; then
    claude --version
else
    echo "WARNING: Claude Code is installed but not currently on PATH."
fi

# ---------------------------------------------------------
# Oh My Zsh
# ---------------------------------------------------------

info "Installing Oh My Zsh"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no \
    CHSH=no \
    KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ---------------------------------------------------------
# Zsh configuration
# ---------------------------------------------------------

info "Configuring Zsh"

ZSH_PATH="$(command -v zsh)"

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]]; then
    sudo usermod --shell "$ZSH_PATH" "$USER"
fi

# Link the repo-managed Zsh configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_SOURCE="$SCRIPT_DIR/zsh/.zshrc"
ZSHRC_TARGET="$HOME/.zshrc"

if [[ -f "$ZSHRC_SOURCE" ]]; then
    if [[ -e "$ZSHRC_TARGET" && ! -L "$ZSHRC_TARGET" ]]; then
        mv "$ZSHRC_TARGET" "$ZSHRC_TARGET.backup.$(date +%Y%m%d%H%M%S)"
    elif [[ -L "$ZSHRC_TARGET" ]]; then
        rm "$ZSHRC_TARGET"
    fi

    ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
    echo "Linked Zsh config: $ZSHRC_TARGET -> $ZSHRC_SOURCE"
fi

# ---------------------------------------------------------
# tmux configuration
# ---------------------------------------------------------

TMUX_CONF_SOURCE="$SCRIPT_DIR/tmux/.tmux.conf"
TMUX_CONF_TARGET="$HOME/.tmux.conf"

if [[ -f "$TMUX_CONF_SOURCE" ]]; then
    if [[ -e "$TMUX_CONF_TARGET" && ! -L "$TMUX_CONF_TARGET" ]]; then
        mv "$TMUX_CONF_TARGET" "$TMUX_CONF_TARGET.backup.$(date +%Y%m%d%H%M%S)"
    elif [[ -L "$TMUX_CONF_TARGET" ]]; then
        rm "$TMUX_CONF_TARGET"
    fi

    ln -s "$TMUX_CONF_SOURCE" "$TMUX_CONF_TARGET"
    echo "Linked tmux config: $TMUX_CONF_TARGET -> $TMUX_CONF_SOURCE"
fi

# ---------------------------------------------------------
# Development directories
# ---------------------------------------------------------

info "Creating development directories"

mkdir -p \
    "$HOME/dev" \
    "$HOME/.config/nvim"

# ---------------------------------------------------------
# Final checks
# ---------------------------------------------------------

info "Installation summary"

echo
echo "Git:"
git --version

echo
echo "uv:"
uv --version

echo
echo "Python:"
python3 --version

echo
echo "tmux:"
tmux -V

echo
echo "Zsh:"
zsh --version

echo
echo "Neovim:"
nvim --version | head -n 1

echo
echo "Claude:"
claude --version

echo
echo "Default shell:"
getent passwd "$USER" | cut -d: -f7

echo
echo "=============================================="
echo " Development environment setup complete!"
echo "=============================================="
echo
echo "Reconnect to SSH for the new shell to take effect."
