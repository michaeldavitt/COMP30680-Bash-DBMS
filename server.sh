#!/bin/bash

# Make a pipe to connect with client
mkfifo server.pipe

while true; do

	# Prompt the user for a command
	read prompt < server.pipe

	# Once a comnmand has been stored in the prompt, there is no danger if it being overwritten by other client commands, so the server pipe lock can be removed
	rm "server.pipe-lock"

	# Separate the user command into the script and the script's parameters
	script=$(echo "$prompt" | cut -d" " -f1)
	id=$(echo "$prompt" | cut -d" " -f2)
	params=$(echo "$prompt" | cut -d" " -f3-)

	case "$script" in
		create_database)
			echo -e "$(./create_database.sh $params &)" > "$id".pipe
			;;
		create_table)
			echo -e "$(./create_table.sh $params &)" > "$id".pipe
			;;
		insert)
			echo -e "$(./insert.sh $params &)" > "$id".pipe
			;;
		select)
			echo -e "$(./select.sh $params &)" > "$id".pipe
			;;
		select_all)
			echo -e "$(./select_all.sh $params &)" > "$id".pipe
			;;
		select_by_name)
			echo -e "$(./select_by_name.sh $params &)" > "$id".pipe
			;;
		select_where)
			echo -e "$(./select_where.sh $params &)" > "$id".pipe
			;;
		select_by_name_where)
			echo -e "$(./select_by_name_where.sh $params &)" > "$id".pipe
			;;
		select_by_name_ordered)
			echo -e "$(./select_by_name_ordered.sh $params &)" > "$id".pipe
			;;
		insert_no_repeats)
			echo -e "$(./insert_no_repeats.sh $params &)" > "$id".pipe
			;;
		remove_database)
			echo -e "$(./remove_database.sh $params &)" > "$id".pipe
			;;
		remove_table)
			echo -e "$(./remove_table.sh $params &)" > "$id".pipe
			;;
		remove_row)
			echo -e "$(./remove_row.sh $params &)" > "$id".pipe
			;;
		remove_row_where)
			echo -e "$(./remove_row_where.sh $params &)" > "$id".pipe
			;;
		edit_row)
			echo -e "$(./edit_row.sh $params &)" > "$id".pipe
			;;
		column_names)
			echo -e "$(./column_names.sh $params &)" > "$id".pipe
			;;
		show_databases)
			echo -e "$(./show_databases.sh $params &)" > "$id".pipe
			;;
		show_tables)
			echo -e "$(./show_tables.sh $params &)" > "$id".pipe
			;;
		show_options)
			echo -e "$(./show_options.sh $params &)" > "$id".pipe
			;;
		shutdown)
			rm server.pipe
			echo "shutting down" > "$id".pipe
			exit 0
			;;
		*)
			rm server.pipe
			echo "Error: bad request" > "$id".pipe
			exit 1
	esac
done;
