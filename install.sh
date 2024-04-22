#!/usr/bin/env bash

VERBOSE=0
if [ $# -eq 1 ]
then
	if [ $1 = '--help' ] || [ $1 = '-h' ]
	then
		echo "usage: install.sh [--verbose]"
		exit 0
	fi

	if [ $1 = '--verbose' ] || [ $1 = '-v' ]
	then
		VERBOSE=1
	fi
fi

# finding script directory regardless of running location, courtesy of @tekumara comment under --> https://stackoverflow.com/a/246128
DOTFILEDIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

create_symlink () {
	sudo ln -s $DOTFILEDIR/config/$1 ~/.$1
}

print_if_verbose () {
	if [ $VERBOSE = 1 ]
	then
		echo "$1"
	fi
}

for filename in `ls $DOTFILEDIR/config`
do
	if [ -e ~/.$filename  ]
	then
		if [ -L ~/.$filename ]
		then
			if ! [ "$(readlink -f ~/.$filename)" = "$(readlink -f $DOTFILEDIR/config/$filename)" ]
			then
				echo "incorrect $filename symlink found, updating..."
				unlink ~/.$filename
				create_symlink $filename
			else
				print_if_verbose "$filename symlink already exists!"
			fi
		else
			echo "non-linked $filename found, creating backup at \"~/.$filename.old\"..."
			mv ~/.$filename ~/.$filename.old
			echo "creating new symlink..."
			create_symlink $filename
		fi
	else
		if [ -L ~/.$filename ]
		then 
			echo "broken $filename found, updating..."
			unlink ~/.$filename
			create_symlink $filename
		else
			echo "$filename not found, creating symlink..."
			create_symlink $filename
		fi
	fi
done


if ! [ -d $DOTFILEDIR/plugins/zsh/zsh-syntax-highlighting ]
then
	echo "cloning zsh-syntax-highlighting..."
	cd $DOTFILEDIR/plugins/zsh
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git > /tmp/dotfile_clone
	echo /tmp/dotfile_clone >> ~/.dotfiles.log
	print_if_verbose $(echo /tmp/dotfile_clone)
fi

if ! [[ "$OSTYPE" == "darwin"* ]]; then
	ZSH_START_FILE=/etc/zsh/zshenv
	if ! grep -F -x -q 'eval "$(dircolors ~/.dir_colors)"' $ZSH_START_FILE > /dev/null
	then
		echo "adding ls colors..."
		dircolors --print-database > ~/.dir_colors
		echo 'eval "$(dircolors ~/.dir_colors)"' | sudo tee -a $ZSH_START_FILE > /dev/null
	fi

	sudo apt install fortunes
fi


if ! [ -e ~/.vim/autoload/plug.vim ]
then
	vi
fi
