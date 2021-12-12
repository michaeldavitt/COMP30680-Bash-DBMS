#!/bin/bash



################## Remove Table - Deletes a table from the database if it exists ##################################



# Check that the correct number of parameters has been supplied
if [ "$#" -ne 2 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 2" >&2
	exit 1
fi


# Create a variable for the database and the table
dir_name="$1"
file_path="$1"/"$2"


# Critical Section
while ! ln "$0" "$dir_name-lock" 2>/dev/null; do
	sleep 1
done


# Check that the database and table exist, and if so, remove the table
if ! [ -d "$dir_name" ]; then
	echo "Error: database" "$dir_name" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1

elif ! [ -f "$file_path" ]; then
	echo "Error: table" "$2" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1
else
	rm "$file_path"
	echo "OK:" "$2" "removed successfully"
fi

rm "$dir_name-lock"

exit 0
