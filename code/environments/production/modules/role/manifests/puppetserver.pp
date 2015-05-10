# class to deploy puppetserver

class role::puppetserver {

  # https://tickets.puppetlabs.com/browse/SERVER-557
  file { '/etc/systemd/system/puppetserver.service.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/systemd/system/puppetserver.service.d/local.conf':
    ensure => 'file',
    content => "[Service]\nTimeoutStartSec=180",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/systemd/system/puppetserver.service.d'],
  }

  class { 'puppetserver':
    before  => Service['puppet'],
    require => File['/etc/systemd/system/puppetserver.service.d/local.conf'],
  }

  class { 'puppetdb':
    ssl_listen_address => '0.0.0.0',
    listen_address     => '0.0.0.0',
    open_listen_port   => true,
  }
  class { 'puppetdb::master::config':
    puppetdb_server     => 'puppet',
    puppet_service_name => 'puppetserver',
    strict_validation   => false,
  }

}

