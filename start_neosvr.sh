#!/bin/sh

if [ "$MODS" = true ]; then
  exec mono ${STEAMAPPDIR}/Neos.exe -c /Config/Config.json -LoadAssembly "/Libraries\NeosModLoader.dll" -l /Logs
else
  exec mono ${STEAMAPPDIR}/Neos.exe -c /Config/Config.json -l /Logs
fi
