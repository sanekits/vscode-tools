#!/usr/bin/env bash

# See https://stackoverflow.com/a/67186819/237059

case $# in
1) ;;
*) echo "Usage: code-remote-container <directory>"; exit 1 ;;
esac

dir=`echo $(cd $1 && pwd)`
hex=`printf ${dir} | od -A n -t x1 | tr -d '[\n\t ]'`
base=`basename ${dir}`
code --folder-uri="vscode-remote://dev-container%2B${hex}/workspaces/${base}"
