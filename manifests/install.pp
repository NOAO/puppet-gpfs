class gpfs::install( $gpfs_version = "3.4.0" ) {
  Yumrepo['gpfs'] -> Class['gpfs::install']

  # the gpfs 3.x.0-0 base RPM has to be installed first and then later upgraded
  # to the 3.x.0-y patch level
  exec { "yum install -y -e0 gpfs.base-$gpfs_version-0":
    alias   => "gpfs.base-$gpfs_version-0",
    path    => '/usr/bin',
    unless  => '/bin/rpm -q gpfs.base',
    #before  => Package["gpfs.base-$gpfs_version"],
    before  => Package["gpfs.base"],
  }

  # install the correct gpfs gpl'd kernel glue for our running kernel.  Note
  # that these are not provided by IBM and need to be hand built for each
  # kernel release.

  # puppet will report that install this package fails... even though it doesn't
  # https://projects.puppetlabs.com/issues/10445
  #package{"gpfs.gplbin-$kernelrelease":
  #  ensure  => latest,
  #  require => Package['gpfs.base'],
  #}

  exec { "yum install -y -e0 gpfs.gplbin-$kernelrelease-$gpfs_version":
    path    => '/usr/bin',
    unless  => "/bin/rpm -q gpfs.gplbin-$kernelrelease-$gpfs_version",
    require => Exec["gpfs.base-$gpfs_version-0"],
#    before  => Package["gpfs.base-$gpfs_version"],
#    before  => Package["gpfs.base"],
  }
 
  # this will take two runs to converage as puppet doesn't allow the same
  # package to have states for two different versions during the same run
  #package{ "gpfs.base-$gpfs_version":
  package{ "gpfs.base":
    ensure => latest,
  }

  package{ "gpfs.docs":
    ensure => latest,
  }

  package{ "gpfs.msg.en_US":
    ensure => latest,
  }

  # add /usr/lpp/mmfs/bin to the default PATH
  file { '/etc/profile.d/gpfs.sh':
    ensure  => present,
    mode    => '0644',
    source  => "puppet:///modules/gpfs/gpfs.sh",
  }
}
