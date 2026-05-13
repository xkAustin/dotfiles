# Lines configured by zsh-newuser-install
#HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/admin/.zshrc'

autoload -Uz compinit
compinit -i
# End of lines added by compinstall

#zoxide
eval "$(zoxide init zsh)"

export FZF_DEFAULT_COMMAND='fd --type f'

eval "$(mise activate zsh)"

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[ -r ~/.env ] && . ~/.env
