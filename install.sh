#!/usr/bin/env bash

VIMRCDIFF=$(diff ~/.vimrc configure/vimrc)
if [ "$VIMRCDIFF" != "" ]
then
	echo "~/.vimrc not found, installing... "
	sudo ln -s configure/vimrc ~/.vimrc
fi
