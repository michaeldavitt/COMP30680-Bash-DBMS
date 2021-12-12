#!/bin/bash

# Check that a parameter has been given
if [ "$#" -ne 1 ]; then
	echo "Error:" "$#" "parameters provided. Number of parameters should be: 1" >&2
	exit 1
fi

# trap ctrl-c and call ctrl-c()
trap ctrl_c INT

# Causes the client pipe to be deleted when the user types ctrl-c
function ctrl_c() {
	rm "$id".pipe
	echo -e "\n\nGoodbye"
	exit 0
}

# Create a variable for the client ID and create a pipe
id="$1"
mkfifo "$id".pipe

# Greet the user and show a list of valid commands
echo -e "Welcome user" "$id\n"
echo -e "Below are a list of valid requests that you can make to the server\n"
echo -e "This list can be viewed anytime by typing \"show_options\" below\n"
./show_options.sh

echo -e "\n"

while true; do
	# Prompt user for a request
	read -p "$ " request

	if [ "$request" = "exit" ]; then
		rm "$id".pipe
		echo -e "\nGoodbye"
		exit 0
	fi

	# Split request into the request part and the arguments part
	req=$(echo "$request" | cut -d" " -f1)
	args=$(echo "$request" | cut -d" " -f2-)

	# If no arguments are provided, args = req, so in this case, set args to an empty string
	if [ "$args" = "$req" ]; then
		args=""
	fi

	# Critical Section - Ensures that the client cannot overwrite the request of another client
	while ! ln "$0" "server.pipe-lock" 2>/dev/null; do
		sleep 1
	done

	# Exit if the server has been shutdown
	if ! [ -e server.pipe ]; then
		echo "Error, server not responding. Please restart the server and try again" >&2
		echo "Exiting..." >&2
		rm "$id".pipe
		rm "server.pipe-lock"
		exit 1
	fi

	# Send the request to the server
	echo "$req" "$id" "$args" > server.pipe

	# Read the response from the server
	echo -e "\nstart_result\n"

	# Used IFS= to fix whitespace issues
	while IFS= read -r response; do
		echo "$response"
	done < "$id".pipe

	echo -e "\nend_result\n"

done

exit 0
