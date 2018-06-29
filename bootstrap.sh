#!/bin/bash

# Check if data folder is empty, bootstrap it if so
if [ ! -d "/server/data/data" ]; then
  echo -e "Data folder empty, populating with CoreScripts"
  cp -a /server/CoreScripts/. /server/data/
fi

# Execute the rest of the arguments as a command
exec $@
