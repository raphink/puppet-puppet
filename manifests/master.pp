class puppet::master {

  $puppetmaster_pkg = $::operatingsystem ? {
    /Debian|Ubuntu/        => 'puppetmaster',
    /RedHat|CentOS|Fedora/ => 'puppet-server',
  }

  package {'puppetmaster':
    ensure => present,
    name   => $puppetmaster_pkg,
  }

  # used by puppetdoc -m pdf
  package {'python-docutils':
    ensure => present
  }

  if $::operatingsystem =~ /RedHat|CentOS|Fedora/ {
    package {'ruby-rdoc': ensure => present }
  }

  if $::operatingsystem =~ /Debian|Ubuntu/ {
    package { 'libactiverecord-ruby': ensure => present }
  } else {
    package {'activerecord':
      ensure   => present,
      provider => 'gem',
      require  => Package['ruby-dev'],
    }
  }

  if (versioncmp($::puppetversion, 2) > 0) {
    $master = 'master'
  } else {
    $master = 'puppetmasterd'
  }

  case $puppetdbtype {
    'mysql': {
      $mysql = $::operatingsystem ? {
        /Debian|Ubuntu/        => 'libdbd-mysql-ruby',
        /RedHat|CentOS|Fedora/ => 'ruby-mysql',
      }

      puppet::config {
        "${master}/dbadapter":     value => 'mysql';
        "${master}/storeconfigs":  value => true;
        "${master}/dbmigrate":     value => true;
        "${master}/dbserver":      value => $puppetdbhost;
        "${master}/dbname":        value => $puppetdbname;
        "${master}/dbuser":        value => $puppetdbuser;
        "${master}/dbpassword":    value => $puppetdbpw;
        "${master}/dbconnections": value => $puppetdbconnections;
      }

      package {'ruby-mysql':
        ensure => present,
        name   => $mysql,
      }
    }

    'mysql2': {

      puppet::config {
        "${master}/dbadapter":     value => 'mysql2';
        "${master}/storeconfigs":  value => true;
        "${master}/dbmigrate":     value => true;
        "${master}/dbserver":      value => $puppetdbhost;
        "${master}/dbname":        value => $puppetdbname;
        "${master}/dbuser":        value => $puppetdbuser;
        "${master}/dbpassword":    value => $puppetdbpw;
        "${master}/dbconnections": value => $puppetdbconnections;
      }

      package {
        'mysql-devel':
          ensure => present;

        'mysql2':
          ensure   => present,
          provider => 'gem',
          require  => Package['mysql-devel'];
      }      
    }

    'sqlite': {
      package { ['sqlite3', 'libsqlite3-ruby']:
        ensure => present,
      }

      puppet::config {
        "${master}/dbadapter":    value => 'sqlite3';
        "${master}/storeconfigs": value => true;
        "${master}/dbmigrate":    value => true;
        "${master}/dbserver":     value => $puppetdbhost;
        "${master}/dbname":       value => $puppetdbname;
        "${master}/dbuser":       value => $puppetdbuser;
        "${master}/dbpassword":   value => $puppetdbpw;
      }
    }

    default: {
      puppet::config {
        "${master}/dbadapter":    ;
        "${master}/storeconfigs": value => false;
        "${master}/dbmigrate":    ;
        "${master}/dbserver":     ;
        "${master}/dbname":       ;
        "${master}/dbuser":       ;
        "${master}/dbpassword":   ;
      }
    }

  }

}
