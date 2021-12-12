#!/bin/bash


####### Create Database - Creates a database if it does not already exist ##################


# Check that one parameter has been provided
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

# Check if the database exists, create one if it doesn't
if [ ! -e "$dir_name" ]; then
	mkdir "$dir_name"
	echo "OK: database" "$dir_name" "successfully created"
else
	echo "Error: database" "$dir_name" "already exists" >&2
	rm "$dir_name-lock"
	exit 1
fi

rm "$dir_name-lock"

exit 0
