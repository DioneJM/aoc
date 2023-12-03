#!/bin/bash

red_limit=12
green_limit=13
blue_limit=14

function check_under_red_limit() {
    record=$@
    regex='[0-9]+ red'
    if [[ $record =~ $regex ]]; then
        red_value=${BASH_REMATCH[0]}
        [[ -n $DEBUG ]] && echo "YES red match: '$red_value'" >&2
        num_cubes_shown=$( echo $red_value | awk '{$1=$1};1' | cut -f1 -d " ")
        if [[ num_cubes_shown -le $red_limit ]]; then
            [[ -n $DEBUG ]] && echo "below limit: '$num_cubes_shown'" >&2
            echo 'yes' 
        else
            [[ -n $DEBUG ]] && echo "above limit: '$num_cubes_shown'" >&2
            echo 'no' 
        fi
    else
        [[ -n $DEBUG ]] && echo "NO red match: '$record'" >&2
        echo 'yes' 
    fi
}
function check_under_green_limit() {
    record=$@
    regex='[0-9]+ green'
    if [[ $record =~ $regex ]]; then
        green_value=${BASH_REMATCH[0]}
        [[ -n $DEBUG ]] && echo "YES green match: '$green_value'" >&2
        num_cubes_shown=$( echo $green_value | awk '{$1=$1};1' | cut -f1 -d " ")
        if [[ num_cubes_shown -le $green_limit ]]; then
            [[ -n $DEBUG ]] && echo "below limit: '$num_cubes_shown'" >&2
            echo 'yes' 
        else
            [[ -n $DEBUG ]] && echo "above limit: '$num_cubes_shown'" >&2
            echo 'no' 
        fi
    else
        [[ -n $DEBUG ]] && echo "NO green match: '$record'" >&2
        echo 'yes' 
    fi
}

function check_under_blue_limit() {
    record=$@
    regex='[0-9]+ blue'
    if [[ $record =~ $regex ]]; then
        blue_value=${BASH_REMATCH[0]}
        [[ -n $DEBUG ]] && echo "YES blue match: '$blue_value'" >&2
        num_cubes_shown=$( echo $blue_value | awk '{$1=$1};1' | cut -f1 -d " ")
        if [[ num_cubes_shown -le $blue_limit ]]; then
            [[ -n $DEBUG ]] && echo "below limit: '$num_cubes_shown'" >&2
            echo 'yes' 
        else
            [[ -n $DEBUG ]] && echo "above limit: '$num_cubes_shown'" >&2
            echo 'no' 
        fi
    else
        [[ -n $DEBUG ]] && echo "NO blue match: '$record'" >&2
        echo 'yes' 
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

    result=()
    running_total=0
    IFS=";" # separate the input by ';'
    for record in $game_records; do
        
        #if [[ $word =~ $regex ]]; then
            #match="${match:+$match }${BASH_REMATCH[0]}"
        #else
            #echo "no match for $word"
        #fi
        [[ -n $DEBUG ]] && echo "record: $record" >&2
        is_red_valid=$(check_under_red_limit $record)
        [[ -n $DEBUG ]] && echo "is red valid: $is_red_valid" >&2
        is_green_valid=$(check_under_green_limit $record)
        [[ -n $DEBUG ]] && echo "is green valid: $is_green_valid" >&2
        is_blue_valid=$(check_under_blue_limit $record)
        [[ -n $DEBUG ]] && echo "is blue valid: $is_blue_valid" >&2
        if [[ $is_red_valid != 'yes' || $is_green_valid != 'yes' || $is_blue_valid != 'yes' ]]; then
            [[ -n $DEBUG ]] && echo "invalid result found:" >&2
            game_number=0
            break
        fi
        result+=($record)
    done
    echo $game_number
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
