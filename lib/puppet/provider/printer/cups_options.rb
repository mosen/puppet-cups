Puppet::Type.type(:printer_defaults).provide :cups_options, :parent => Puppet::Provider do
  desc "This provider manages default printer options by executing lpoptions(1) as the root user.

  The root options are saved under /etc/cups/lpoptions.

  Note: On Mac OS X the default lpoptions do not correlate with the print dialog. The default printer and default media
  are selected by ~/Library/Preferences/com.apple.print.PrintingPrefs.plist (10.6) and submitted with the job options.


  "

  commands :lpoptions => "/usr/bin/lpoptions"
  commands :lpinfo => "/usr/sbin/lpinfo"

  class << self
    # Retrieve options including whether the printer destination is shared.
    def printer_options(destination)
      options = {}

      # I'm using shellsplit here from the ruby std lib to avoid having to write a quoted string parser.
      lpoptions('-d', destination).shellsplit.each do |kv|
        values = kv.split('=')
        options[values[0]] = values[1]
      end

      options
    end

    def prefetch(resources)

    end
  end

  def create

  end

  def destroy

  end

  def exists?

  end
end