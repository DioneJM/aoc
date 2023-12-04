#!/bin/bash

function parse_card() {
    card=$@
    winning_numbers=($(echo $card | cut -f2 -d ':' | cut -f1 -d '|'))
    winning_numbers_str=$(echo $card | cut -f2 -d ':' | cut -f1 -d '|')
    my_numbers=($(echo $card | cut -f2 -d ':' | cut -f2 -d '|'))
    echo "winning numbers: ${winning_numbers[@]}" >&2
    echo "winning numbers string: $winning_numbers_str" >&2
    echo "my numbers: ${my_numbers[@]}" >&2

    matches=0
    for number in ${my_numbers[@]}; do
        for winning_number in ${winning_numbers[@]}; do
            if [[ $winning_number -eq $number ]]; then
                echo "$number is in $winning_numbers_str" >&2
                matches=$(( $matches+1 ))
            fi
        done
    done
    echo $matches
}

# too lazy to make this dynamic
# input
num_cards=212
# example
#num_cards=6

matches_record=() 
for ((i = 0; i < $num_cards; i++)); do
    matches_record+=(1) # pad an array with the number of cards and set to 1 representing the real card
done

running_total=0
while IF="" read line
do
    echo $line >&2
    card_number=$(echo $line | cut -f1 -d ':' | cut -f2 -d ' ')
    current_card_count=${matches_record[$card_number-1]}
    echo "current card count: $current_card_count" >&2
    num_matches=$(parse_card $line)
    echo "for card $card_number, got num matches: $num_matches" >&2
    for ((i=0; i < $num_matches; i++)); do
        record_idx=$(( $card_number + i ))
        echo "adding copy for card number: $record_idx"
        current_count=${matches_record[$record_idx]}
        echo "current count: $current_count" >&2
        matches_record[$record_idx]=$(( $current_count + $current_card_count ))
        echo "after: ${matches_record[@]}" >&2
    done
    echo "---" >&2
done

echo "matches_record: ${matches_record[@]}"

total_number=0
for count in ${matches_record[@]}; do
    total_number=$(( $total_number + $count ))
done

echo "total: $total_number"


