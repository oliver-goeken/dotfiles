#!/usr/bin/env bash

# option handling from --> https://stackoverflow.com/a/14203146
VERBOSE=0
SILENT=0
ALL=0
usage_message () {
	echo "usage: install.sh [options]"
	echo "  options:"
	echo "    -h, --help     Display this help message"
	echo "    -v, --verbose  Print all messages"
	echo "    -s, --silent   Suppresse all messages"
	echo "    -a, --all      Install everything, including extra programs"
}
while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help)
			usage_message
			exit 0
			;;
		-v|--verbose)
			VERBOSE=1
			shift
			;;
		-s|--silent)
			SILENT=1
			shift
			;;
		-a|--all)
			ALL=1
			shift
			;;
		-*|--*)
			echo "unknown option $1"
			usage_message
			exit 1
			;;
		*)
			echo "invalid argument $1"
			usage_message
			exit 1
			;;
	esac
done


create_symlink () {
	sudo ln -s $DOTFILEDIR/config/$1 $2
}

print_not_silent () {
	if [ $SILENT = 0 ]
	then
		echo "$1"
	fi
}

print_if_verbose () {
	if [ $VERBOSE = 1 ]
	then
		print_not_silent "$1"
	fi
}

declare -a locations=( ["sway"]="~/.config/sway" )

# finding script directory regardless of running location, courtesy of @tekumara comment under --> https://stackoverflow.com/a/246128
DOTFILEDIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
echo "$DOTFILEDIR" > ~/.dotfiledir
for filename in `ls $DOTFILEDIR/config`
do
	if ! [ -d $DOTFILEDIR/config/$filename ]
	then
		CONFDEST="\<$filename\>"
		if [[ -z ${locations[$filename]} ]]
		then
			CONFDEST=~/."$filename"
		else
			CONFDEST="${!locations[$filename]}"
		fi
		if [ -e $CONFDEST  ]
		then
			if [ -L $CONFDEST ]
			then
				if ! [ "$(readlink -f $CONFDEST)" = "$(readlink -f $DOTFILEDIR/config/$filename)" ]
				then
					print_not_silent "incorrect $filename symlink found, updating..."
					unlink $CONFDEST
					create_symlink $filename $CONFDEST
				else
					print_if_verbose "$filename symlink already exists!"
				fi
			else
				print_not_silent "unlinked $filename found, creating backup at \"$CONFDEST.old\"..."
				mv $CONFDEST $CONFDEST.old
				print_not_silent "creating new symlink..."
				create_symlink $filename $CONFDEST
			fi
		else
			if [ -L $CONFDEST ]
			then 
				print_not_silent "incorrect $filename symlink found, updating..."
				unlink $CONFDEST
				create_symlink $filename $CONFDEST
			else
				print_not_silent "$filename not found, creating symlink..."
				create_symlink $filename $CONFDEST
			fi
		fi
	fi
done




if ! [ -d $DOTFILEDIR/plugins/zsh/zsh-syntax-highlighting ] || [ -z "$(ls -A $DOTFILEDIR/plugins/zsh/zsh-syntax-highlighting)" ]
then
	print_not_silent "cloning zsh-syntax-highlighting..."
	cd $DOTFILEDIR/plugins/zsh
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git > /tmp/dotfile_clone
	echo /tmp/dotfile_clone >> ~/.dotfiles.log
	print_if_verbose $(echo /tmp/dotfile_clone)
fi

if ! [ -e ~/.vim/autoload/plug.vim ]
then
	print_not_silent "configuring vim..."
	vi
fi

INSTALL_LS=false
if [ "$INSTALL_LS" = "true" ] && ! [[ "$OSTYPE" == "darwin"* ]]; then
	ZSH_START_FILE=/etc/zsh/zshenv
	if ! grep -F -x -q 'eval "$(dircolors ~/.dir_colors)"' $ZSH_START_FILE > /dev/null
	then
		print_not_silent "adding ls colors..."
		dircolors --print-database > ~/.dir_colors
		print_not_silent 'eval "$(dircolors ~/.dir_colors)"' | sudo tee -a $ZSH_START_FILE > /dev/null
	fi
fi



if [ $ALL = 1 ] && ! [ -d ~/git/pipes.sh ]; then
	print_not_silent "installing pipes.sh..."
	mkdir -p ~/git
	cd ~/git
	git clone git@github.com:pipeseroni/pipes.sh.git > /tmp/dotfile_pipes
	echo /tmp/dotfile_pipes >> ~/.dotfiles.log
	print_if_verbose $(echo /tmp/dotfile_pipes)
	cd pipes.sh
	sudo make install > /tmp/dotfile_pipes_make
	echo /tmp/dotfile_pipes_make >> ~/.dotfiles.log
	print_if_verbose $(echo /tmp/dotfile_pipes_make)
	cd $DOTFILEDIR
fi

if [ $ALL = 1 ] && ! [ -d ~/.tmux/plugins/tpm ]; then
	print_not_silent "installing tpm..."
	mkdir -p ~/.tmux/plugins/tpm
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm > /tmp/dotfile_tpm
	echo /tmp/dotfile_pipes >> ~/.dotfiles.log
	print_if_verbose $(echo /tmp/dotfile_pipes)
fi


exec zsh

print_not_silent "done!"
