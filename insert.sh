#!/bin/bash



############### Insert - Inserts a row into a table in the database ###########################


# Check to ensure that the correct number of parameters has been provided by the user
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


# Make sure that the database and the file both exist
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


# Make sure that the number of columns in the data array matches the number of columns in the table, and insert the data if this is the case
if [ "${#headings_array[@]}" -ne "${#data_array[@]}" ]; then
	echo "Error:" "${#data_array[@]}" "columns provided. Number of columns should be:" "${#headings_array[@]}" >&2
	rm "$dir_name-lock"
	exit 1

else
	echo "$data" >> "$file_path"
	echo "OK:" "$data" "inserted into table" "$2"
fi

rm "$dir_name-lock"

exit 0

