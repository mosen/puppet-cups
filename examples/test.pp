# Demonstrate usage of the printer resource type, and the cups provider

printer { "Printer_A":
    ensure      => present,
    uri         => "file:///", # Not validated with CUPS recognised uri's, so check before usage.
    description => "This is the printer description",
    location    => "Main office",
    ppd         => "/Library/Printers/PPDs/Printer.ppd", # This file is automatically required.
    enabled     => true, # Enabled by default
    accept      => true, # Enabled by default
    shared      => false, # Disabled by default
    options     => {}, #
}
