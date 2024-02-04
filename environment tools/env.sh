#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -c    Check existing environments"
    echo "  -d    Delete an environment"
    echo "  -e    Specify the environment name"
    echo "  -f    Specify the requirements file"
    echo "  -l    List installed packages in an environment"
    echo "  -a    Activate an environment"
    echo "  -de   Deactivate the current environment"
    exit 1
}

# Function to list existing environments
list_environments() {
    echo "Existing environments:"
    for dir in */; do
        echo "  ${dir%/}"
    done
}

# Parse command line options
while getopts ":cd:e:f:la" opt; do
    case $opt in
        c)
            list_environments
            exit 0
            ;;
        d)
            environment_name="$OPTARG"
            if [ -z "$environment_name" ]; then
                echo "Error: -d option requires an environment name."
                usage
            fi
            rm -rf "$environment_name"
            echo "Environment '$environment_name' deleted successfully."
            exit 0
            ;;
        e)
            environment_name="$OPTARG"
            ;;
        f)
            requirements_file="$OPTARG"
            ;;
        l)
            list_packages=true
            ;;
        a)
            activate=true
            ;;
        de)
            deactivate=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Check for conflicting options
if [ "$activate" = true ] && [ "$deactivate" = true ]; then
    echo "Error: Options -a and -de are mutually exclusive."
    usage
fi

# Check if activating or deactivating an environment
if [ "$activate" = true ]; then
    source "$environment_name/bin/activate"
    exit 0
elif [ "$deactivate" = true ]; then
    deactivate
    exit 0
fi

# Check if required options are provided
if [ -z "$environment_name" ]; then
    echo "Error: -e option is required."
    usage
fi

# Install necessary packages/tools, including python3-venv
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv

# Check if listing packages in an environment
if [ "$list_packages" = true ]; then
    source "$environment_name/bin/activate"
    pip list
    exit 0
fi

# Create a virtual environment and activate it
python3 -m venv "$environment_name"
source "$environment_name/bin/activate"

# Install Python packages from requirements file
if [ -n "$requirements_file" ]; then
    pip install -r "$requirements_file"
fi

echo "Environment '$environment_name' created and packages installed successfully."
