class gpfs::kernel_builder  {

  # the gpfs 3.5 kernel glue build scripts check for the existance of g++ and
  # fail if it's not present
  package{['imake', 'kernel-devel', 'kernel-headers', 'gcc-c++', 'rpm-build']:
    ensure  => present,
  }

  package{ 'gpfs.gpl':
    ensure  => latest,
    require => Package['imake', 'kernel-devel', 'kernel-headers'],
  }
}
