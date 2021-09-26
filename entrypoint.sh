#!/bin/bash

if [ ! -d "/server/data/data" ]; then
  echo -e "Data folder empty, populating with CoreScripts"
  cp -a /server/CoreScripts/. /server/data/
fi

./tes3mp-server $@
