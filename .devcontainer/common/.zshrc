# history の設定
# history を保存するファイル
HISTFILE="${HOME}/.zsh_history"
# history をメモリに保存する件数
HISTSIZE=100
# history をファイルに保存する件数
SAVEHIST=100000
# 重複する直前のコマンド history の削除
setopt hist_ignore_dups
# 重複するコマンドを history に残さない設定
setopt hist_ignore_all_dups
# 同時に起動した zsh 間で history を共有
setopt share_history

# 補完機能の有効化
autoload -Uz compinit
compinit -u
# if [ -e /usr/local/share/zsh-completions ]; then
#   fpath=(/usr/local/share/zsh-completions $fpath)
# fi
# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補を詰めて表示
setopt list_packed
# 補完候補一覧をカラー表示
zstyle ':completion:*' list-colors ''
# 補完候補をハイライト
zstyle ':completion:*:default' menu select=2
# tab 入力後に方向キーで選択可能にする
zstyle ':completion:*:setopt:*' menu true select

# コマンドのスペルを訂正
setopt correct
# ビープ音を鳴らさない
# setopt no_beep

# prompt
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{magenta}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{yellow}+"
zstyle ':vcs_info:*' formats "%F{cyan}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd() { vcs_info }
# ホームディレクトリからのすべてのパスを表示
# PROMPT='%n@%m:%F{green}%~%f %F{cyan}$%f '
# ホームディレクトリからの最後のディレクトリ名のみを表示
PROMPT='%n@%m:%F{green}%1~%f %F{cyan}$%f '
RPROMPT='${vcs_info_msg_0_}'

# key binding
# ctr+A でカーソルの先頭に移動などをできるようにするためのもの
bindkey -e

# alias
alias g='git'

alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv}'

# go
if [ -d /usr/local/go ]; then
  export PATH="$PATH:/usr/local/go/bin"
  export GOPRIVATE="ghe.corp.yahoo.co.jp"
fi

if [ -d "${HOME}/bin" ]; then
  export PATH="$PATH:${HOME}/bin"
fi
