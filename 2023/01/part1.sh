#!/usr/bin/env bash

# Problem:
# for each line, get all of the digits
# get the first and last digit of the line
# add both together
# add result to a total sum

total_sum=0
# $@ represents all arguments
# IFS is a special variable called 'Internal field separator'
# idk how it works, all i know is that when passed with `read` it allows you to 
# take in a file and have each line of that file as a separate argument
# i.e. I couldn't get something like:
# for line in read line
# do
#     ...
#done
# to work since the input was coming in all as a single argument
while IFS="" read line 
do
    digits=(`echo $line | grep -o [0-9]`) # grep all of the digits and only print the ones matching the [0-9] regex
    sum=0
    if [[ "${#digits[@]}" -eq 1 ]]; then
        #echo "${digits[*]} only has 1 element"
        sum=${digits[0]}${digits[0]}        
        #echo "$sum"
    else
        #echo "${digits[*]} has more than 1 element"
        sum=${digits[0]}${digits[${#digits[@]}-1]}
        #echo "$sum"
    fi
    total_sum=$(( $total_sum + $sum ))
    #echo "----"
done

echo $total_sum
