#!/bin/sh

if [ ! -f /etc/provisioned ] ; then
  # remove Puppet 3.7.x and repositories
  /bin/yum -y remove puppet hiera facter ruby-augeas ruby-shadow
  /bin/rm -f /etc/yum.repos.d/puppetlabs*

  # install Puppet 4.x
  /bin/yum -y install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
  if [ $? -ne 0 ] ; then
    echo "Something went wrong intalling the repository RPM"
    exit 1
  fi

  /bin/yum -y install puppet-agent
  if [ $? -ne 0 ] ; then
    echo "Something went wrong intalling puppet-agent"
    exit 1
  fi

  echo "10.13.37.2    puppet" >> /etc/hosts

  touch /etc/provisioned
fi

