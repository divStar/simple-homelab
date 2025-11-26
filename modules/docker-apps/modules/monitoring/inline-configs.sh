#!/bin/bash
set -euo pipefail

COMPOSE_FILE="${1:-docker-compose.yml}"

if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo "❌ Error: $COMPOSE_FILE not found"
    exit 1
fi

if ! command -v yq &> /dev/null; then
    echo "❌ Error: yq is required. Install it with:"
    echo "  brew install yq  (macOS)"
    echo "  sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq  (Linux)"
    exit 1
fi

cp "$COMPOSE_FILE" "${COMPOSE_FILE}.backup"
echo "📦 Backup created: ${COMPOSE_FILE}.backup"
echo ""

configs=$(yq eval '.configs | keys | .[]' "$COMPOSE_FILE" 2>/dev/null || echo "")

if [[ -z "$configs" ]]; then
    echo "⚠️  No configs found in $COMPOSE_FILE"
    exit 0
fi

for config_name in $configs; do
    # Get file path from line comment on the config key
    file_path=$(yq eval ".configs.\"${config_name}\" | key | line_comment" "$COMPOSE_FILE")
    
    # Skip if no comment or empty
    if [[ -z "$file_path" || "$file_path" == "null" ]]; then
        continue
    fi
    
    # Trim whitespace
    file_path=$(echo "$file_path" | xargs)
    
    # Check if the file exists
    if [[ ! -f "$file_path" ]]; then
        echo "⚠️  Warning: Config file '$file_path' for '$config_name' not found, skipping..."
        continue
    fi
    
    echo "📝 Inlining '$config_name' from '$file_path'..."
    
    # Strip trailing whitespace from file
    temp_file=$(mktemp)
    sed 's/[[:space:]]*$//' "$file_path" > "$temp_file"
    
    # Load file content and set style to literal
    yq eval -i ".configs.\"${config_name}\".content = load_str(\"$temp_file\")" "$COMPOSE_FILE"
    yq eval -i ".configs.\"${config_name}\".content |= . style=\"literal\"" "$COMPOSE_FILE"
    
    rm "$temp_file"
done

echo ""
echo "✅ Done! All configs inlined."
echo "To revert: mv ${COMPOSE_FILE}.backup $COMPOSE_FILE"