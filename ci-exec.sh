#!/bin/bash -xe

BUNDLER_VERSION=1.1.rc
GEMSET=surveyor

export TMPDIR="`pwd`/tmp"
mkdir -p tmp

if [ -n "${RAILS_VERSION}" ]; then
    GEMSET="${GEMSET}-${RAILS_VERSION}"
fi

if [ -z $CI_RUBY ]; then
    echo "CI_RUBY must be set"
    exit 1
fi

set +xe
echo "Initializing RVM"
source ~/.rvm/scripts/rvm
set -xe

# On the overnight build, reinstall all gems
if [ `date +%H` -lt 5 ]; then
    set +xe
    echo "Purging gemset to verify that all deps can still be installed"
    rvm --force $CI_RUBY gemset delete $GEMSET
    set -xe
fi

RVM_CONFIG="${CI_RUBY}@${GEMSET}"
set +xe
echo "Switching to ${RVM_CONFIG}"
rvm use $RVM_CONFIG
set -xe

which ruby
ruby -v

set +e
gem list -i bundler -v $BUNDLER_VERSION
if [ $? -ne 0 ]; then
  set -e
  gem install bundler -v $BUNDLER_VERSION
fi
set -e

bundle _${BUNDLER_VERSION}_ update

bundle _${BUNDLER_VERSION}_ exec rake ci:all --trace
