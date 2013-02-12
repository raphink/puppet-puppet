define puppet::config_version (
  $source,
  $ensure = present,
  $environment = false,
  $path = false,
  $arguments = '$environment',
) {
  $key = $environment ? {
    false   => 'master/config_version',
    default => "${environment}/config_version"
  }

  $script_env_path = $environment ? {
    false   => $path,
    default => "/usr/local/bin/config_version_${environment}.sh",
  }

  $script_path = $script_env_path ? {
    false   => '/usr/local/bin/config_version.sh',
    default => $script_env_path,
  }

  file { $script_path:
    ensure => $ensure,
    source => $source,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  ::puppet::config { $key:
    ensure  => $ensure,
    value   => "${script_path} ${arguments}",
    require => File[$script_path],
  }
}
