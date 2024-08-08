#!/bin/bash

alias ?="$PWD/chatgpt_query.sh"
SHELL_TYPE=$(basename "$SHELL")

case "$SHELL_TYPE" in
	"bash")
		SHELL_CONFIG=".bashrc"
		;;
	"zsh")
		SHELL_CONFIG=".zshrc"
		;;
	*)
		echo "Unsupported shell type"
		exit 1
		;;
esac

if ! grep -q "alias '?'=" "$HOME/$SHELL_CONFIG"; then
  echo "alias '?'='$PWD/chatgpt_query.sh'" >> "$HOME/$SHELL_CONFIG"
  source "$HOME/$SHELL_CONFIG"
fi
