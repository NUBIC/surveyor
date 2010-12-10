######
# This is not an executable script.  It selects and configures rvm for
# bcsec's CI process based on the RVM_RUBY environment variable.
#
# Use it by sourcing it:
#
#  . ci-env.sh
#
# Assumes that the create-on-use settings are set in your ~/.rvmrc:
#
#  rvm_install_on_use_flag=1
#  rvm_gemset_create_on_use_flag=1
#
# Hudson Build Execute Shell Commands:
#
# source ci-env.sh
# rake -f hudson.rakefile --trace
# cd testbed
# export RAILS_ENV="hudson"
# bundle exec rake spec cucumber

export rvm_gemset_create_on_use_flag=1
export rvm_project_rvmrc=0

set +xe
echo "Loading RVM ree@surveyor-dev"
source ~/.rvm/scripts/rvm
rvm use ree@surveyor-dev
set -xe
