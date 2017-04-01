#!/bin/bash -el

cd sinope_github
bundle
bundle exec carthage_cache -b $AWS_CACHE_BUCKET install || (carthage bootstrap --platform ios,mac --no-use-binaries; bundle exec carthage_cache -b $AWS_CACHE_BUCKET publish)
bundle exec rake test:unit
