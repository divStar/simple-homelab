#!/bin/bash

# Configuration
ENV_FILE="stack.env"
TOKEN_VAR_NAME="WATCHTOWER_HTTP_API_TOKEN"
API_URL="https://watchtower.my.world/v1/update"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t TOKEN      Manually specify the API token"
    echo "  -e ENV_FILE   Specify env file path (default: stack.env in current directory)"
    echo "  -u URL        Specify API URL (default: localhost:8080/v1/update)"
    echo "  -h            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 -t mytoken"
    echo "  $0 -e /path/to/stack.env"
    echo "  $0 -u https://watchtower.example.domain/v1/update"
    exit 1
}

# Parse command line options
TOKEN=""
while getopts "t:e:u:h" opt; do
    case $opt in
        t)
            TOKEN="$OPTARG"
            ;;
        e)
            ENV_FILE="$OPTARG"
            ;;
        u)
            API_URL="$OPTARG"
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

# If token not provided via command line, try to read from env file
if [ -z "$TOKEN" ]; then
    if [ -f "$ENV_FILE" ]; then
        # Read token from the env file
        TOKEN=$(grep "^${TOKEN_VAR_NAME}=" "$ENV_FILE" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
        
        if [ -z "$TOKEN" ]; then
            echo "Error: $TOKEN_VAR_NAME not found in $ENV_FILE"
            exit 1
        fi
        echo "Using token from $ENV_FILE"
    else
        echo "Error: Environment file not found at $ENV_FILE"
        echo "Please specify the token manually with -t or provide the correct env file path with -e"
        exit 1
    fi
else
    echo "Using manually provided token"
fi

# Make the API call
echo "Calling API endpoint: $API_URL"
curl -H "Authorization: Bearer ${TOKEN}" "$API_URL"

echo ""
echo "Done!"
