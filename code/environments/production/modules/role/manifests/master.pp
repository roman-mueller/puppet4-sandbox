# class to deploy master node:
# - puppetserver
# - puppetdb

class role::master {

  # dependencies repo needed for activemq...
  yumrepo { 'puppetlabs-deps':
    ensure   => 'present',
    baseurl  => 'http://yum.puppetlabs.com/el/7/dependencies/$basearch',
    descr    => 'Puppet Labs Dependencies El 7 - $basearch',
    enabled  => '1',
  }

  # https://tickets.puppetlabs.com/browse/SERVER-557
  file { '/etc/systemd/system/puppetserver.service.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/systemd/system/puppetserver.service.d/local.conf':
    ensure  => 'file',
    content => "[Service]\nTimeoutStartSec=500",
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

  # require puppetserver class to make sure java is installed and avoid
  # puppetlabs/java dependency
  class  { 'activemq':
    mq_broker_name      => 'puppet',
    mq_admin_username   => 'puppet',
    mq_admin_password   => 'puppet',
    mq_cluster_username => 'puppet',
    mq_cluster_password => 'puppet',
    require           => [ Yumrepo['puppetlabs-deps'], Class['puppetserver'], ],
  }

  # unsure why, but this folder does not get crated and without it activemq
  # fails to start
  file { '/usr/share/activemq/activemq-data':
    ensure  => 'directory',
    group   => 'activemq',
    owner   => 'activemq',
    mode    => '0755',
    require => Class['activemq'],
  }

  class { '::mcollective':
    connector         => 'activemq',
    broker_host       => 'puppet',
    broker_port       => '61613',
    broker_user       => 'puppet',
    broker_password   => 'puppet',
    broker_ssl        => false,
    security_provider => 'psk',
    security_secret   => 'puppet',
    use_node          => false,
    require           => File['/usr/share/activemq/activemq-data'],
  }
  include ::mcollective::node

  class { '::mcollective::client':
    connector         => 'activemq',
    broker_host       => 'puppet',
    broker_port       => '61613',
    broker_user       => 'puppet',
    broker_password   => 'puppet',
    security_provider => 'psk',
    security_secret   => 'puppet',
   }

}

