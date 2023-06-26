#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-05-06 14:57:41
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-25 18:55:46
 # @Description: 
### 

#!/bin/bash

# Define the custom path type enumerator
NONE=0
FOLDER=1
FILE=2
BOTH=3

# Define the input_custom_path function
function input_custom_path {
    # Prompt the user to input a folder path
    read -p "$1" input_path

    # Exit if the user types 'q'
    if [[ "$input_path" =~ [qQ] ]]; then
        exit 2
    fi

    # If validation is not required, return the input path
    if [[ "$2" == false ]]; then
        echo "$input_path"
        return
    fi

    # Check if the input path is valid based on the custom path type
    if [[ "$3" == $FOLDER ]]; then
        if [[ -d "$input_path" ]]; then
            echo "$input_path"
        else
            echo -e "\033[31mError: '$input_path' is not a valid folder path. Please try again.\033[0m"
            input_custom_path "$1" "$2" "$3"
        fi
    elif [[ "$3" == $FILE ]]; then
        if [[ -f "$input_path" ]]; then
            echo "$input_path"
        else
            echo -e "\033[31mError: '$input_path' is not a valid file path. Please try again.\033[0m"
            input_custom_path "$1" "$2" "$3"
        fi
    else
        echo "$input_path"
    fi
}

# Prompt the user to input a folder path
# input_custom_path "Enter a folder path: " true $FOLDER