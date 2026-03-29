# Overview

Mirror script for local docker registries.

Uses curl / jq / docker to yank a list of all image names, then tags, then mirrors them.. Simple.

The use case for this is where you have local / private registries you want to sync in a home lab / corporate / air gapped environment.

Up side: You just need to be able to git pull / push to both repos

Down side: It uses as much space on the client / host running the script as the source repo, possibly a bit more.

Pulished it here because I couldn't find one and someone working on the same project wanted to use an open-source script!  :-) 
