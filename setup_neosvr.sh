#!/bin/sh

bash "${STEAMCMDDIR}/steamcmd.sh" \
	+force_install_dir ${STEAMAPPDIR} \
	+login ${STEAMLOGIN} \
	+app_license_request ${STEAMAPPID} \
	+app_update ${STEAMAPPID} -beta ${STEAMBETA} -betapassword ${STEAMBETAPASSWORD} validate \
	+quit

if [ "$CLEANASSETS" = true ]; then
	find ${STEAMAPPDIR}/Data/Assets -type f -atime +7 -delete
	find ${STEAMAPPDIR}/Data/Cache -type f -atime +7 -delete
fi
if [ "$CLEANLOGS" = true ]; then
	find /Logs -type f -name *.log -atime +30 -delete
fi

if [ "$MODS" = true ]; then
	# https://github.com/neos-modding-group/NeosModLoader/issues/56
	mkdir -p "${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR}/Neos_Data\Managed"
	ln -s ${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR}/FrooxEngine.dll "${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR}/Neos_Data\Managed/FrooxEngine.dll"
	curl -sqLo "${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR}/Libraries\NeosModLoader.dll" ${NMLURL}
fi

exec $*
