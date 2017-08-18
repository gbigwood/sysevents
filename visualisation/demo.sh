#!/bin/bash

set -e 
set -x

firstuuid=`uuidgen`
seconduuid=`uuidgen`
thirduuid=`uuidgen`
fourthuuid=`uuidgen`
fifthuuid=`uuidgen`

# Create some entries
curl -H 'Content-Type: application/json' -X PUT -d '{"parent_id": "", "type": "main"}' http://localhost:4000/link/$firstuuid
curl -H 'Content-Type: application/json' -X PUT -d "{\"parent_id\": \"$firstuuid\", \"type\": \"get user\"}" http://localhost:4000/link/$seconduuid
curl -H 'Content-Type: application/json' -X PUT -d "{\"parent_id\": \"$seconduuid\", \"type\": \"user found\"}" http://localhost:4000/link/$thirduuid
curl -H 'Content-Type: application/json' -X PUT -d "{\"parent_id\": \"$seconduuid\", \"type\": \"output request\"}" http://localhost:4000/link/$fourthuuid
curl -H 'Content-Type: application/json' -X PUT -d "{\"parent_id\": \"$thirduuid\", \"type\": \"output result\"}" http://localhost:4000/link/$fifthuuid

# Demo/smote test to 'GET' the chain
curl -f -H 'Content-Type: application/json' -X GET http://localhost:4000/chain/$seconduuid
echo ""

# Convert to dotfile
python3 dotmaker.py $seconduuid /tmp/grid.dot
cat /tmp/grid.dot

# Visualise
dot -Tpng /tmp/grid.dot -o /tmp/grid.png 
