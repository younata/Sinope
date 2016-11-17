#!/bin/bash

pushd pasiphae_github
bundle install --gemfile=./Gemfile
bundle exec rake db:migrate
PASIPHAE_APPLICATION_TOKEN='test' bundle exec rails s &
PASIPHAE_PID=$!
sleep 10 
popd
pushd sinope_github
bundle install --gemfile=./Gemfile
bundle exec carthage_cache -b $AWS_CACHE_BUCKET install || (carthage bootstrap --platform ios,mac --no-use-binaries; bundle exec carthage_cache -b $AWS_CACHE_BUCKET publish)
bundle exec rake test:integration:run || kill -9 $PASIPHAE_PID
kill -9 $PASIPHAE_PID
