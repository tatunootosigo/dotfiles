# 少し凝った zshrc
# License : MIT
# http://mollifier.mit-license.org/

########################################
# 環境変数
export LANG=ja_JP.UTF-8
# パスを通す
export PATH=$PATH:~/bin

# 色を使用出来るようにする
autoload -Uz colors
colors

# emacs 風キーバインドにする
bindkey -e

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# プロンプト
# 1行表示
# PROMPT="%~ %# "
# 2行表示
PROMPT="%{${fg[green]}%}[%n@%m]%{${reset_color}%} %~
%# "


# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

########################################
# 補完
# 補完機能を有効にする
autoload -Uz compinit
compinit

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
       /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'


########################################
# vcs_info
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
autoload -Uz is-at-least
setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '%F{yellow}'
zstyle ':vcs_info:git:*' unstagedstr '%F{magenta}'
zstyle ':vcs_info:*' formats '%F{green}%u%c(%s)-[%b]%f'
zstyle ':vcs_info:*' actionformats '%F{red}(%s)-[%b|%a]%f'

# hooks 設定
if is-at-least 4.3.11; then
    zstyle ':vcs_info:git+set-message:*' hooks git-untracked
    # フックの最初の関数
    # git の作業コピーのあるディレクトリのみフック関数を呼び出すようにする
    # (.git ディレクトリ内にいるときは呼び出さない)
    # .git ディレクトリ内では git status --porcelain などがエラーになるため
    function +vi-git-hook-begin() {
        if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
            # 0以外を返すとそれ以降のフック関数は呼び出されない
            return 1
        fi

        return 0
    }

    # untracked ファイル表示
    #
    # untracked ファイル(バージョン管理されていないファイル)がある場合は
    # unstaged (%u) の先頭に '%F{blue}' を追加
    function +vi-git-untracked() {
        if command git status --porcelain 2> /dev/null \
                | awk '{print $1}' \
                | command grep -F '??' > /dev/null 2>&1 ; then

            # unstaged (%u) に追加
            hook_com[unstaged]=$(echo '%F{blue}'$hook_com[unstaged])
        fi
    }
fi

function _update_vcs_info_msg() {
    LANG=en_US.UTF-8 vcs_info
    RPROMPT="${vcs_info_msg_0_}"
}
add-zsh-hook precmd _update_vcs_info_msg

# ########################################
# # git_prompt

# # プロンプト表示前に実行される関数
# # (これを使用しなくてもpreexec()で変更したプロンプトは元に戻る)
# precmd () {
#     # RPROMPT=$(echo $(__git_ps1 "[%s]")|sed -e s/%/%%/|sed -e s/%%%/%%/|sed -e 's/\$/\\$/')
#     local git_prompt="$(__git_ps1 '%s')"
#     if [[ -n "$git_prompt" ]]; then
#         # local color=36 # cyan
#         local color=34 # blue
#         if [[ $git_prompt == *'*'* ]]; then
#             color=31 # red
#         elif [[ $git_prompt == *'%'* ]]; then
#             color=33 # yellow
#         elif [[ $git_prompt == *'+'* ]]; then
#             color=32 # green
#         elif [[ $git_prompt == *'$'* ]]; then
#             color=35 # magenta
#         fi
#         PROMPT=$'\e['"$color"$'m(\ue0a0 '"$git_prompt"$')\e[0m\n'"$BASE_PROMPT"
#     else
#         PROMPT="$BASE_PROMPT"
#     fi
# }
# GIT_PS1_SHOWDIRTYSTATE=1
# GIT_PS1_SHOWSTASHSTATE=1
# GIT_PS1_SHOWUNTRACKEDFILES=1
# GIT_PS1_SHOWUPSTREAM=""
# GIT_PS1_DESCRIBE_STYLE="branch"
# GIT_PS1_SHOWCOLORHINTS=0
#
########################################
# オプション
# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# beep を無効にする
setopt no_beep

# フローコントロールを無効にする
setopt no_flow_control

# Ctrl+Dでzshを終了しない
setopt ignore_eof

# '#' 以降をコメントとして扱う
setopt interactive_comments

# ディレクトリ名だけでcdする
setopt auto_cd

# cd したら自動的にpushdする
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 高機能なワイルドカード展開を使用する
setopt extended_glob

########################################
# キーバインド

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

########################################
# エイリアス

alias la='ls -a'
alias ll='ls -l'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -p'

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

alias dirs='dirs -v'

alias tiga='tig --all'

#git-forest
alias gf=git-forest
alias git-forest='(){ git-forest --all $@ | less  -i -R -S -Q  }'

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

alias glf="git ls-files"

#cdiff
alias cdiff="cdiff -s -w $(expr $(tput cols) / 2)"

#pry
alias irb='pry'
########################################
# ctrl+c で標準出力をクリップボードにコピーする
# mollifier delta blog : http://mollifier.hatenablog.com/entry/20100317/p1
if which pbcopy >/dev/null 2>&1 ; then
    # Mac
    alias -g C='| pbcopy'
elif which xsel >/dev/null 2>&1 ; then
    # Linux
    alias -g C='| xsel --input --clipboard'
elif which putclip >/dev/null 2>&1 ; then
    # Cygwin
    alias -g C='| putclip'
fi



########################################
# OS 別の設定
case ${OSTYPE} in
    darwin*)
        #Mac用の設定
        export CLICOLOR=1
        alias ls='ls -G -F'
        ;;
    linux*)
        #Linux用の設定
        alias ls='ls -F --color=auto'
        ;;
esac

########################################
# TMUX
# tmuxが起動していない場合にalias設定を行う
if [ $SHLVL = 1 ]; then
    # tmuxにセッションがなかったら新規セッションを立ち上げた際に分割処理設定を読み込む
    alias tmuxa="tmux -2 attach || tmux -2 new-session \; source-file ~/.tmux/new-session"
fi

# zplug
source ~/.zplug/init.zsh

# source ~/.enhancd/init.sh
zplug "b4b4r07/enhancd", use:init.sh

zplug load # --verbose
