#!/usr/bin/env nix-shell 
#! nix-shell -i bash --pure
#! nix-shell -p bash

for f in data/pokemon/base_stats/*.asm; do
    cat $f \
    | tr '\n' '\v' \
    | sed -E 's/dw (\w+), (\w+)(.+)(..)db [%01]+ ; padding/dw \1, \2\3\4db BANK(\1)\4assert BANK(\1) == BANK(\2)/g' \
    | tr '\v' '\n' \
    > $f.tmp;
    mv -f $f.tmp $f;
done
