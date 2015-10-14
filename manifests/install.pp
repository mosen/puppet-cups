# Installs CUPS and related components
class cups::install {
  package { 'cups':
    ensure          => $::cups::package_ensure,
    name            => $::cups::package_name,
    install_options => $::cups::package_install_options,
  }

  if $::cups::cups_lpd_enable {
    package { 'cups-lpd':
      ensure          => $::cups::package_ensure,
      name            => $::cups::package_cups_lpd,
      install_options => $::cups::package_cups_lpd_install_options,
    }
  }
}
