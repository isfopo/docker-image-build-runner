#!/bin/bash
set -euo pipefail
ANKI_VERSION=$(pip index versions anki |grep -E 'anki \(.+\)' |sed 's/^anki (//g;s/)$//g')
docker build -t cryptkiddie2/ankisyncserver:latest .
docker tag cryptkiddie2/ankisyncserver:latest "cryptkiddie2/ankisyncserver:v$ANKI_VERSION"
docker login -u "$DOCKER_USER" --password "$DOCKER_PW"
docker push cryptkiddie2/ankisyncserver:latest
docker push "cryptkiddie2/ankisyncserver:v$ANKI_VERSION"
docker logout
