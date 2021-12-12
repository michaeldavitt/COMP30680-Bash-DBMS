#!/bin/bash


################ Select by Name Where - Similar to Select by Name, except the user also provides a criteria that the rows should meet ###############
################ e.g., only select rows where ID = 1 etc. ###########################################################################################





# Check that the correct number of parameters have been entered
if [ "$#" -ne 5 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 5" >&2
	exit 1
fi


# Assign parameters to variables for readability
dir_name="$1"
file_path="$1"/"$2"
select_columns="$3"
criteria_column="$4"
criteria_value="$5"


# Critical Section
while ! ln "$0" "$dir_name-lock" 2>/dev/null; do
	sleep 1
done


# Check that the databse and table exists
if ! [ -d "$dir_name" ]; then
	echo "Error: database " "$dir_name" " does not exist" >&2
	rm "$dir_name-lock"
	exit 1

elif ! [ -f "$file_path" ]; then
	echo "Error: table " "$2" " does not exist" >&2
	rm "$dir_name-lock"
	exit 1

fi


# Convert the headers in the table to an array to validate that the user-requested columns exist
IFS="," read -ra headers_array<<< "$(head -n 1 "$file_path")"


# Convert the user-requested columns into an array to validate that they exist
IFS="," read -ra user_columns<<< "$select_columns"


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

	# This test will pass if the user-requested column minus one did not match the index of any column in the table
	if [ "$valid_column" = false ]; then
		echo "Error: " "$elem" " is not a valid column" >&2
		rm "$dir_name-lock"
		exit 1
	fi
done


# Check that the criteria column provided by the user exists using the same method as above
valid_column=false
for index in "${!headers_array[@]}"; do

	if [ "$criteria_column" = "${headers_array[$index]}" ]; then
		valid_column=true
		criteria_index=$index
	fi

done


# If valid column = false, this implies that the user has specified an invalid column
if [ "$valid_column" = false ]; then
	echo "Error: " "$criteria_column" " is not a valid column" >&2
	rm "$dir_name-lock"
	exit 1
fi


# Iterate through each line in the table
{
	read
	while IFS= read -r line; do


		# Convert each line into an array
		IFS="," read -ra line_array<<< "$line"


		# Check that the criteria column value in this row is equal to the criteria value provided by the user. Print the row if this is the case
		if [ "${line_array[$criteria_index]}" = "$criteria_value" ]; then

			# Find the entries corresponding to the user-requested columns and store them in the output array
			output=()
			for column in "${column_index_array[@]}"; do
				output+=("${line_array[$column]}")
			done

			# Print out the values in their original form - comma separated
			IFS=","
			echo "${output[*]}"
		fi

	done
} < "$file_path"


rm "$dir_name-lock"


exit 0
