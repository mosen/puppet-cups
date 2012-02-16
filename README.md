CUPS support for puppet
=======================

*IN DEVELOPMENT*

This module/resource aims to provide support for management of the CUPS printing system.

Primarily it will be used to add and remove printers from client machines running the Mac OS X operating system,
although it should be generic enough to use with any linux/bsd variety with CUPS installed.

It may eventually be used to manage permissions and options for the cups daemon.


Facter Facts
============

A list of facter facts provided by the module.

printers
--------

Provides a list of installed printers.


Resource Types
==============

A list of resource types provided by the module.

printer
-------

The printer resource type is used to add and remove printers from a puppet node.

__Example__

```
    # Printer resource sample : all parameters listed (except for ppd options, which depend on the ppd).

    printer { "Printer_A":
        ensure      => present,
        uri         => "lpd://localhost/printer_a",
        description => "This is the printer description",
        location    => "Main office",
        ppd         => "/Library/Printers/PPDs/Printer.ppd",
        enabled     => true, # Enabled by default
        shared      => false, # Disabled by default
        options     => {}, # Not yet supported: Hash of PPD options ( name => value )
    }
```

See the __lpadmin(8)__  manual page for more information on valid device-uri's.

printer_defaults
----------------

The printer defaults resource type is used to define default options for the CUPS printing system.

__Example__


```
   printer_defaults { "media":
        ensure => present,
        value  => "A4",
   }
```


TODO
====

+ Consider adding a resource type default_printer which would ensure that only one default printer was defined per
manifest. This would be the easiest way to prevent duplicate definitions of default printers and unexpected behaviour.
+ The printers resource does not respond to changes in parameters (i.e does not re-create the printer if the uri or
description changes for example). Investigate using property methods to force those changes.