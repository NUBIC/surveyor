#!/bin/bash

echo ""

# Set the prompt for the select command
PS3="Choose a stack or 'q' to quit: "
export CUCUMBER_OPTS="--format CucumberSpinner::ProgressBarFormatter"
export SPEC_OPTS="--format Fuubar --color spec"
export BUNDLER_VERSION=1.5.3

options=""
rubies=(2.0.0 2.1.1)
rails_versions=(rails_3.2 rails_4.0)

for i in "${rubies[@]}"
do
  for j in "${rails_versions[@]}"
  do
    options+="$i@$j "
  done
done
options+="all"

# Show a menu and ask for input.
select combo in $options; do
  case $combo in
  all)
    for i in "${rubies[@]}"
    do
      for j in "${rails_versions[@]}"
      do
        export CI_RUBY=$i
        export RAILS_VERSION=$j
        source ~/.rvm/scripts/rvm
        rvm use $CI_RUBY@surveyor-$RAILS_VERSION --create
        read -p "Press [Enter] to run tests on $CI_RUBY@$RAILS_VERSION..."
        gem list -i bundler -v $BUNDLER_VERSION
        if [ $? -ne 0 ]; then
          gem install bundler -v $BUNDLER_VERSION
        fi
        bundle _${BUNDLER_VERSION}_ update
        bundle _${BUNDLER_VERSION}_ exec rake testbed spec cucumber cucumber:wip
      done
    done
    ;;
  "")
    echo ""
    ;;
  *)
    arr=(${combo//@/ })
    export CI_RUBY=${arr[0]}
    export RAILS_VERSION=${arr[1]}
    source ~/.rvm/scripts/rvm
    rvm use $CI_RUBY@surveyor-$RAILS_VERSION --create
    read -p "Press [Enter] to run tests on $CI_RUBY@$RAILS_VERSION..."
    gem list -i bundler -v $BUNDLER_VERSION
    if [ $? -ne 0 ]; then
      gem install bundler -v $BUNDLER_VERSION
    fi
    bundle _${BUNDLER_VERSION}_ update
    bundle _${BUNDLER_VERSION}_ exec rake testbed spec
    ;;
  esac
  break
done