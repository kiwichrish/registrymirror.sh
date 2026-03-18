#!/bin/bash

SOURCEREPO=s.rd3.nz
DESTREPO=d.rd3.nz

echo Replicating all images from $SOURCEREPO to $DESTREPO

# Get top level list of registies into array
curl -sX GET https://${SOURCEREPO}/v2/_catalog -o /tmp/in.json

# now getall the tags
jq -r '.repositories[]' /tmp/in.json | while read reg; do 
    tagurl=https://${SOURCEREPO}/v2/${reg}/tags/list
    curl -sX GET $tagurl -o /tmp/tags.json
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
