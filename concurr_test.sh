#!/bin/bash

################## Concurrency Test - Small script for testing the effects of concurrency #####################

./select_all.sh university students & ./remove_table.sh university students & ./insert.sh university students 2,catherine,jacobs,compsci,2
