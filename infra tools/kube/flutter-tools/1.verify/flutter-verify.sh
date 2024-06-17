#!/bin/bash

# Define the list of tools to check
tools=("bash" "file" "mkdir" "rm" "which")

# Function to check if a tool is present and print the result
check_tool() {
    local tool=$1
    local path
    path=$(which "$tool" 2>/dev/null)
    if [ -n "$path" ]; then
        printf "\e[32m●\e[0m\t%-10s\t%s\n" "$tool" "$path"
    else
        printf "\e[31m✖\e[0m\t%-10s\t%s\n" "$tool" "Not found"
    fi
}

# Iterate over the list of tools and check each one
for tool in "${tools[@]}"; do
    check_tool "$tool"
done

