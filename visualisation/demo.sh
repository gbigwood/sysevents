#!/bin/bash
set -e 
set -x

firstuuid=`uuidgen`
seconduuid=`uuidgen`
thirduuid=`uuidgen`
thirduuid=`uuidgen`
fourthuuid=`uuidgen`

# Create some entries
curl -H 'Content-Type: application/json' -X PUT -d '{"parent_id": "", "type": "main"}' http://localhost:4000/link/$firstuuid
curl -H 'Content-Type: application/json' -X PUT -d "{\"parent_id\": \"$firstuuid\", \"type\": \"get user\"}" http://localhost:4000/link/$seconduuid
curl -H 'Content-Type: application/json' -X PUT -d "{\"parent_id\": \"$seconduuid\", \"type\": \"user found\"}" http://localhost:4000/link/$thirduuid
curl -H 'Content-Type: application/json' -X PUT -d "{\"parent_id\": \"$thirduuid\", \"type\": \"output result\"}" http://localhost:4000/link/$fourthuuid

# demo/smote test to 'GET' the chain
curl -f -H 'Content-Type: application/json' -X GET http://localhost:4000/chain/$seconduuid
echo ""

# convert to dotfile
python3 dotmaker.py $seconduuid /tmp/grid.dot
cat /tmp/grid.dot

# visualise
dot -Tpng /tmp/grid.dot -o /tmp/grid.png 



