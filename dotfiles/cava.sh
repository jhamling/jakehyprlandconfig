#!/bin/bash

# 0..7 → block characters
chars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

cava -p ~/.config/waybar/cava_config | while read -r line; do
    out=""
    len=${#line}

    for ((i=0; i<len; i++)); do
        ch=${line:i:1}

        if [[ $ch =~ [0-7] ]]; then
            n=$ch

            # amplitude scaling
            n=$(( n * 2 ))
            (( n > 7 )) && n=7
        else
            n=0
        fi

        out+="${chars[$n]}"
    done

    printf '%s\n' "$out" || true
done
