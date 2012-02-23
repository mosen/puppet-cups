## puppet-cups module

## User Guide

### Overview

This type provides the ability to manage cups printers and options.

Limitations:
+ It currently does not support classes.
+ It currently does not set default printers.

This document is loosely based upon puppetlabs-firewall README, so credit to the maintainers of puppetlabs-firewall for
establishing the format.

### Installation

This module should be checked out or otherwise copied into your modulepath.

If you are not sure where your module path is try this command:

    puppet --configprint modulepath

This module uses Ruby based providers so your Puppet configuration
(ie. puppet.conf) must include the following items:

    [agent]
    pluginsync = true

The module will not operate normally without these features enabled for the
client.

### Examples

The most basic printer install possible:

    printer { "Basic_Printer":
        ensure      => present,
        uri         => "lpd://hostname/printer_a",
        description => "This is the printer description",
        ppd         => "/Library/Printers/PPDs/Printer.ppd", # PPD file will be autorequired
    }

Removing the printer "Basic_Printer" from the previous example:

    printer { "Basic_Printer":
        ensure      => absent,
    }

More advanced install using most of the available properties:

    printer { "Extended_Printer":
        ensure      => present,
        uri         => "lpd://localhost/printer_a",
        description => "This is the printer description",
        location    => "Main office",
        ppd         => "/Library/Printers/PPDs/Printer.ppd", # PPD file will be autorequired
        enabled     => true, # Enabled by default
        shared      => false, # Disabled by default
        options     => { media => 'A4' }, # Hash of options ( name => value )
    }

You can also set a number of default options which will apply to all printers by using the printer_defaults resource.
For instance if you wanted to default the media option to 'A4' for all printers:

    printer_defaults { "media":
        ensure => present,
        value  => "A4",
    }

You can also set printer_defaults to ensure => absent, if you want the option to be unset.


The module provides access to one additional facter fact "printers", which provides a comma separated list of installed
printers.

See the __lpadmin(8)__  manual page for more information on valid device-uri's.
You can execute __lpoptions -l__ to list the valid options for the current printer.

For more information refer to the CUPS administrators manual.

### Bugs

Please submit any issues through Github issues as I don't have a dedicated project page for this module.

## Developer Guide

### Contributing

You can issue a pull request and send me a message if you like, and I will consider taking the patch upstream :)

### Testing

The tests are really only basic at the moment.

Make sure you have:

    rake

Install the necessary gems:

    gem install rspec

And run the tests from the root of the source code:

    rake test