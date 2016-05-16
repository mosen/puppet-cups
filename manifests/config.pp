# Configures various aspects of CUPS
class cups::config {
  if $::cups::cups_lpd_enable {    
    xinetd::service { 'cups-lpd' :
      ensure       => 'present',
      service_name => 'printer',
      disable      => 'no',
      socket_type  => 'stream',
      protocol     => 'tcp',
      port         => '515',
      wait         => 'no',
      user         => 'lp',
      server       => '/usr/lib/cups/daemon/cups-lpd',  
    }
  }
}
