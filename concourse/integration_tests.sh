#!/bin/bash

pushd pasiphae_github
bundle install --gemfile=./Gemfile && bundle exec rake db:migrate && PASIPHAE_APPLICATION_TOKEN=\'test\' bundle exec rails s &
sleep 10 
popd
pushd sinope_github
bundle
bundle exec rake test:integration:run
