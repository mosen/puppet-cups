# Installs CUPS and related components
class cups::install {
  package { 'cups':
    ensure => $::cups::package_ensure,
    name   => $::cups::package_name,
  }

  if $::cups::cups_lpd_enable {
    package { 'cups-lpd':
      ensure => $::cups::package_ensure,
      name   => $::cups::package_cups_lpd,
    }
  }
}
