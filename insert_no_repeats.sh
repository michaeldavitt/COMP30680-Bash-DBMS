#!/bin/bash

################ Insert no repeats - Same as insert, except does not allow the row to be entered if it already exists in the table ####################





# Check that the user has provided the correct number of parameters
if [ "$#" -ne 3 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 3" >&2
	exit 1
fi


# Create directory and file path variables
dir_name="$1"
file_path="$1"/"$2"


# Create a variable for the tuple, and convert this tuple to an array for analysis
data="$3"
IFS="," read -ra data_array<<< "$data"


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


# Make sure that the number of columns in the data array matches the number of columns in the table
if [ "${#headings_array[@]}" -ne "${#data_array[@]}" ]; then
	echo "Error:" "${#data_array[@]}" "columns provided. Number of columns should be:" "${#headings_array[@]}" >&2
	rm "$dir_name-lock"
	exit 1
fi


# Loop through each line in the table, check if the user tuple matches one of the lines, if it does, don't add it
while IFS= read -r line; do
	if [ "$data" = "$line" ]; then
		echo "Error: Duplicate entry. Insertion failed" >&2
		rm "$dir_name-lock"
		exit 1
	fi
done < "$file_path"


# If all above tests passed, insert the row into the table
echo "$data" >> "$file_path"

echo "OK:" "$data" "inserted into table" "$2"

rm "$dir_name-lock"

exit 0

