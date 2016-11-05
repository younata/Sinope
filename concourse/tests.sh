#!/bin/bash

cd sinope
bundle
bundle exec rake test:unit && bundle exec rake test:integration:setup_and_run
bundle exec rake add_upgrade_chore
