#!/bin/bash


############### Select - Selects specific columns from the table e.g., select columns 1 and 3 etc. #########################




# Check that the correct number of parameters have been entered
if [ "$#" -ne 3 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 3" >&2
	exit 1
fi


# Assign parameters to variables for readibility
dir_name="$1"
file_path="$dir_name"/"$2"
columns="$3"


# Critical Section
while ! ln "$0" "$dir_name-lock" 2>/dev/null; do
	sleep 1
done


# Check that the database and table exist
if ! [ -d "$dir_name" ]; then
	echo "Error: database" "$dir_name" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1

elif ! [ -f "$file_path" ]; then
	echo "Error: table" "$2" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1
fi


# Convert the headers in the table to an array to validate that the user-requested columns exist
IFS="," read -ra headers_array<<< "$(head -n 1 "$file_path")"


# Convert the user-requested columns into an array to validate that they exist
IFS="," read -ra columns_array<<< "$columns"


# Loop checks if each user-requested column exists, and if it does not exist, exits the program
for col_num in "${columns_array[@]}"; do

	# Boolean variable used to signify if a user-provided column number maps to a column in the table
	valid_column=false
	for index in "${!headers_array[@]}"; do

		# Subtract 1 from each user-requested column and compare with headers index, which is zero-indexed
		if [ $(($col_num-1)) -eq "$index" ]; then
			valid_column=true
		fi
	done

	# This test will pass if the user-requested column number did not map to a column in the table
	if [ "$valid_column" = false ]; then
		echo "Error:" "$col_num" "is not a valid column" >&2
		rm "$dir_name-lock"
		exit 1
	fi
done


# Show selected columns
tail -n+2 "$file_path"| cut -d, -f"$columns"


rm "$dir_name-lock"

exit 0
