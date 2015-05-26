#!/bin/bash

echo ""

# Set the prompt for the select command
PS3="Choose a surveyor stack or 'q' to quit: "
export SPEC_OPTS="--format Fuubar --color spec"
export BUNDLER_VERSION=1.6.1

options=""
rubies=(2.0.0 2.1.1)
rails_versions=(3.2.17 4.0.0)

for i in "${rubies[@]}"
do
  for j in "${rails_versions[@]}"
  do
    options+="$i@$j "
  done
done

# Show a menu and ask for input.
select combo in $options; do
  case $combo in
  *)
    arr=(${combo//@/ })
    export RUBY_VERSION=${arr[0]}
    export RAILS_VERSION=${arr[1]}
    echo "$RUBY_VERSION" > .ruby-version
    echo "surveyor-rails_$RAILS_VERSION" > .ruby-gemset
    source ~/.rvm/scripts/rvm
    rvm use $RUBY_VERSION@surveyor-rails_$RAILS_VERSION --create
    read -p "Press [Enter] to remove and regenerate testbed for $RUBY_VERSION@surveyor-rails_$RAILS_VERSION..."
    gem list -i bundler -v $BUNDLER_VERSION
    if [ $? -ne 0 ]; then
      gem install bundler -v $BUNDLER_VERSION
    fi
    bundle _${BUNDLER_VERSION}_ update
    bundle _${BUNDLER_VERSION}_ exec rake testbed
    echo 'if [ -f "$rvm_path/scripts/rvm" ] && [ -f ".ruby-version" ]; then
  source "$rvm_path/scripts/rvm"
  if [ -f ".ruby-gemset" ]; then
    rvm use `cat .ruby-version`@`cat .ruby-gemset`
  else
    rvm use `cat .ruby-version`
  fi
fi' > testbed/.powrc
    echo "$RUBY_VERSION" > testbed/.ruby-version
    echo "surveyor-rails_$RAILS_VERSION" > testbed/.ruby-gemset
    ;;
  esac
  break
done