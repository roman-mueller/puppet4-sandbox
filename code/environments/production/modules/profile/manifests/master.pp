# class to deploy master node:
# - puppetserver
# - puppetdb

class profile::master {

  include firewall

  # https://tickets.puppetlabs.com/browse/SERVER-557
  file { '/etc/systemd/system/puppetserver.service.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  firewall { '8140 accept - puppetserver':
    dport  => '8140',
    proto  => 'tcp',
    action => 'accept',
  }

  firewall { '61613 accept - activemq':
    dport  => '61613',
    proto  => 'tcp',
    action => 'accept',
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
    puppetdb_server         => 'puppet',
    strict_validation       => false,
    manage_report_processor => true,
    enable_reports          => true,
  }

  # require puppetserver class to make sure java is installed and avoid
  # puppetlabs/java dependency
  class  { 'activemq':
    mq_broker_name      => 'puppet',
    mq_admin_username   => 'puppet',
    mq_admin_password   => 'puppet',
    mq_cluster_username => 'puppet',
    mq_cluster_password => 'puppet',
    require             => [ Yumrepo['puppetlabs-deps'],
                              Class['puppetserver'], ],
  }

  # unsure why, but this folder does not get created and without it activemq
  # fails to work properly 
  file { '/usr/share/activemq/activemq-data':
    ensure  => 'directory',
    group   => 'activemq',
    owner   => 'activemq',
    mode    => '0755',
    require => Class['activemq'],
  }

}

