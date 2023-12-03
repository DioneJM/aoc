#!/bin/bash

red_limit=12
green_limit=13
blue_limit=14

function get_reds_shown() {
    record=$@
    regex='[0-9]+ red'
    if [[ $record =~ $regex ]]; then
        red_value=${BASH_REMATCH[0]}
        [[ -n $DEBUG ]] && echo "YES red match: '$red_value'" >&2
        num_cubes_shown=$( echo $red_value | awk '{$1=$1};1' | cut -f1 -d " ")
        echo $num_cubes_shown
    else
        [[ -n $DEBUG ]] && echo "NO red match: '$record'" >&2
        echo 0 
    fi
}
function get_greens_shown() {
    record=$@
    regex='[0-9]+ green'
    if [[ $record =~ $regex ]]; then
        green_value=${BASH_REMATCH[0]}
        [[ -n $DEBUG ]] && echo "YES green match: '$green_value'" >&2
        num_cubes_shown=$( echo $green_value | awk '{$1=$1};1' | cut -f1 -d " ")
        echo $num_cubes_shown
    else
        [[ -n $DEBUG ]] && echo "NO green match: '$record'" >&2
        echo 0 
    fi
}

function get_blues_shown() {
    record=$@
    regex='[0-9]+ blue'
    if [[ $record =~ $regex ]]; then
        blue_value=${BASH_REMATCH[0]}
        [[ -n $DEBUG ]] && echo "YES blue match: '$blue_value'" >&2
        num_cubes_shown=$( echo $blue_value | awk '{$1=$1};1' | cut -f1 -d " ")
        echo $num_cubes_shown
    else
        [[ -n $DEBUG ]] && echo "NO blue match: '$record'" >&2
        echo 0
    fi
}

function parse_game() {
    game=$@
    regex="[0-9]+ red|[0-9]+ blue|[0-9]+ green"
    # the '>&2' redirects to stderr so that the echo call doesn't affect the returned result
    [[ -n $DEBUG ]] && echo "input: '$game'" >&2
    #game_number=$( echo "$game_line" | cut -f1 -d ':' | cut -f2 -d " " )
    game_number=$( echo $game | cut -f1 -d ':' | cut -f2 -d ' ')
    [[ -n $DEBUG ]] && echo "game_number: $game_number" >&2

    game_records=$( echo $game | cut -f2 -d ':')
    [[ -n $DEBUG ]] && echo "game_records: $game_records" >&2

    max_red=1
    max_green=1
    max_blue=1
    IFS=";" # separate the input by ';'
    for record in $game_records; do
        [[ -n $DEBUG ]] && echo "record: $record" >&2
        num_reds=$(get_reds_shown $record)
        [[ -n $DEBUG ]] && echo "num_reds: $num_reds" >&2
        if [[ $num_reds -gt $max_red ]]; then
            max_red=$num_reds
        fi

        num_greens=$(get_greens_shown $record)
        [[ -n $DEBUG ]] && echo "num_greens: $num_greens" >&2
        if [[ $num_greens -gt $max_green ]]; then
            max_green=$num_greens
        fi

        num_blues=$(get_blues_shown $record)
        [[ -n $DEBUG ]] && echo "num_blues: $num_blues" >&2
        if [[ $num_blues -gt $max_blue ]]; then
            max_blue=$num_blues
        fi

    done

    power=$(( $max_red * $max_green * $max_blue ))
    echo $power
}

running_total=0
while IFS="" read line
do
    game=$(parse_game $line)
    running_total=$(($running_total + $game))
    [[ -n $DEBUG ]] && echo "result: '${game[@]}'" >&2
    [[ -n $DEBUG ]] && echo '---' >&2
done
echo "total: $running_total"
