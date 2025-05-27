source ~/.config/zsh/.zsh_aliases

export EDITOR='nvim'
export VISUAL='nvim'

setopt histignorealldups sharehistory
setopt HIST_IGNORE_SPACE

# Custom commands
function tkdir(){
    mkdir -p $1
    cd $1
}

# Directory stack
setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index


# Vim stuff

IN_VIM=$(ps -p $PPID -o comm= | grep -qsE '[gm]?vim' && echo 1)

# Use vim bindings, except when we're actually in vim
[ -z $IN_VIM ] && bindkey -v || bindkey -e

export KEYTIMEOUT=1

bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey -M vicmd '^[[1;5C' emacs-forward-word
bindkey -M vicmd '^[[1;5D' emacs-backward-word
bindkey -M viins '^[[1;5C' emacs-forward-word
bindkey -M viins '^[[1;5D' emacs-backward-word
bindkey "\E[1~" beginning-of-line
bindkey "\E[4~" end-of-line
bindkey "\E[H" beginning-of-line
bindkey "\E[F" end-of-line
bindkey "\E[3~" delete-char
bindkey '^[^?' backward-kill-word
bindkey '^P' up-line-or-search
bindkey "^N" down-line-or-search


# Change cursor shape based on vim mode
cursor_mode() {
    # See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes
    cursor_block='\e[2 q'
    cursor_beam='\e[6 q'

    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }

    zle-line-init() {
        echo -ne $cursor_beam
    }

    zle -N zle-keymap-select
    zle -N zle-line-init
}

cursor_mode

# Navigate menus with vim keys
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Edit command with vim useing 'E'
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd E edit-command-line

# Add missing text objects to vi mode
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
  bindkey -M $km -- '-' vi-up-line-or-history
  for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
    bindkey -M $km $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $km $c select-bracketed
  done
done

# Add surround to vim mode
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd ys add-surround
bindkey -M visual S add-surround


# History
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.cache/.zsh_history

# Use modern completion system
autoload -Uz compinit; compinit
source ~/.config/zsh/completion.zsh

PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.go/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(task --completion zsh)"

source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# zsh autosuggestions
source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^E' autosuggest-accept

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

stty -ixon

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

eval "$(kubectl completion zsh)"
export KUBECONFIG=~/.kube/demos:~/.kube/prod
alias k=kubectl
