#!/bin/bash


################# Create Table - Creates a table in a database ###################################


# Check that the correct number of parameters have been provided
if [ "$#" -ne 3 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 3" >&2
	exit 1
fi


# Assign parameters to variables for interpretability
dir_name="$1"
headers="$3"
file_path="$1"/"$2"


# Critical Section
while ! ln "$0" "$dir_name-lock" 2>/dev/null; do
	sleep 1
done


# Check that the database exists and that the table does not exist. Create the table and add the table headings if both test are passed
if ! [ -d "$dir_name" ]; then
	echo "Error: database" "$dir_name" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1

elif [ -f "$file_path" ]; then
	echo "Error: table" "$2" "already exists" >&2
	rm "$dir_name-lock"
	exit 1

else
	echo "OK: table created"
	echo "$headers" >> "$file_path"
fi

rm "$dir_name-lock"

exit 0
