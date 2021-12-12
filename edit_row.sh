#!/bin/bash




################# Edit Row - replaces the selected row with an a new row ########################




# Check that the correct number of parameters has been provided by the user
if [ "$#" -ne 4 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 4" >&2
	exit 1
fi


# Create directory and file path variables
dir_name="$1"
file_path="$1"/"$2"

# Create variables for the tuples, and convert these tuples to arrays for analysis
data="$3"
IFS="," read -ra data_array<<< "$data"

replacement="$4"
IFS="," read -ra replacement_array<<< "$replacement"


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

# Convert the table headings to an array for comparison with the data array
IFS="," read -ra headings_array<<< "$(head -n 1 "$file_path")"


# Make sure that the number of columns in the data array matches the number of columns in the table
if [ "${#headings_array[@]}" -ne "${#data_array[@]}" ]; then
	echo "Error:" "${#data_array[@]}" "columns supplied in the data array. Number of columns should be:" "${#headings_array[@]}" >&2
	rm "$dir_name-lock"
	exit 1
fi

# Make sure that the number of columns in the replacement array matches the number of columns in the table
if [ "${#headings_array[@]}" -ne "${#replacement_array[@]}" ]; then
	echo "Error:" "${#replacement_array[@]}" "columns supplied in the replacement array. Number of columns should be:" "${#headings_array[@]}" >&2
	rm "$dir_name-lock"
	exit 1
fi


# Check that the row to be replaced exists in the table
row_exists=false
while IFS= read -r line; do

	if [ "$line" = "$data" ]; then
		row_exists=true
	fi

done < "$file_path"

# Give an error if the row provided by the user does not exist
if [ "$row_exists" = false ]; then
	echo "Error:" "$data" "does not exist in table" "$2" >&2
	rm "$dir_name-lock"
	exit 1
fi


# Replace any lines in the data that match the original row supplied by the user with the replacement row supplied by the user.
sed -i "s/$data/$replacement/" "$file_path"

echo "OK: replacement successful"

rm "$dir_name-lock"


exit 0

