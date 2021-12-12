#!/bin/bash



################# Select Where - Similar to select, except the user also adds a criteria ################################
################# e.g., select columns 1,3 where column 2 = michael etc. ################################################


# Check that the correct number of parameters has been provided by the user
if [ "$#" -ne 5 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 5" >&2
	exit 1
fi


# Assign parameters to variables for readibility
dir_name="$1"
file_path="$1"/"$2"
select_columns="$3"
criteria_column="$4"
criteria_value="$5"


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


# Loop checks if each user-requested column exists, and if it does not exist, exits the program
for elem in "${user_columns[@]}"; do
	valid_column=false
	for index in "${!headers_array[@]}"; do

		# Subtract 1 from each user-requested column to get the index
		if [ $(($elem-1)) -eq "$index" ]; then
			valid_column=true
		fi
	done

	# This test will pass if the user-requested column minus one did not match the index of any column in the table
	if [ "$valid_column" = false ]; then
		echo "Error: " "$elem" " is not a valid column" >&2
		rm "$dir_name-lock"
		exit 1
	fi
done


# Check that the criteria column exists using the same method as above
valid_column=false
for index in "${!headers_array[@]}"; do
	if [ $(($criteria_column-1)) -eq "$index" ]; then
		valid_column=true
	fi
done

# Valid column = false implies that the user provided an invalid criteria column
if [ "$valid_column" = false ]; then
	echo "Error: " "$criteria_column" " is not a valid column" >&2
	rm "$dir_name-lock"
	exit 1
fi


# Iterate through each line in the table
while IFS= read -r line; do

	# Isolate the criteria column value in each row
	line_col="$(echo "$line" | cut -d, -f"$criteria_column")"


	# Check that the criteria column value is equal to the criteria value provided by the user, and print the row if this is the case
	if [ "$line_col" = "$criteria_value" ]; then

		# Only print the columns in the row that were specified by the user
		echo "$line" | cut -d, -f"$select_columns"
	fi

done < "$file_path"


rm "$dir_name-lock"


exit 0
