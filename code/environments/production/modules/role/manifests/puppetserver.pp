# class to deploy puppetserver

class role::puppetserver {

  class { 'puppetserver':
    before => Package['puppet-agent'],
  }

}

