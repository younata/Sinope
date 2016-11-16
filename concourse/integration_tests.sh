#!/bin/bash

cd sinope_github
bundle
bundle exec rake test:integration:setup_and_run
