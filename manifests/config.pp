#
# == Definition: puppet::config
#
# Simple wrapper around augeas to set values to options in
# /etc/puppet/puppet.conf
#
# Example:
#   puppet::config { "main/ssldir": value => "/var/lib/ssl" }
#   puppet::config { "ca/ssldir":   value => "/srv/puppetca" }
#
define puppet::config (
  $ensure=present,
  $value='default value'
) {

  # Stay compatible with the way things were done before
  $real_ensure = $value ? {
    'default value' => 'absent',
    default         => $ensure,
  }

  $changes = $real_ensure ? {
    present => "set ${name} '${value}'",
    absent  => "rm ${name}",
  }

  augeas {"set puppet config parameter '${name}' to '${value}'":
    incl    => '/etc/puppet/puppet.conf',
    lens    => 'Puppet.lns',
    changes => $changes,
    require => Package['puppet'],
  }

}
