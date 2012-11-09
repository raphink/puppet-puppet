define puppet::cert (
  $ssldir='',
  $ensure='present'
) {

  $ssldir_opt = $ssldir ? {
    ''      => '',
    default => "--ssldir ${ssldir}",
  }

  case $ensure {
    present: {
      exec {"Generate puppet certificate ${name}":
        command => "puppet cert generate ${ssldir_opt} ${name}",
        unless  => "puppet cert list ${ssldir_opt} ${name}",
      }
    }

    /absent|cleaned/: {
      exec {"Clean puppet certificate ${name}":
        command => "puppet cert clean ${ssldir_opt} ${name}",
        onlyif  => "puppet cert list ${ssldir_opt} ${name}",
      }
    }

    revoked: {
      exec {"Revoke puppet certificate ${name}":
        command => "puppet cert revoke ${ssldir_opt} ${name}",
        onlyif  => "puppet cert list ${ssldir_opt} ${name}",
      }
    }

    default: {
      fail("Wrong ensure value ${ensure}")
    }
  }

}
