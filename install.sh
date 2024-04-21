#!/usr/bin/env bash

touch ~/.vimrc
VIMRCDIFF=$(diff ~/.vimrc config/vimrc)
if [ "$VIMRCDIFF" != "" ]
then
	echo "~/.vimrc not found, installing... "
	sudo ln -s configure/vimrc ~/.vimrc
fi
