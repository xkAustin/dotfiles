#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# ---- preflight ----
fail() { echo "ERROR: $*"; exit 1; }

command -v zsh  &>/dev/null || fail "zsh is required but not installed"
command -v git  &>/dev/null || fail "git is required but not installed"

# ---- helpers ----
backup_file() {
  local target=$1
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up $target -> $target.backup"
    mv "$target" "$target.backup"
  fi
}

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

# ---- ZSH / Git ----
link_file "$DOTFILES_DIR/zsh/.zshrc"     "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zprofile"  "$HOME/.zprofile"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# ---- SSH ----
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

link_file "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config" 2>/dev/null || true

# ---- Claude ----
mkdir -p "$HOME/.claude/agents"

link_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"

for agent_file in "$DOTFILES_DIR/claude/agents"/*.md; do
  [ -e "$agent_file" ] || continue
  link_file "$agent_file" "$HOME/.claude/agents/$(basename "$agent_file")"
done

# ---- reminders ----
echo ""
echo "==> Done!"
echo ""
echo "Next steps (manual):"
echo "  1. source ~/.zshrc"
echo "  2. Generate an SSH key if you don't have one:"
echo "     ssh-keygen -t ed25519 -C \"your-email@example.com\" -f ~/.ssh/id_ed25519"
echo "  3. Add the public key to GitHub:"
echo "     cat ~/.ssh/id_ed25519.pub"
