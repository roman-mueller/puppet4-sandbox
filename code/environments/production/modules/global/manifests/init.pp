# global class that gets applied to all nodes (see "code/hieradata/global.yaml")

class global {

  service { 'firewalld':
    ensure => 'stopped',
    enable => false,
  }

  host { 'puppet':
    ip => '10.13.37.2',
  }

  host { 'node1':
    ip => '10.13.37.3',
  }

  package { 'puppet-agent':
    ensure => installed,
  }

  service { 'puppet':
    ensure  => running,
    enable  => true,
    require => Package['puppet-agent'],
  }

}
