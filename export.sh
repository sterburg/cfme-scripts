#!/bin/sh

export RUBYOPT=W0

## Prerequisites
echo "## Installing git"
rpm --quiet -q git && echo "Already installed" || yum -y install git
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


## Export CFME Database objects
for i in `ls -d * |egrep -v "vmdb|port.sh"`
do
  echo
  echo "## Export " $i
  miqexport $i $PWD/$i
done


## Export UI Customizations
echo
echo "## Export UI Customizations"
cd /var/www/miq/vmdb/
cp -a -f --parents \
   ./public/assets/atea/                              \
   ./product/menubar/                                 \
   ./app/assets/stylesheets/main.scss                 \
   ./app/assets/stylesheets/icon_customizations.scss  \
   ./productization/assets/stylesheets/main.scss      \
   $HOME/AteaCloudformsConfiguration/vmdb/


## Save
echo
echo "## Upload AteaCloud Configuration repository"
cd $HOME/AteaCloudformsConfiguration
git add .
git commit -m "`date +%Y%m%d` `hostname -f`"
git push   -u origin master

