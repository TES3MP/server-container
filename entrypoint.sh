#!/bin/bash

set -e

if [ ! -d "/server/data/data" ]
then
  echo -e "Data folder empty, populating with CoreScripts"
  cp -a /server/CoreScripts/. /server/data/
fi

printenv | grep 'TES3MP_SERVER_' | while read -r envvar
do
  declare -a envvar_exploded=(`echo "$envvar" | sed 's/=/ /g'`)
  config="${envvar_exploded[0]}"
  value="${envvar_exploded[@]:1}"
  declare -a config_exploded=(`echo "$config" | sed 's/_/ /g'`)
  section="${config_exploded[2]}"
  section="$(echo $section | sed 's/[^ ]\+/\L\u&/g')"
  variable="${config_exploded[@]:3}"
  variable=$(echo "$variable" \
    | tr '[:upper:]' '[:lower:]' \
    | awk -F " " '{printf "%s", $1; \
        for(i=2; i<=NF; i++) printf "%s", toupper(substr($i,1,1)) substr($i,2); print"";}')
  crudini --set ./tes3mp-server-default.cfg \
    "${section}" "${variable}" "${value}"
  echo "Applied config: [$section] $variable = $value"
done

./tes3mp-server $@
