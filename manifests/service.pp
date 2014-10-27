class cups::service () {

    service { 'cups':
        ensure     => $cups::service_ensure,
        enable     => $cups::service_enabled,
        hasstatus  => true,
        hasrestart => true,
        require    => Class['cups::install'],
    }
}
