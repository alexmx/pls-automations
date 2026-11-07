#!/bin/zsh
# @pls.name: New UUID
# @pls.description: Generate a new UUID and copy it to the clipboard
# @pls.param case: enum(lower|upper) = lower -- upper only when the request asks for uppercase
# @pls.example: new uuid
# @pls.example: generate a guid
# @pls.example: give me an uppercase UUID
# @pls.example: I need a unique id

uuid=$(uuidgen)
[[ $PLS_CASE == lower ]] && uuid=${uuid:l}
print -rn -- "$uuid" | pbcopy
echo "$uuid (copied)"
