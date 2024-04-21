#!/usr/bin/env bash

git add .

if [ -n "$1" ]; then
	git commit -m "$1"
else
	git commit -m "push changes"
fi

git push
