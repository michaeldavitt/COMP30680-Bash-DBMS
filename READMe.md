# Bash DBMS

## Usage
1: Once you have cloned the repository, type ./server.sh & to launch the server in the background

2: Type ./client.sh followed by a numerical client ID to simulate a client

3: Follow the instructions presented by the client interface. These instructions will tell you what commands you should send to create and interact with databases and tables stored on the server.

## Introduction
The objective of this assignment was to implement a rudimentary Database Management System (DBMS) server and clients who interact with it using Bash. The DBMS server receives requests from clients and returns a response via pipes. The server can handle many different client requests, which are described in the requirements section below.

## Requirements
The central idea is that we have a server that acts as an interface between clients and the various databases stored on the server. Clients should be allowed to make the following requests to the server:

• Create database: The client should be able to create a new database in the server.

• Create table: The client should be able to create a new table in the database.

• Insert: The client should be able to insert a new row into a table in the database.

• Select: The client should be able to select specific columns from a table in the database.

• Shutdown: The client should be able to shut down the server

• Exit: The client should be able to exit the server.

## Additional Functionality
• Select All: The client should be able to select all rows from a table in the database

• Select by Name: The client should be able to select specific columns in a table by name, and the resulting output should depend on the order of column names specified by the user (e.g., a request for columns id and firstname should produce a different output to a request for columns firstname and id).

• Select Where: The client should be able to select rows in the table according to a criterion (e.g., column number 1 = 1, column number 2 = michael etc.)

• Select by Name Where: The client should be able to select specific columns in a table by name and provide a criterion (e.g., select id, firstname from employees where id = 1)

• Select by Name Ordered: The client should be able to select specific columns in the table and have the output be ordered by a specified column (e.g., select id, firstname and surname from employees, order by surname. The first row in the output will be the row with the surname that comes first alphabetically).

• Insert No Repeats: The client should not be able to insert rows in a table if these rows already exist.

• Remove Database: The client should be able to remove databases from the server.

• Remove Table: The client should be able to remove tables from the server.

• Remove Row: The client should be able to remove rows from tables.

• Remove Row Where: The client should be able to remove rows according to some criteria (e.g., remove all rows where surname = davitt).

• Edit Row: The client should be able to replace one row in the table with another.

• Column Names: The client should be able to get the column names for a particular table. Having access to the column names is important for other requests, such as select by name where the client is required to specify column names in their request.

• Show Databases: The client should be able to view all existing databases

• Show Tables: The client should be able to view all tables in a database

• Show Options: The client should be able to view a list of all valid requests that they can make to the server. 

## References
1: Reading a file line by line: https://www.cyberciti.biz/faq/unix-howto-read-line-by-line-from-file/

2: Skipping the header when reading a file line by line:
https://stackoverflow.com/questions/31911179/ignoring-first-line-column-header-while-reading-afile-in-bash