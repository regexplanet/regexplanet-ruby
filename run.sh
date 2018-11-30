#!/bin/bash


docker build -t regexplanet-ruby .
docker run \
	-p 4000:4000 --expose 4000 -e PORT='4000' \
	-e COMMIT=$(git rev-parse --short HEAD) \
	-e LASTMOD=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
	regexplanet-ruby
