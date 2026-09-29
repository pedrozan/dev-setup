# Dev Setup

Bootstrap script for recreating my development environment on Ubuntu.

## Installed tools

- Git
- uv
- Python 3.11
- tmux
- Zsh
- Oh My Zsh
- Neovim
- Claude Code

## Usage

On a fresh Ubuntu VM:

```bash
sudo apt-get update
sudo apt-get install -y git curl

git clone <REPOSITORY_URL> ~/dev-setup
cd ~/dev-setup

./setup.sh
