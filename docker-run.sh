#!/bin/bash


docker build -t regexplanet-ruby .
docker run \
	--expose 4000 \
	--env COMMIT=$(git rev-parse --short HEAD)-local \
	--env LASTMOD=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
	--env PORT='4000' \
	--publish 4000:4000 \
	regexplanet-ruby

