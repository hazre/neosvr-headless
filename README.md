# neosvr-headless
Docker image of a NeosVR headless server, forked from https://github.com/bontebok/neosvr-headless

Adds support for mods. (WIP, NOT READY TO BE USED)

See NeosVR Discord for beta access key. Steam login is required to download the client. You'll have to disable SteamGuard, so probably create a separate Steam account for your headless server.

Sample docker-compose:
```
version: "3.9"
services:
  neosvr-headless:
    build:
      context: https://github.com/hazre/neosvr-headless.git
      args:
       - HOSTUSERID=${HOSTUSERID:-1000}
       - HOSTGROUPID=${HOSTGROUPID:-1000}
    tty: true
    stdin_open: true
    environment:
      - STEAMBETA=${STEAMBETA}
      - STEAMBETAPASSWORD=${STEAMBETAPASSWORD}
      - STEAMLOGIN=${STEAMLOGIN}
      - CLEANASSETS=${CLEANASSETS:-true}
      - CLEANLOGS=${CLEANLOGS:-true}
      - MODS=${MODS:-false}
    volumes:
      - "./Config:/Config"
      - "./Logs:/Logs"
      - "/etc/localtime:/etc/localtime:ro"
      # optional unless you enable mods
      # - "./nml_libs:/nml_libs"
      # - "./nml_mods:/nml_mods"
    restart: unless-stopped
```

Place your `Config.json` into `Config` folder. Logs would be stored in `Logs` folder.

Note, you MUST supply a .env file along with your docker-compose.yaml, a sample .env file has been included with the name sample.env. Be sure to rename and edit this file to supply all values required including the NeosVR beta access key, your steam login and password, and the UID and GID if the user that owns the Config and Logs folders. If you do not want your logs and/or assets being cleaned after 30 and 7 days respectively, change the values of CLEANLOGS and/or CLEANASSETS to false in the .env file.

You probably need to set `vm.max_map_count=262144` by doing `echo "vm.max_map_count=262144" >> /etc/sysctl.conf` lest you end up with frequent GC crashes.
