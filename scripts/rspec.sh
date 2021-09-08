#!/bin/bash
bundle exec rspec --format html --out=spec/result/rspec.html && RSPEC_RESULT='success' || RSPEC_RESULT='failed'
export RSPEC_RESULT=$RSPEC_RESULT