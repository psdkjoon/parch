ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

if [ ! -d "${HOME}/.config/zsh" ]; then
  mkdir -p "${HOME}/.config/zsh"
  wget -P "${HOME}/.config/zsh" -O catppuccin.zsh https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/refs/heads/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh
fi


source "${ZINIT_HOME}/zinit.zsh"
source "${HOME}/.config/zsh/catppuccin.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

autoload -U compinit && compinit

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=50000

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^H" backward-kill-word
bindkey "^[[3;5~" kill-word
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

setopt appendhistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt autocd
setopt interactivecomments
setopt no_beep
setopt correct
setopt nullglob
setopt extendedglob
setopt pushdignoredups
setopt noclobber
setopt hist_expire_dups_first

zhelp() {
    man zshbuiltins | col -b | fzf --preview 'echo {}' --preview-window=up:80%
}

run() {
    rm website.log &>/dev/null
    nohup python3 -m http.server ${1:-9090} &>website.log &
}

i() {
    command yay -S $(command yay -Ss "$1" | awk 'NR%2{p=$0;next}{printf "%s\n%s", p, $0} NR%2==0{printf "\0"}' | fzf -m --read0 --tac | grep -oP '^(aur|core|extra)/\K\S+' | paste -sd' ')
}

fuck() {
  eval "$(thefuck --alias)"
  fuck "$@"
}

export PATH="$PATH:/home/psdk/dev/flutter/bin"

alias s='yay -Ss'
alias ii='yay -S'
alias u='yay -Syu'
alias uu='yay -Syyu'
alias r='yay -Rs'
alias q='yay -Qs'
alias d="aria2c -x 16 -s 16"
alias cd='z'
alias cp="cp -i"
alias py='python'
alias lg='lazygit'
alias cloc="cloc . | tail -n +4"
alias ytd='yt-dlp --cookies-from-browser firefox'
alias ssh="kitty +kitten ssh"
alias tree='lsd --tree --depth 2'
alias nt='z $(mktemp -d)'
alias zedit='sudo -E nvim ~/.zshrc && source ~/.zshrc'
alias envedit='sudo -E nvim ~/.config/hypr/hyprenvs.conf'
alias pret='npx --yes prettier --write "**/*.{js,css,html,json,md}"'
alias ls='lsd'
alias convert='magick'
alias fl='fc-list --format="%{family}\n" | sort -u | rg -i '
alias cc='sudo rm -fr /var/cache/pacman/pkg/download-* && yes | sudo pacman -Sc && yes | sudo pacman -Scc && yes | yay -Sc && yes | yay -Scc && yes | yay -Rs $(yay -Qtdq)'
alias nano='nvim'
alias beep='paplay /opt/beep.mp3'
alias cat='bat --theme="Catppuccin Mocha"'
alias bat='bat --theme="Catppuccin Mocha"'
alias c='clear'
alias grep='rg'
alias img="kitty +kitten icat --scale-up --align=center"
alias find='fd'
alias du='dust'
alias ping='gping'
alias yazi='yazi --cwd-file="$YAZI_CWD_FILE"; if [ -f "$YAZI_CWD_FILE" ]; then cwd="$(cat "$YAZI_CWD_FILE")"; if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then cd "$cwd" || echo "Failed to change directory to $cwd" >&2; fi; rm -f "$YAZI_CWD_FILE"; fi'

# Git alias
alias grl='gh repo list --visibility public'

export FZF_DEFAULT_OPTS='--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 --color=selected-bg:#45475A --color=border:#6C7086,label:#CDD6F4'

eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/base.toml)"
