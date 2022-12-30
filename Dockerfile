FROM mono

LABEL name=neosvr-headless maintainer="panther.ru@gmail.com"

ARG	HOSTUSERID
ARG	HOSTGROUPID

ENV	STEAMAPPID=740250 \
	STEAMAPP=neosvr \
	STEAMCMDURL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
	NMLLIBURL="https://github.com/neos-modding-group/NeosModLoader/releases/latest/download/0Harmony.dll" \
	NMLURL="https://github.com/neos-modding-group/NeosModLoader/releases/latest/download/NeosModLoader.dll" \
	STEAMCMDDIR=/opt/steamcmd \
	STEAMBETA=__CHANGEME__ \
	STEAMBETAPASSWORD=__CHANGEME__ \
	STEAMLOGIN=__CHANGEME__ \
	USER=neos \
	HOMEDIR=/home/neos
ENV	STEAMAPPDIR="${HOMEDIR}/${STEAMAPP}-headless"

# Prepare the basic environment
RUN	set -x && \
	apt-get -y update && \
	apt-get -y upgrade && \
	apt-get -y install curl lib32gcc1 && \
	rm -rf /var/lib/{apt,dpkg,cache}

# Add locales
RUN	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y locales

RUN	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=en_US.UTF-8 && \
	update-locale LANG=en_GB.UTF-8 && \
	rm -rf /var/lib/{apt,dpkg,cache}

ENV	LANG en_GB.UTF-8

# Fix the LetsEncrypt CA cert
RUN	sed -i 's#mozilla/DST_Root_CA_X3.crt#!mozilla/DST_Root_CA_X3.crt#' /etc/ca-certificates.conf && update-ca-certificates

# Create user, install SteamCMD
RUN	addgroup --gid ${HOSTGROUPID} ${USER}

RUN	adduser --disabled-login \
		--shell /bin/bash \
		--gecos "" \
		--gid ${HOSTGROUPID} \
		--uid ${HOSTUSERID} \
		${USER}

RUN	mkdir -p ${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR} /Config /Logs /Scripts /nml_libs /nml_mods /Libraries && \
	cd ${STEAMCMDDIR} && \
	curl -sqL ${STEAMCMDURL} | tar zxfv - && \
	curl -sqLo ${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR}/nml_libs/0Harmony.dll ${NMLLIBURL} && \
	chown -R ${USER}:${USER} ${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR} /Config /Logs /nml_libs /nml_mods /Libraries

COPY	./setup_neosvr.sh ./start_neosvr.sh /Scripts

RUN	chown -R ${USER}:${USER} /Scripts/setup_neosvr.sh /Scripts/start_neosvr.sh && \
	chmod +x /Scripts/setup_neosvr.sh /Scripts/start_neosvr.sh

# Switch to user
USER ${USER}

WORKDIR ${STEAMAPPDIR}

VOLUME ["${STEAMAPPDIR}", "/Config", "/Logs", "/nml_libs", "/nml_mods"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/Scripts/setup_neosvr.sh"]
CMD ["/Scripts/start_neosvr.sh"]
