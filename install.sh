#!/usr/bin/env bash
set -euo pipefail

# ---- CONFIG: change this to your actual dotfiles repo ----
DOTFILES_REPO="git@github.com:devroy10/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
# ------------------------------------------------------------

echo "==> Prevent running as root"
if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script with sudo"
  exit 1
fi

echo "==> Installing base packages"
sudo apt update
sudo apt install -y zsh tmux git curl fonts-powerline kitty

echo "==> Cloning dotfiles repo"
if [ -d "$DOTFILES_DIR" ]; then
  echo "Dotfiles already present, pulling latest"
  git -C "$DOTFILES_DIR" pull
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

echo "==> Installing Oh My Zsh (non-interactive)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Installing Powerlevel10k"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# ZSH PLUGINS
echo "==> Installing zsh-autosuggestions"
AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

if [ ! -d "$AUTOSUGGESTIONS_DIR" ]; then
  git clone --depth=1 \
    https://github.com/zsh-users/zsh-autosuggestions \
    "$AUTOSUGGESTIONS_DIR"
fi

echo "==> Installing zsh-syntax-highlighting"
SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

if [ ! -d "$SYNTAX_DIR" ]; then
  git clone --depth=1 \
    https://github.com/zsh-users/zsh-syntax-highlighting \
    "$SYNTAX_DIR"
fi

# PLUGIN MANAGER
echo "==> Installing tmux plugin manager (TPM)"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi



echo "==> Backing up any existing configs"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
for f in .zshrc .p10k.zsh .tmux.conf; do
  if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mv "$HOME/$f" "$HOME/$f.bak.$TIMESTAMP"
    echo "Backed up existing $f -> $f.bak.$TIMESTAMP"
  fi
done

if [ ! -f "$DOTFILES_DIR/.zshrc" ]; then
  echo "Missing .zshrc in dotfiles repo"
  exit 1
fi

if [ ! -f "$DOTFILES_DIR/.tmux.conf" ]; then
  echo "Missing .tmux.conf in dotfiles repo"
  exit 1
fi

if [ ! -f "$DOTFILES_DIR/.p10k.zsh" ]; then
  echo "Missing .p10k.zsh in dotfiles repo"
  exit 1
fi

# SYMLINK TO DOTFILES
echo "==> Symlinking configs"
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

echo "==> Installing tmux plugins"
if [ -x "$TPM_DIR/bin/install_plugins" ]; then
  "$TPM_DIR/bin/install_plugins"
fi

echo "==> Updating tmux plugins"
if [ -x "$TPM_DIR/bin/update_plugins" ]; then
  "$TPM_DIR/bin/update_plugins" || true
fi

echo "==> Setting zsh as default shell"
if [ "$SHELL" != "$(which zsh)" ]; then
  sudo chsh -s "$(which zsh)" "$USER"
fi

echo "==> Setting up Kitty config"
mkdir -p "$HOME/.config/kitty"
if [ -f "$DOTFILES_DIR/kitty/kitty.conf" ]; then
  ln -sf "$DOTFILES_DIR/kitty/kitty.conf" \
    "$HOME/.config/kitty/kitty.conf"
fi

echo "==> Done."
echo "Reminder: install a Nerd Font (e.g. MesloLGS NF) on this machine's"
echo "terminal emulator/GUI for Powerlevel10k icons to render correctly —"
echo "this can't be done by a shell script alone (it's a terminal setting)."
