define puppet::config_version::git (
  $ensure = present,
  $environment = undef,
  $path = undef,
) {
  $rname = $environment ? {
    ''      => 'default config_version',
    defalut => "config_version for environment ${environment}",
  }

  ::puppet::config_version { $rname:
    ensure      => $ensure,
    source      => "puppet:///${module_name}/config_version_git.sh",
    environment => $environment,
    path        => $path,
    arguments   => '$environment',
  }
}
