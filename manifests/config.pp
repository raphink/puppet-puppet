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

  case $real_ensure {
    present: {
      $changes = "set ${name} ${value}"
      $onlyif_cond = "size == 0"
    }

    absent: {
      $changes = "rm ${name}"
      $onlyif_cond = "size > 0"
    }

    default : { err ( "unknown ensure value ${ensure}") }
  }

  augeas { "set puppet config parameter '${section}/${name}' to '${value}'":
    context => "/files/etc/puppet/puppet.conf",
    changes => $changes,
    onlyif  => "match ${name}[.='${value}'] ${onlyif_cond}",
    require => Package["puppet"],
  }

}