#!/bin/bash


docker build -t regexplanet-ruby .
docker run -p 4000:4000 --expose 4000 -e PORT='4000' regexplanet-ruby
