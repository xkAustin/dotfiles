# Lines configured by zsh-newuser-install
#HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit -i
# End of lines added by compinstall

# zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f'
fi

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# Homebrew plugins (detect prefix dynamically)
if command -v brew &>/dev/null; then
  BREW_PREFIX="$(brew --prefix)"
  [ -r "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -r "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

[ -r ~/.env ] && . ~/.env
