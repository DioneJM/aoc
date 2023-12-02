
total_sum=0

function to_digit() {
    value=$1
    if [[ "$value" =~ [0-9] ]]; then
        echo $value
    else
        if [[ "$value" == "one" ]]; then
            echo 1
        elif [[ "$value" == "two" ]]; then 
            echo 2
        elif [[ "$value" == "three" ]]; then 
            echo 3
        elif [[ "$value" == "four" ]]; then 
            echo 4
        elif [[ "$value" == "five" ]]; then 
            echo 5
        elif [[ "$value" == "six" ]]; then 
            echo 6
        elif [[ "$value" == "seven" ]]; then 
            echo 7
        elif [[ "$value" == "eight" ]]; then 
            echo 8
        elif [[ "$value" == "nine" ]]; then 
            echo 9
        else
            echo 0
        fi
    fi
}

while IFS="" read line
do
    echo "input: $line"
    actual_digits=(`echo $line | python3 -c "import re; print('\n'.join(re.findall(r'[0-9]', input())))"`)
    echo "actual_digits: ${actual_digits[@]}"
    digits=(`echo $line | python3 -c "import re; print('\n'.join(re.findall(r'(?=(one|two|three|four|five|six|seven|eight|nine|[0-9]))', input())))"`)
    sum=0
    echo "digits: ${digits[@]}"
    if [[ "${#digits[@]}" -eq 1 ]]; then
        digit1=$(to_digit ${digits[0]})
        sum=$digit1$digit1
        echo $sum
    else
        digit1=$(to_digit ${digits[0]})
        digit2=$(to_digit ${digits[${#digits[@]} - 1]})
        sum=$digit1$digit2
        echo $sum
    fi
    total_sum=$(( $total_sum+$sum ))
done
echo $total_sum
