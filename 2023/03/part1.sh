#!/bin/bash

# iterate through each row
# find all numbers in a given row
# for each number check:
# 1. Is there a symbol adjancent to the number?
#   - scenario 1: before the number
#   - scenario 2: after the number
# IF yes => add number to running total
# IF no check next case
# 2. Is there an adjacent symbol in the previous row?
#   - will need to look in the cells N+2 cells where N is the length of the number 
#   - if the number begins on cell Y on row X, 
#       - then the cells that need to be checked are from (Y - 1) -> (Y + 2) on row (X - 1)
#   - will need to account for boundary and make sure we don't go out of bounds
# IF yes => add number to running total (IF number wasn't added in previous case)
# IF no check next case
# 3. Is there an adjacent symbol in the next row?
#   -  will follow the same logic as used in the Case #2
# IF yes => add number to running total (IF number wasn't added in previous case)
# IF no then nothing to add

#special_char_regex="[$&+,:;=?@#|\'<>^*()%!-]|[0-9]"
special_char_regex="[^.0-9]"
schematic=()
schematic_width=0
while IFS="" read line
do
    schematic_width=${#line}
    schematic+=($line)
    echo $line
done
echo '---'
#echo "schematic: ${schematic[@]}"

function get_number_position() {
    search_string=$1
    row=$2
    echo "searching for $search_string" >&2
    echo "in row $row" >&2

    first_character=${search_string[0]}
    search_length=${#search_string}
    echo "length: $search_length" >&2

    # Convert string to array of characters
    array=()
    for ((i = 0; i < ${#row}; i++)); do
        array+=("${row:$i:1}")
    done

    for i in ${array[@]}; do
        echo "ele $i" >&2
    done
    # Restore IFS to its original value

    rest=${row#*$search_string}
    position=$(( ${#row} - ${#rest} - ${#search_string} ))
    echo "position of $search_string: $position" >&2
    echo $position
}

function num_has_symbol_adjacent_in_row() {
    start_position=$1
    end_position=$2
    row=$3

    if [[ $start_position -ne 0 ]]; then
        char=${row:$(( $start_position - 1 )):1}
        #echo "prev: $char"
        if [[ $char =~ $special_char_regex ]]; then
            #echo "returning success before case" >&2
            return 0
        fi
    fi

    if [[ $end_position -lt $(( ${#row} - 1 )) ]]; then
        char=${row:$(( $end_position + 1 )):1}
        #echo "after: $char"
        if [[ $char =~ $special_char_regex ]]; then
            #echo "returning success after case" >&2
            return 0
        fi
    fi

    return 1
}

function num_has_symbol_adjacent_in_previous_row() {
    start_position=$1
    end_position=$2
    row=$3
    row_position=$4
    #echo "current row: $row_position" >&2

    if [[ $row_position -eq 0 ]]; then
        return 1
    fi

    previous_row=${schematic[$(($row_position - 1))]}
    #echo "previous row: $previous_row" >&2

    start_substring=$(( $start_position - 1))
    end_substring=$(( $end_position - $start_position + 3))
    substring=${previous_row:$start_substring:$end_substring}
    #echo "substring: $substring" >&2
    if [[ $substring =~ $special_char_regex ]]; then
        return 0
    fi

    return 1
}

function num_has_symbol_adjacent_in_next_row() {
    start_position=$1
    end_position=$2
    row=$3
    row_position=$4
    #echo "current row number: $row_position" >&2

    if [[ $row_position -eq $(( ${#schematic[@]} - 1)) ]]; then
        return 1
    fi

    next_row=${schematic[$(($row_position + 1))]}
    #echo "next row: $next_row" >&2


    start_index=$(( $start_position - 1 ))
    start_substring=$(( $start_index > 0 ? $start_index : 0 ))
    end_substring=$(( $end_position - $start_substring + 2))
    substring=${next_row:$start_substring:$end_substring}
    echo "next row substring: $start_substring $end_substring $substring" >&2
    if [[ $substring =~ $special_char_regex ]]; then
        return 0
    fi

    return 1
}

function get_all_number_position_in_row() {
    $row=$0


    index_aray=($(echo $row | awk '{s=$0;  i=1; idx=0;
                while (i>0){
                    i=match(s, /[0-9]+/);
                    if(i>0) {
                        idx += i;
                        print idx-1;
                        s=substr(s, i+1);
                    }
                }
            }'))

    echo "searching in $row" >&2
    echo "index_array: ${index_aray[@]}" >&2 
    echo $index_array
}



current_row=0
running_total=0
for row in ${schematic[@]}; do
    if [[ $current_row -gt 0 ]]; then
        echo "${schematic[$(( $current_row - 1 ))]} (previous_row)" >&2
    fi
    echo "$row (evaluating)" >&2
    if [[ $current_row -lt $(( ${#schematic} - 1 )) ]]; then
        echo "${schematic[$(( $current_row + 1 ))]} (next_row)" >&2
    else
        echo "next_row: [ ]"
    fi
    numbers_in_row=($(echo $row | grep -o "[0-9]*"))
    number_positions_in_row=$(get_all_number_position_in_row $row) # array of indices for each digit in a row

    for number in ${numbers_in_row[@]}; do
        start_position=$(get_number_position $number $row)
        end_position=$(($start_position + ${#number} -1))
        echo "checking: $number. start: $start_position, end: $end_position" >&2
        # this function call is possible because it returns a 0 or non-zero value
        if num_has_symbol_adjacent_in_row $start_position $end_position $row; then
            echo "adding -$number- to total (SAME row case)" >&2
            running_total=$(( $running_total + $number ))
            continue
        fi

        if num_has_symbol_adjacent_in_previous_row $start_position $end_position $row $current_row; then
            echo "adding -$number- to total (PREVIOUS row case)" >&2
            running_total=$(( $running_total + $number ))
            continue
        fi

        if num_has_symbol_adjacent_in_next_row $start_position $end_position $row $current_row; then
            echo "adding -$number- to total (NEXT row case)" >&2
            running_total=$(( $running_total + $number ))
            continue
        fi

        echo "NOT adding $number as no cases were satisfied" >&2

    done
    echo '---number---'
    #echo "current: $current_row"
    current_row=$(( $current_row+1 ))
done

echo "total: $running_total"
