# History control
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=100000
HISTFILESIZE=2000000

# https://bluz71.github.io/2023/06/02/maximize-productivity-of-the-bash-shell.html
#  - cdspell - automatically fix directory typos when changing directory
#  - direxpand - automatically expand directory globs when completing
#  - dirspell - automatically fix directory typos when completing
#  - globstar - ** recursive glob
#  - histappend - append to history, don't overwrite
#  - nocaseglob - case-insensitive globbing
#  - no_empty_cmd_completion - do not TAB expand empty lines
shopt -s cdspell direxpand dirspell globstar histappend \
  nocaseglob no_empty_cmd_completion

# Helpful aliases
alias ll="colorls -GAhltr"
alias ls="colorls -G"
alias tls="tmux ls"
alias ta="tmux a -t"
alias vi="vim"
alias vimrc="vim ${HOME}/.vimrc"
alias bashrc="vim ${HOME}/.bashrc"
alias todo="vi ${HOME}/Documents/todo.txt"
alias follow="tail -f -n +1"
alias make="gmake"
alias tclsh="rlwrap --no-warnings -c tclsh8.6"

# Unbreak broken, non-colored terminal.
export TERM="xterm-256color"

# Colorize some outputs.
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export GREP_OPTIONS="--color"

# Obviously.
export EDITOR=/usr/local/bin/vim

# Change up a variable number of directories
# E.g:
#   cu   -> cd ../
#   cu 2 -> cd ../../
#   cu 3 -> cd ../../../
function cu {
    local count=$1
    if [ -z "${count}" ]; then
        count=1
    fi
    local path=""
    for i in $(seq 1 ${count}); do
        path="${path}../"
    done
    cd $path
}


# Open all modified files in vim tabs
function vimod {
    vim -p $(git status -suall | awk '{print $2}')
}

# Open files modified in a git commit in vim tabs; defaults to HEAD.
# Examples: 
#     virev 49808d5
#     virev HEAD~3
function virev {
    commit=$1
    if [ -z "${commit}" ]; then
      commit="HEAD"
    fi
    rootdir=$(git rev-parse --show-toplevel)
    sourceFiles=$(git show --name-only --pretty="format:" ${commit} | grep -v '^$')
    toOpen=""
    for file in ${sourceFiles}; do
      file="${rootdir}/${file}"
      if [ -e "${file}" ]; then
        toOpen="${toOpen} ${file}"
      fi
    done
    if [ -z "${toOpen}" ]; then
      echo "No files were modified in ${commit}"
      return 1
    fi
    vim -p ${toOpen}
}

function removelink {
  [ -L "$1" ] && mv "$(readlink "$1")" "$1"
}

# Colors have names too. Stolen from Arch wiki
txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;33m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;36m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[1;30m\]' # Black - Bold
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldblu='\[\e[1;34m\]' # Blue
bldpur='\[\e[1;35m\]' # Purple
bldcyn='\[\e[1;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
bakblk='\[\e[40m\]'   # Black - Background
bakred='\[\e[41m\]'   # Red
badgrn='\[\e[42m\]'   # Green
bakylw='\[\e[43m\]'   # Yellow
bakblu='\[\e[44m\]'   # Blue
bakpur='\[\e[45m\]'   # Purple
bakcyn='\[\e[46m\]'   # Cyan
bakwht='\[\e[47m\]'   # White
txtrst='\[\e[0m\]'    # Text Reset

# Prompt colors
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWCOLORHINTS=true
export PROMPT_DIRTRIM=3

# Prompt helpers
git_prompt() {
    local g="$(__gitdir)"
    if [ -n "$g" ]; then
        # The __git_ps1 function inserts the current git branch where %s is
        local GIT_PROMPT=`__git_ps1 "%s"`
        echo "[${GIT_PROMPT}]"
    fi
}

git_colon() {
    local g="$(__gitdir)"
    if [ -n "$g" ]; then
      echo ":"
    fi
}

export PS1="${txtgrn}[\u@\h]${txtrst}:${txtblu}[\A]${txtrst}:${txtgrn}[\w]${txtrst}\$(git_colon)${txtylw}\$(git_prompt) ${txtrst}| "
export PS4='+${BASH_SOURCE[0]##*/}($LINENO)/${FUNCNAME[0]}> '

source $HOME/bin/git-completion.sh
source $HOME/bin/z.sh
