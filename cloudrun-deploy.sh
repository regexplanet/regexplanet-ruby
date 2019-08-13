#!/bin/bash
#docker login -u oauth2accesstoken -p "$(gcloud auth print-access-token)" https://gcr.io

set -o errexit
set -o pipefail
set -o nounset

docker build -t regexplanet-ruby .
docker tag regexplanet-ruby:latest gcr.io/regexplanet-hrds/ruby:latest
docker push gcr.io/regexplanet-hrds/ruby:latest

gcloud beta run deploy regexplanet-ruby \
	--image gcr.io/regexplanet-hrds/ruby \
	--platform managed \
	--project regexplanet-hrds \
	--region us-central1 \
	--update-env-vars "COMMIT=$(git rev-parse --short HEAD),LASTMOD=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
