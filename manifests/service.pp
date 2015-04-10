class cups::service () {

    service { 'cups':
        ensure     => $cups::service_ensure,
        enable     => $cups::service_enabled,
        hasstatus  => true,
        hasrestart => true,
        require    => Class['cups::install'],
    }

    if $cups::cups_lpd_enable {
        service { 'xinetd':
            ensure     => $cups::cups_lpd_ensure,
            enable     => $cups::cups_lpd_enable,
            hasstatus  => true,
            hasrestart => true,
            subscribe  => File['/etc/xinetd.d/cups-lpd'],
        }
    }
}
