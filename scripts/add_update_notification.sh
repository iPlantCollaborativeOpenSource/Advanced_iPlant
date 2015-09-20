#!/bin/bash

SYSTEM=$1
DIRECTORY=$2

auth-tokens-refresh -S
DUUID=$(files-list -v -S ${SYSTEM} ${DIRECTORY} | jq -r .[0]._links.metadata.href | egrep -o \"associationIds\"\:\"[0-9a-z\-]+\" | egrep -o "\"[0-9a-z\-]+\"" | tr -d "\"")

NOTIFICATION="{ \"associatedUuid\": \"$DUUID\", \"event\": \"*\", \"url\": \"matt.vaughn@gmail.com\" }"
echo $NOTIFICATION > "notify.json"
notifications-addupdate -F notify.json
