#!/bin/bash



############# Select by Name - Similar to select, except instead of providing column numbers, the user provides column names ###################



# Check that the correct number of parameters has been provided by the user
if [ "$#" -ne 3 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 3" >&2
	exit 1
fi


# Assign parameters to variables for readibility
dir_name="$1"
file_path="$1"/"$2"
select_columns="$3"


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
IFS="," read -ra user_columns<<< "$select_columns"


# Create an array for storing the index of the user-requested columns
column_index_array=()


# Loop checks if each user-requested column exists, and if it does not exist, exits the program
for elem in "${user_columns[@]}"; do

	valid_column=false
	for index in "${!headers_array[@]}"; do

		# Compare the user column with the headings
		if [ "$elem" = "${headers_array[$index]}" ]; then
			valid_column=true
			column_index_array+=($index)
		fi
	done

	# This test will pass if the user-requested column is not in the table
	if [ "$valid_column" = false ]; then
		echo "Error:" "$elem" "is not a valid column" >&2
		rm "$dir_name-lock"
		exit 1
	fi
done


# Iterate through each line in the table
{
	read
	while IFS= read -r line; do

		# Convert each line into an array
		IFS="," read -ra line_array<<< "$line"

		# Find the entries corresponding to the user-requested columns and store them in the output array
		output=()
		for column in "${column_index_array[@]}"; do
			output+=("${line_array[$column]}")
		done

		# Print out the values in their original form - comma separated
		IFS=","
		echo "${output[*]}"

	done
} < "$file_path"


rm "$dir_name-lock"


exit 0
