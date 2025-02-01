#!/usr/bin/env bash
#
# run the docker container version locally
#

set -o errexit
set -o pipefail
set -o nounset


docker build -t regexplanet-ruby .


docker run \
	--expose 4000 \
	--env COMMIT=$(git rev-parse --short HEAD)-local \
	--env LASTMOD=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
	--env PORT='4000' \
	--publish 4000:4000 \
	regexplanet-ruby

