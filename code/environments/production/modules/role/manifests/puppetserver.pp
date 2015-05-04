# class to deploy puppetserver

class role::puppetserver {

  class { 'puppetserver':
    before => Package['puppet-agent'],
  }

  class { 'puppetdb':
    ssl_listen_address => '0.0.0.0',
  }

  class { 'puppetdb::master::config':
    puppetdb_server     => 'puppet',
    puppet_service_name => 'puppetserver',
    puppet_confdir      => '/etc/puppetlabs/puppet',
  }

}

