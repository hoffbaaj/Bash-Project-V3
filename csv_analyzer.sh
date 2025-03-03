#!/bin/bash

# Function to display help message
function print_help() {
    echo "Usage: csv_analyzer.sh -f <file> -d <delimiter> -o <operation> -c <columns> [-r <regex>] [-h]"
    echo ""
    echo "Options:"
    echo "  -f <file>       Specify the CSV file."
    echo "  -d <delimiter>  Define the CSV delimiter (default: ',')."
    echo "  -o <operation>  Select an operation: filter, sort, stats."
    echo "  -c <columns>    Specify column(s) (comma-separated for multiple)."
    echo "  -r <regex>      (Optional) Regular expression for filtering rows."
    echo "  -h              Display this help message."
    exit 0
}

# Function to check if file exists
function file_exists() {
    if [[ ! -f "$1" ]]; then
        echo "Error: File '$1' not found!"
        exit 1
    fi
}

# Function to validate column selection
function validate_columns() {
    local file="$1"
    local delimiter="$2"
    local selected_columns="$3"
    
    header=$(head -n 1 "$file" | tr "$delimiter" '\n')
    col_count=$(echo "$header" | wc -l)

    for col in $(echo "$selected_columns" | tr ',' ' '); do
        if [[ "$col" -gt "$col_count" || "$col" -lt 1 ]]; then
            echo "Error: Column index '$col' is out of range. File has $col_count columns."
            exit 1
        fi
    done
}

# Function to filter rows based on regex
function filter_rows() {
    local file="$1"
    local delimiter="$2"
    local columns="$3"
    local regex="$4"
    
    awk -F"$delimiter" -v cols="$columns" -v pattern="$regex" '
        BEGIN {split(cols, colArr, ",")}
        NR == 1 {print; next}
        {
            for (i in colArr) {
                if ($colArr[i] ~ pattern) {
                    print $0
                    next
                }
            }
        }
    ' "$file"
}

# Function to sort file based on a column
function sort_file() {
    local file="$1"
    local delimiter="$2"
    local column="$3"
    
    (head -n 1 "$file" && tail -n +2 "$file" | sort -t"$delimiter" -k"$column") 
}

# Function to calculate column statistics
function column_stats() {
    local file="$1"
    local delimiter="$2"
    local column="$3"
    
    awk -F"$delimiter" -v col="$column" '
        NR > 1 {
            sum += $col
            count++
            if (min == "" || $col < min) min = $col
            if (max == "" || $col > max) max = $col
        }
        END {
            if (count > 0) {
                print "Count: " count
                print "Sum: " sum
                print "Min: " min
                print "Max: " max
                print "Average: " sum / count
            } else {
                print "Error: No numeric data found in column."
            }
        }
    ' "$file"
}

# Parse command-line arguments
file=""
delimiter=","
operation=""
columns=""
regex=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -f) file="$2"; shift 2 ;;
        -d) delimiter="$2"; shift 2 ;;
        -o) operation="$2"; shift 2 ;;
        -c) columns="$2"; shift 2 ;;
        -r) regex="$2"; shift 2 ;;
        -h) print_help ;;
        *) echo "Unknown option: $1"; print_help ;;
    esac
done

# Validate input arguments
if [[ -z "$file" || -z "$operation" || -z "$columns" ]]; then
    echo "Error: Missing required arguments!"
    print_help
fi

# Check if file exists
file_exists "$file"

# Validate column selection
validate_columns "$file" "$delimiter" "$columns"

# Perform the requested operation
case "$operation" in
    filter) 
        if [[ -z "$regex" ]]; then
            echo "Error: The filter operation requires a regex pattern."
            exit 1
        fi
        filter_rows "$file" "$delimiter" "$columns" "$regex"
        ;;
    sort)
        sort_file "$file" "$delimiter" "$columns"
        ;;
    stats)
        column_stats "$file" "$delimiter" "$columns"
        ;;
    *)
        echo "Error: Invalid operation '$operation'."
        print_help
        ;;
esac
