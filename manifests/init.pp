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
        options     => [], # Not yet supported: array of PPD options
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
}