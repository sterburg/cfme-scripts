#!/bin/sh

export RUBYOPT=W0

## Prerequisites
echo "## Prerequisites"
rpm --quiet -q git && echo "Git: Already installed" || yum -y install git
if [ ! -f /var/www/miq/vmdb/lib/tasks/rhconsulting_tags.rake ]; then
  git clone https://github.com/rhtconsulting/cfme-rhconsulting-scripts.git $HOME/cfme-rhconsulting-scripts
  cd $HOME/cfme-rhconsulting-scripts
  make install
else
  echo "cfme-rhconsulting-scripts: Already installed"
fi

## Prepare
echo
echo "## Downloading AteaCloud Configuration repository"
cd $HOME
[ ! -d AteaCloudformsConfiguration ] && git clone https://github.com/anjan03/AteaCloudformsConfiguration.git
cd AteaCloudformsConfiguration
git pull

## Import CFME Database objects
for i in `ls -d * |egrep -v "vmdb|port.sh"`
do
  echo
  echo "## Import " $i
  miqimport $i $PWD/$i
done


## Import UI Customizations
echo
echo "## Import UI Customizations"
cp -va vmdb/* /var/www/miq/vmdb/

cd /var/www/miq/vmdb
echo "## Precompile UI Customizations"
RAILS_ENV=production rake assets:clean assets:precompile
echo "## Restart services"
systemctl restart evmserverd
