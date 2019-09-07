#!/bin/bash

# exit on error
set -e

# error on unexpanded variables
set -u


#pbcopy='xclip -selection clipboard'
#alias pbpaste='xclip -selection clipboard -o'

echo $(uuidgen | tr -d - | tr -d '\n' | tr '[:upper:]' '[:lower:]')
#| xclip -selection clipboard && xclip -selection clipboard -o && echo

#uuidgen | tr -d - | tr -d '\n' | tr '[:upper:]' '[:lower:]'  | pbcopy && pbpaste && echo

exit 0
