# TBP Mailing

This is a dockerized mailing server with the configs set for TBP. Currently, it has the following components:

  * Postfix (MTA)
  * Docker  (SASL)
  
These components run in containers of Alpine Linux. Interacting with a container can be accomplished through `docker exec` commands or `docker attach` to enter a shell.
  
## Setup and Running

Before building TBP Mailing with the Makefile, you may wish to take a look at the configurations of the individual components. See the Config section for more details, and the Notes section for specific details about the current configs. Pay attention to the Notes section on authentication if you wish to set that up, as the default set up has no valid entries.

TBP Mailing comes with a Makefile with the following commands:

  * `make build`: Builds the relevant containers
  * `make run`: Starts the relevant containers
  * `make stop`: Stops the relevant containers
  * `make clean`: Stops and removes the relevant containers
  * `make clear`: Removes the relevant containers, networks, and volumes (stored mail and logs)
  * `make update_email_aliases`: Updates the virtual email aliases used by postfix (the containers need to be restarted for this to take effect; postmapping and reloading postfix within the container could also work)
  
## Config

TBP Mailing is sorted into folders for its individual components and is managed by a `docker-compose.yml` in the main directory. 

Each component folder contains a config folder, a dist folder, and a Dockerfile. The config folder contains the current configurations of the component, and may be modified as need be. The dist folder contains the configurations for a default install of the component from its original source (may not be completely up to date, but should be reasonably close). 

In order to configure TBP Mailing, modifications may be needed not only to the config folders, but also to the Dockerfile and the `docker-compose.yml` (especially if new ports or volumes are needed).

## Logging

TBP Mailing uses syslog to log for both postfix and docker, with the logs stored within their respective containers. Logs are contained within /var/log. Postfix currently contains logs for the levels crit, err, warning, info, and debug. Docker currently contains logs for the levels crit, err, warning, and info. These logs are stored within volumes, and you may wish to clear them periodically.

## Notes

Because this server does not use the default configuration, various quirks are important to keep in mind. A lot of these quirks are due to legacy considerations and carryover; these may change if these configurations are deemed undesirable.

First, postfix runs chrooted into `/var/spool/postfix`, meaning that copying files into this directory may be necessary to provide postfix with all the information that it needs. Currently, postfix requires various files from `/etc`. If modifications to these files are made, modifications to the files in the chroot directory should be made as well. Currently, postfix runs chrooted to keep security configurations from the original TBP mailing server. If one wishes to run postfix without chroot, changes should be made to `master.cf`.

Second, the allowed SASL mechanisms are `plain login digest-md5 ntlm cram-md5`. This is carried over from the previous implementation, and may be edited within dovecot's `config/conf.d/10-auth.conf`. Because both `digest-md5` and `cram-md5` are allowed, passwords are stored in plaintext within dovecot's `users` file (the location and name of this file may also be altered within `config/conf.d/10-auth.conf`). All users currently are authenticated with the same password (but we all currently authenticate under president anyways). Entries within the users file follow the format of `example@example.com:{PLAIN}passwd`, where PLAIN is the password storage scheme.

Note that the repo does not store a `users` file within `dovecot/config` to avoid committing passwords to git. Instead, an empty `users.dist` file is provided. In order for authentication to work correctly, rename the `users.dist` file to `users` and add the relevant entries.

Third, postfix currently runs with `compatibility_level = 2`. This means that the [backwards compatibility safety net](http://www.postfix.org/COMPATIBILITY_README.html) is disabled. If legacy configurations need to be used, either make the relevant changes described in the link or set the compatibility level to reenable the net.

The server currently runs under unsecured connections, so only port 25 is used and neccessary. More ports may be added if need be. 
  
