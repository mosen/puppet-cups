#
class cups::service {
    $ensure_service = $cups::ensure ? {
        present   => running,
        running   => running,
        installed => running,
        default   => stopped,
    }

    service { 'cups':
        ensure     => $ensure_service,
        enable     => $cups::enable,
        hasstatus  => true,
        hasrestart => true,
        require    => Class['cups::install'],
    }
}
