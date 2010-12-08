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
# export RAILS_ENV="hudson"
# rake -f init_ci.rakefile --trace
# rake -f init_testbed.rakefile
# cd testbed
# bundle exec rake spec cucumber

set +x
echo "Loading RVM"
source ~/.rvm/scripts/rvm
set -x

RVM_RUBY=ree
GEMSET=surveyor-dev

if [ -z "$RVM_RUBY" ]; then
    echo "Could not map env (RVM_RUBY=\"${RVM_RUBY}\") to an RVM version.";
    shopt -q login_shell
    if [ $? -eq 0 ]; then
        echo "This means you are still using the previously selected RVM ruby."
        echo "Probably not what you want -- aborting."
        # don't exit an interactive shell
        return;
    else
        exit 1;
    fi
fi

echo "Switching to ${RVM_RUBY}@${GEMSET}"
set +xe
rvm use "${RVM_RUBY}@${GEMSET}"
if [ $? -ne 0 ]; then
    echo "Switch failed"
    exit 2;
fi
set -xe
ruby -v

set +e
gem list -i rake
if [ $? -ne 0 ]; then
    echo "Installing rake since it is not available"
    gem install rake
fi
set -e
