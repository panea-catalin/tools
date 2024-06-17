# Tool Checker Script

This bash script checks for the presence of specific tools on your system and outputs the result in a formatted table. The output includes a green dot (●) for tools that are found and a red cross (✖) for tools that are not found, along with the tool name and its path or a "Not found" message.

## Script Description

The script iterates over a list of specified tools and checks if each one is present using the `which` command. The results are displayed in a table with three columns:
1. Status (● for found, ✖ for not found)
2. Tool Name
3. Tool Path or "Not found"

## Usage

1. Save the script to a file (e.g., `check_tools.sh`).
2. Make the script executable:
    ```bash
    chmod +x check_tools.sh
    ```
3. Run the script:
    ```bash
    ./check_tools.sh
    ```

## Script Code

```bash
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

