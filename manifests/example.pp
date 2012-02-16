# Demonstrate usage of the printer resource type, and the cups provider

class cups {

    # Printer resource sample : all parameters listed (except for ppd options, which depend on the ppd).
    printer { "Printer_A":
        ensure      => present,
        uri         => "lpd://localhost/printer_a",
        description => "This is the printer description",
        location    => "Main office",
        ppd         => "/Library/Printers/PPDs/Printer.ppd",
        enabled     => true, # Enabled by default
        shared      => false, # Disabled by default
        options     => {}, # Not yet supported: hash of PPD options
    }

    # Printer resource sample : the recommended minimum parameters.
    printer { "Printer_B":
        ensure      => present,
        uri         => "lpd://localhost/printer_b",
        description => "This is the printer description",
        ppd         => "/Library/Printers/PPDs/Printer.ppd",
    }

    # Printer resource sample : removing a printer (and keeping it removed).
    printer { "Printer_C":
        ensure      => absent,
    }

    # Mac OS X should use the operatingsystem version to figure out the PPD location.
    # Some drivers are localised, and some are not. Usually 10.5 drivers are not.
    # You can use your own logic to determine how the path will be set in any case.
    $ppd_localedir = $macosx_productversion ? {
        /10\.5/ => "",
        default => "en.lproj/" # your own locale
    }

    printer { "osx_printer":
        ensure => present,
        ppd    => "/Library/Printers/PPDs/{$ppd_localedir}Printer.ppd",
        # ..etc
    }
}