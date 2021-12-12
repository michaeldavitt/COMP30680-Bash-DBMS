#!/bin/bash


############# Remove database - Removes a database if it exists #########################


# Check that at least one parameter has been provided
if [ "$#" -ne 1 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 1" >&2
	exit 1
fi

# Create a variable for the database
dir_name="$1"

# Critical Section
while ! ln "$0" "$dir_name-lock" 2>/dev/null; do
	sleep 1
done

# Make sure that the database exists, and remove it if it does
if [ -d "$dir_name" ]; then
	rm -r "$dir_name"
	echo "OK: database" "$dir_name" "removed successfully"
else
	echo "Error: database" "$dir_name" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1
fi

rm "$dir_name-lock"

exit 0
