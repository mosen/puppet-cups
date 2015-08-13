# Installs the development packages
class cups::devel {
  package { $::cups::package_devel:
    ensure  => $::cups::ensure,
  }
}
