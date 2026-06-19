# Anki Sync Server Docker build

This is a template to build a docker image from a docker enabled project hosted on pypi.

Based of off [ankisyncserver-docker](https://git.zehka.net/zehka/ankisyncserver-docker)

A fresh build is automatically issued every day as I'd forget to update it otherwise.
I have enabled password hashing by default because it is 2024 after all.
Unfortunately i can't include the tool to hash your passwords as it is on sourcehut and they seem to be blocking my build server so you need to hash your own passwords. Also please notice that for docker compose you need to escape every $ by replacing it with $$.

An example docker compose file looks like this:

```
version: '3'
services:
   ankisync:
      image: cryptkiddie2/ankisyncserver:latest
      environment:
         - SYNC_USER1=USERNAME:HASHED_PASSWORD
       volumes:
          - anki_data:/data

volumes:
  anki_data:
    driver: local
```

The built version on docker hub is [here](https://hub.docker.com/repository/docker/cryptkiddie2/ankisyncserver)
