#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# ---- preflight ----
fail() { echo "ERROR: $*"; exit 1; }

command -v git &>/dev/null || fail "git is required but not installed"

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

# ---- prompt ----
prompt_yn() {
  local prompt="$1"
  local answer
  while true; do
    read -r -p "$prompt [y/N] " answer
    case "$answer" in
      [Yy]|[Yy][Ee][Ss]) return 0 ;;
      [Nn]|[Nn][Oo]|"")  return 1 ;;
      *) echo "Please answer y or n" ;;
    esac
  done
}

INSTALLED_ANY=false
INSTALLED_ZSH=false

# ---- ZSH ----
if [ -d "$DOTFILES_DIR/zsh" ] && prompt_yn "Import zsh configs?"; then
  command -v zsh &>/dev/null || fail "zsh is required but not installed"
  link_file "$DOTFILES_DIR/zsh/.zshrc"     "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/zsh/.zprofile"  "$HOME/.zprofile"
  INSTALLED_ANY=true
  INSTALLED_ZSH=true
fi

# ---- Git ----
if [ -d "$DOTFILES_DIR/git" ] && prompt_yn "Import git configs?"; then
  link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
  INSTALLED_ANY=true
fi

# ---- SSH ----
if [ -d "$DOTFILES_DIR/ssh" ] && prompt_yn "Import ssh configs?"; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  link_file "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
  INSTALLED_ANY=true
fi

# ---- Claude ----
if [ -d "$DOTFILES_DIR/claude" ] && prompt_yn "Import claude configs?"; then
  mkdir -p "$HOME/.claude/agents"
  link_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
  for agent_file in "$DOTFILES_DIR/claude/agents"/*.md; do
    [ -e "$agent_file" ] || continue
    link_file "$agent_file" "$HOME/.claude/agents/$(basename "$agent_file")"
  done
  INSTALLED_ANY=true
fi

# ---- reminders ----
echo ""
if $INSTALLED_ANY; then
  echo "==> Done!"
  echo ""
  echo "Next steps (manual):"
  if $INSTALLED_ZSH; then
    echo "  1. source ~/.zshrc"
  else
    echo "  1. Restart your shell or source the relevant rc file"
  fi
  echo "  2. Generate an SSH key if you don't have one:"
  echo "     ssh-keygen -t ed25519 -C \"your-email@example.com\" -f ~/.ssh/id_ed25519"
  echo "  3. Add the public key to GitHub:"
  echo "     cat ~/.ssh/id_ed25519.pub"
else
  echo "==> Nothing was installed."
fi
