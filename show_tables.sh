#!/bin/bash

############### Show Tables - Shows all tables in a given database ##############################



# Check that the correct number of parameters has been provided by the user
if [ "$#" -lt 1 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 1" >&2
	exit 1
fi


# Create a parameter for the database
dir_name="$1"


# Critical Section
while ! ln "$0" "$dir_name-lock" 2>/dev/null; do
	sleep 1
done

# Check that the database exists, and exit if it doesn't 
if ! [ -d "$dir_name" ]; then
	echo "Error: database" "$dir_name" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1
fi

# Display tables in the database
ls "$dir_name"/

rm "$dir_name-lock"

exit 0
