class cups::install (
) {
    package { 'cups':
        name    => $cups::package_name,
        ensure  => $cups::package_ensure,
    }
    
    if $cups::cups_lpd_enable {
        package { 'cups-lpd':
            name    => $cups::package_cups_lpd,
            ensure  => $cups::package_ensure,
        }
    }
}
