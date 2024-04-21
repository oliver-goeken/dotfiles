#!/usr/bin/env bash

create_symlink () {
	sudo ln -s config/$1 ~/.$1
}

for filename in vimrc
do
	if [ -e ~/.$filename  ]
	then
		if [ -L ~/.$filename ]
		then
			if ! [ "~/.$filename" -ef "config/$filename" ]
			then
				echo "incorrect $filename symlink found, updating..."
				unlink ~/.$filename
				create_symlink $filename
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
			echo "broekn $filename found, updating..."
			unlink ~/.$filename
			create_symlink $filename
		else
			echo "$filename not found, creating symlink..."
			create_symlink $filename
		fi
	fi
done
