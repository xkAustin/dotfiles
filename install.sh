#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/Developer/projects/dotfiles"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# 备份函数
backup_file() {
  local target=$1
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up $target -> $target.backup"
    mv "$target" "$target.backup"
  fi
}

# 创建软链接函数
link_file() {
  local source=$1
  local target=$2

  if [ -L "$target" ]; then
    echo "Skipping $target (already a symlink)"
  else
    backup_file "$target"
    echo "Linking $target -> $source"
    ln -s "$source" "$target"
  fi
}

# === ZSH ===
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# === SSH ===
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

link_file "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config" 2>/dev/null || true

echo "==> Done!"
echo "Run: source ~/.zshrc"
