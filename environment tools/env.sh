#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]" >&2
    echo "Options:" >&2
    echo "  -c    Check existing environments" >&2
    echo "  -e    Specify the environment name" >&2
    echo "  -f    Specify the requirements file (create option)" >&2
    echo "  -l    List installed packages in an environment" >&2
    echo "  -u    Update packages" >&2
    echo "  -d    Delete an environment" >&2
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
while getopts ":ce:f:ldu" opt; do
    case $opt in
        c)
            list_environments
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
        u)
            # Update packages without creating/modifying an environment
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip python3-venv
            exit 0
            ;;
        d)
            delete_environment=true
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

# Check if listing packages in an environment
if [ "$list_packages" = true ]; then
    # Display installed packages in the environment
    if [ -n "$environment_name" ]; then
        if [ -d "$environment_name" ]; then
            source "$environment_name/bin/activate"
            pip list
            deactivate  # Deactivate the environment
        else
            echo "Error: Environment '$environment_name' not found." >&2
            exit 1
        fi
    else
        echo "Error: -e option is required for listing packages." >&2
        usage
    fi
    exit 0
fi

# Check if delete option is provided
if [ "$delete_environment" = true ]; then
    # Check if required options are provided for deleting an environment
    if [ -z "$environment_name" ]; then
        echo "Error: -e option is required for deleting an environment." >&2
        usage
    fi

    # Delete the environment
    if [ -d "$environment_name" ]; then
        rm -rf "$environment_name"
        echo "Environment '$environment_name' deleted successfully."
        exit 0
    else
        echo "Error: Environment '$environment_name' not found." >&2
        exit 1
    fi
fi

# Check if create option is provided
if [ -n "$environment_name" ] && [ -n "$requirements_file" ]; then
    # Create a virtual environment and activate it
    if ! command -v python3 &> /dev/null; then
        echo "Error: Python3 is not installed." >&2
        exit 1
    fi

    python3 -m venv "$environment_name"
    source "$environment_name/bin/activate"

    # Install Python packages from requirements file
    pip install -r "$requirements_file"

    echo "Environment '$environment_name' created and packages installed successfully."
    exit 0
fi

# If no valid options are provided, display usage information
echo "Error: Invalid options provided." >&2
usage
