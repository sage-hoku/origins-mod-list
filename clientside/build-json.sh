# Root directory, can be overridden by first arg
ROOT_DIR="${1:-archive}"
OUTPUT_FILE="${2:-clientside.json}"

declare -A mod_map

# Find all .jar files and organize them
while IFS= read -r -d '' modfile; do
    relpath="${modfile#$ROOT_DIR/}"             # remove root path
    folder="${relpath%/*}"                      # extract folder
    file="${relpath##*/}"                       # extract filename

    # Initialize array if not exists
    if [[ -z "${mod_map[$folder]}" ]]; then
        mod_map["$folder"]="[]"
    fi

    # Append file to list (manually maintaining JSON array string)
    mod_map["$folder"]=$(echo "${mod_map[$folder]}" | sed "s/]$/, \"${file}\"]/")
done < <(find "$ROOT_DIR" -type f -name "*.jar" -print0)

# Output to JSON
{
    echo "{"
    first=1
    for key in "${!mod_map[@]}"; do
        [[ $first -eq 0 ]] && echo ","
        first=0
        printf '  "%s": %s' "$key" "${mod_map[$key]}"
    done
    echo ""
    echo "}"
} > "$OUTPUT_FILE"

echo "Mod list saved to $OUTPUT_FILE"
