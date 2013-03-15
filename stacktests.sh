#!/bin/bash

echo ""

# Set the prompt for the select command
PS3="Choose a stack or 'q' to quit: "

options=""
rubies=(ree 1.9.3)
rails_versions=(rails_3.1 rails_3.2)

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
    read -p "Press [Enter] to run tests on all..."
    for i in "${rubies[@]}"
    do
      for j in "${rails_versions[@]}"
      do
        export CI_RUBY=$i
        export RAILS_VERSION=$j
        source ~/.rvm/scripts/rvm
        rvm use $CI_RUBY@surveyor-$RAILS_VERSION --create
        ./ci-exec.sh
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
    ./ci-exec.sh
    ;;
  esac
  break
done