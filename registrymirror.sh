#!/bin/bash

# Modify for your own repos.
SOURCEREPO=s.rd3.nz
DESTREPO=d.rd3.nz
LOCKTIMEOUT=5
LOCKFILE="/tmp/registrymirror.lock"

# Check if we can et a lock, so only one is running on a system at a time
touch $LOCKFILE  # Create lock
exec {FD}<>$LOCKFILE  # Get file descriptor
if ! flock -x -w $LOCKTIMEOUT $FD; then
        >&2 echo "!!! Failed to obtain a lock via $LOCKFILE within $LOCKTIMEOUT seconds"
  exit 1
fi

echo Replicating all images from $SOURCEREPO to $DESTREPO

# Get top level list of registies into array
curl -sX GET https://${SOURCEREPO}/v2/_catalog -o /tmp/in.json

# now getall the tags
jq -r '.repositories[]' /tmp/in.json | while read reg; do 
    tagurl=https://${SOURCEREPO}/v2/${reg}/tags/list
    curl -sX GET $tagurl -o /tmp/tags.json
    # and itterate through em
    jq -r '.tags[]' /tmp/tags.json | while read tags; do 
        oldname="$SOURCEREPO/${reg}:${tags}"
        newname="$DESTREPO/${reg}:${tags}"
        echo 
        echo "$oldname -> $newname"
        docker pull $oldname
        docker tag $oldname $newname
        docker push $newname
    done
done

rm /tmp/in.json
rm /tmp/tags.json
