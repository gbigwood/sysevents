#!/bin/bash

set -e 
set -x

#Give it a top level uuid...

# Convert to dotfile
python3 dotmaker.py $1 /tmp/grid.dot
cat /tmp/grid.dot

# Visualise
dot -Tpng /tmp/grid.dot -o /tmp/grid.png 
