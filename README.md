# Bash-Project-V3

How It Works

Uses AWK for filtering and statistics.
Uses sort for sorting.
Can process delimited files other than CSV (e.g., | or ; separated files).
Performs column validation to avoid errors.
Handles invalid input with helpful messages.

Usage Examples
1️⃣ Filter rows where column 2 contains "error":

./csv_analyzer.sh -f data.csv -d ',' -o filter -c 2 -r "error"

2️⃣ Sort file by column 3:

./csv_analyzer.sh -f data.csv -d ',' -o sort -c 3

3️⃣ Get statistics for column 4:

./csv_analyzer.sh -f data.csv -d ',' -o stats -c 4

4️⃣ Help menu:

./csv_analyzer.sh -h