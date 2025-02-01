#!/usr/bin/env bash
#
# run locally
#

set -o errexit
set -o pipefail
set -o nounset


bundle install

export PORT=4000
./regexplanet.rb
