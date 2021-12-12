#!/bin/bash

######################### Column Names - Get column names from a specific table ####################################################


# Check that the correct number of parameters has been provided
if [ "$#" -ne 2 ]; then
	echo "Error:" "$#" "paramters provided. Number of parameters should be: 2" >&2
	exit 1
fi


# Assign the parameters to variables for interpretability
dir_name="$1"
file_path="$1"/"$2"

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

# Output the column names by isolating the first row in the table
head -n 1 "$file_path"

rm "$dir_name-lock"

exit 0
