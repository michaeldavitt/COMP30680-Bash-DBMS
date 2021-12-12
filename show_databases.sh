#!/bin/bash

for i in $(ls -d */); do
	echo ${i%%/};
done

exit 0
