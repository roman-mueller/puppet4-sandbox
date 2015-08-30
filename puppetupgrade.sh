#!/bin/sh

if [ ! -f /etc/provisioned ] ; then
  # remove strange manually placed repo file
  /bin/rm -f /etc/yum.repos.d/puppetlabs*

  # install Puppet 4.x release repo
  /bin/yum -y install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
  if [ $? -ne 0 ] ; then
    echo "Something went wrong intalling the repository RPM"
    exit 1
  fi

  # install / update puppet-agent
  /bin/yum -y install puppet-agent
  if [ $? -ne 0 ] ; then
    echo "Something went wrong intalling puppet-agent"
    exit 1
  fi

  echo "10.13.37.2    puppet" >> /etc/hosts

  touch /etc/provisioned
fi

