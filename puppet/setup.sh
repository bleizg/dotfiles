#!/bin/bash

[ -z "$1" ] && echo "No role supplied" && exit 1

ROLE="$1"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo apt-get install -y build-essential git libreadline-dev
sudo apt-get install -y libssl-dev zlib1g-dev autoconf libicu-dev
sudo apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3
sudo apt-get install -y libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone https://github.com/rkh/rbenv-whatis.git ~/.rbenv/plugins/rbenv-whatis
git clone https://github.com/rkh/rbenv-use.git ~/.rbenv/plugins/rbenv-use

cd ~/.rbenv && src/configure && make -C src

eval "$(rbenv init -)"

rbenv install 2.4.4
rbenv rehash
rbenv global 2.4.4
rbenv use 2.4.4
gem install bundler

cd /tmp
wget https://apt.puppetlabs.com/puppet5-release-stretch.deb
sudo dpkg -i puppet5-release-stretch.deb
sudo apt-get update
sudo apt install -y puppet-agent

sudo /opt/puppetlabs/bin/puppet resource cron puppet-apply ensure=present user=root minute=30 command="/opt/puppetlabs/bin/puppet apply $DIR/manifests/role/$ROLE.pp  --logdest syslog"
