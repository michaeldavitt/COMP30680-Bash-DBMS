#!/bin/bash


############# Remove Row Where - Similar to remove row, except instead of providing a row to delete, you provide a column name and a value
############# If for row x column value = value, delete row x


# Check that the correct number of parameters has been provided by the user
if [ "$#" -ne 4 ]; then
	echo "Error" "$#" "parameters provided. Number of parameters should be: 4" >&2
	exit 1
fi


# Assign parameters to variables for interpretability
dir_name="$1"
file_path="$1"/"$2"
user_col="$3"
user_val="$4"


# Critical Section
while ! ln "$0" "$dir_name-lock" 2>/dev/null; do
	sleep 1
done


# Make sure that directory and file exists
if ! [ -d "$dir_name" ]; then
	echo "Error: database" "$dir_name" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1

elif ! [ -f "$file_path" ]; then
	echo "Error: table" "$2" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1
fi

# Convert the table headings to an array for comparison with the data array
IFS="," read -ra headings_array<<< "$(head -n 1 "$file_path")"


# Make sure that column name provided by the user is one of the headings
valid_column=false
for index in "${!headings_array[@]}"; do
	if [ "$user_col" = "${headings_array[$index]}" ]; then
		valid_column=true

		# Create a variable for the index of the user-specified column so that it can be isolated later
		user_col_index=$index
	fi
done


# Condition will be true if the column name provided by the user if not one of the columns in the table
if [ "$valid_column" = false ]; then
	echo "Error:" "$user_col" "is not a valid column" >&2
	rm "$dir_name-lock"
	exit 1
fi


# Get the initial number of lines in the table
initial_count=$(wc -l "$file_path" | cut -d" " -f1)


# Create a variable storing lines that need to be deleted
lines_to_delete=()


# Loop through each line in the table, check if the condition is true, if it is, add it to the array of lines to be deleted
while IFS="" read -r line; do

	# Convert each line to an array
	IFS="," read -ra line_array<<< "$line"

	# Check criteria, and add the line to lines to be deleted if the test passes
	if [[ "${line_array[$user_col_index]}" = "$user_val" && "${headings_array[@]}" != "${line_array[@]}" ]]; then
		lines_to_delete+=("$line")
	fi

done < "$file_path"


# Loop through all lines that need to be deleted, and delete them from the table
for line in "${lines_to_delete[@]}"; do
	sed -i "/$line/d" "$file_path"
done


# Get new table line count
final_count=$(wc -l "$file_path" | cut -d" " -f1)


# Check to see if a row has been deleted by comparing both table counts
if [ "$initial_count" -gt "$final_count" ]; then
	echo "OK: deletion successful"

else
	echo "Error: no rows matched the criteria" "$user_col" "=" "$user_val" >&2
	rm "$dir_name-lock"
	exit 1
fi

rm "$dir_name-lock"

exit 0

