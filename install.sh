#!/usr/bin/env bash

DOTFILEDIR=~/dotfiles
DOTFILES=vimrc

create_symlink () {
	sudo ln -s $DOTFILEDIR/config/$1 ~/.$1
}

for filename in $DOTFILES
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
				echo "$filename symlink already exists!"
			fi
		else
			echo "non-linked $filename found, creating backup at..."
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

if ! [ -e ~/.vim/autoload/plug.vim ]
then
	echo "testing"
	vi
fi
