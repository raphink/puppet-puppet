class puppet::database::mysql (
  $dbname = 'puppet',
  $dbuser = 'puppet',
  $dbpassword = 'puppet',
) {

  include ::mysql::server

  mysql::database {'puppet':
    ensure => present,
  }

  mysql::rights {'Set rights for puppet database':
    host     => '%', #TODO: allow only puppetmasters.
    database => $dbname,
    user     => $dbuser,
    password => $dbpassword,
  }

}
