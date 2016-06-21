# Manages the Common UNIX Printing System (CUPS)
class cups (
  $default_printer         = undef,
  $package_ensure          = $::cups::params::package_ensure,
  $package_name            = $::cups::params::package_name,
  $package_install_options = $::cups::params::package_install_options,
  $devel_package_ensure    = $::cups::params::devel_package_ensure,
  $devel_package_name      = $::cups::params::devel_package_name,
  $service_ensure          = $::cups::params::service_ensure,
  $service_enabled         = $::cups::params::service_enabled,
  $service_name            = $::cups::params::service_name,
  $cups_lpd_enable         = $::cups::params::cups_lpd_enable,
  $package_cups_lpd        = $::cups::params::package_cups_lpd,
  $config_file             = $::cups::params::config_file,
) inherits cups::params {

  include '::cups::install'
  include '::cups::service'

  $printer_defaults_def = { ensure => present }
  $printer_defaults = hiera_hash('cups::printer_defaults', {})
  create_resources('printer_defaults', $printer_defaults, $printer_defaults_def)

  $printers_def = {
    ensure  => present,
    require => Class['::cups::service'],
  }
  $printers = hiera_hash('cups::printers', {})
  create_resources('printer', $printers, $printers_def)

  if $cups_lpd_enable {
    include '::cups::config'
  }

  if $default_printer {
    validate_string($default_printer)
    validate_re($default_printer, '^[^[:blank:]/#]+$')

    exec { 'default_printer':
      command => "lpoptions -d ${default_printer}",
      unless  => "grep -q \'^Default ${default_printer}$\' /etc/cups/lpoptions",
      path    => ['/usr/local/bin', '/usr/bin', '/bin'],
      require => [ Class['::cups::service'], Printer[keys($printers)], ],
    }
  }
}
