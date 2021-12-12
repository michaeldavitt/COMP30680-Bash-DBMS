#!/bin/bash




################# Remove Row - removes the row that the user provides from a table in the database ########################



# Check that the correct number of parameters has been provided by the user
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


# Make sure that the database and table both exist
if ! [ -d "$dir_name" ]; then
	echo "Error: database" "$dir_name" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1

elif ! [ -f "$file_path" ]; then
	echo "Error: table" "$2" "does not exist" >&2
	rm "$dir_name-lock"
	exit 1
fi


# Get the table headings
headings="$(head -n 1 "$file_path")"

# Convert the table headings to an array for comparison with the data array
IFS="," read -ra headings_array<<< "$headings"


# Make sure that the number of columns in the data array matches the number of columns in the table
if [ "${#headings_array[@]}" -ne "${#data_array[@]}" ]; then
	echo "Error:" "${#data_array[@]}" "columns provided. Number of columns should be:" "${#headings_array[@]}" >&2
	rm "$dir_name-lock"
	exit 1
fi


# Get the initial number of lines in the table
initial_count=$(wc -l "$file_path" | cut -d" " -f1)


# Add if statement to ensure that headings cannot be deleted
if [ "$data" != "$headings" ]; then

	# Delete any lines in the data that match the tuple supplied by the user
	sed -i "/$data/d" "$file_path"

fi

# Get new table line count
final_count=$(wc -l "$file_path" | cut -d" " -f1)



# Check to see if a row has been deleted by comparing both table counts
if [ "$initial_count" -gt "$final_count" ]; then
	echo "OK: deletion successful"
else
	echo "Error:" "$data" "did not match any rows in the table" >&2
	rm "$dir_name-lock"
	exit 1
fi

rm "$dir_name-lock"

exit 0

