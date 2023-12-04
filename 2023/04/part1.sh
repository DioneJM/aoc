#!/bin/bash

function parse_card() {
    card=$@
    card_number=$(echo $card | cut -f1 -d ':' | cut -f2 -d ' ')
    winning_numbers=($(echo $card | cut -f2 -d ':' | cut -f1 -d '|'))
    winning_numbers_str=$(echo $card | cut -f2 -d ':' | cut -f1 -d '|')
    my_numbers=($(echo $card | cut -f2 -d ':' | cut -f2 -d '|'))
    echo "for card $card_number:" >&2
    echo "winning numbers: ${winning_numbers[@]}" >&2
    echo "winning numbers string: $winning_numbers_str" >&2
    echo "my numbers: ${my_numbers[@]}" >&2

    matches=0
    for number in ${my_numbers[@]}; do
        for winning_number in ${winning_numbers[@]}; do
            if [[ $winning_number -eq $number ]]; then
                matches=$(( $matches+1 ))
            fi
        done
    done
    echo "total matches: $matches" >&2
    if [[ $matches -eq 0 ]]; then
        echo "0"
    else
        echo $(( 2**$(( $matches-1 )) ))
    fi
}


running_total=0
while IF="" read line
do
    echo $line >&2
    result=$(parse_card $line)
    running_total=$(( $running_total + $result ))
done
echo "worth: $running_total"



