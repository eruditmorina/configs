export BASH_SILENCE_DEPRECATION_WARNING=1
export HISTSIZE=50000
export HISTCONTROL=ignoreboth:erasedups
export PS1='\u@\h:\[\e[01;32m\]\w\[\e[0m\]\$ '
export EDITOR='vim'
export CLICOLOR=1

if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

# append to bash history
shopt -s histappend

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# bash-completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# nvm
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# poetry
export PATH="$HOME/.local/bin:$PATH"

# golang
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:$PATH"

# rustup
export PATH="$HOME/.cargo/bin:$PATH"
