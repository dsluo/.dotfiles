#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# default text editor
export EDITOR=vim
export VISUAL=vim

# prompt, or powerline if available
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ '
if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]
then
	powerline-daemon -q
	POWERLINE_BASH_CONTINUATION=1
	POWERLINE_BASH_SELECT=1
	. /usr/share/powerline/bindings/bash/powerline.sh
fi


# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

if command -v bat &> /dev/null
then
    alias cat=bat
fi

# path extensions
export PATH="$HOME/.local/bin":$PATH
export PATH=$PATH:"$HOME/emory-tki/bin"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
