#!/bin/bash

[ -z "$1" ] && echo "No role supplied" && exit 1

ROLE="$1"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if Puppet already installed
#command -v /opt/puppetlabs/bin/puppet >/dev/null 2>&1 && { echo >&2 "Puppet is already installed. Aborting."; exit 0; }

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone https://github.com/rkh/rbenv-whatis.git ~/.rbenv/plugins/rbenv-whatis
git clone https://github.com/rkh/rbenv-use.git ~/.rbenv/plugins/rbenv-use
cd ~/.rbenv && src/configure && make -C src

rbenv install 2.3.1
rbenv install 1.9.3-p551
rbenv rehash

rbenv global 1.9.3-p551
rbenv use 1.9.3-p551
gem install bundler

rbenv global 2.3.1
rbenv use 2.3.1
gem install bundler

cd /tmp
wget https://apt.puppetlabs.com/puppet5-release-stretch.deb 
dpkg -i puppet5-release-stretch.deb 
apt-get update
apt install -y puppet-agent

/opt/puppetlabs/bin/puppet resource cron puppet-apply ensure=present user=root minute=30 command="/opt/puppetlabs/bin/puppet apply $DIR/manifests/roles/$ROLE.pp  --logdest syslog"
