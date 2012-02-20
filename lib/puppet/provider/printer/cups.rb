# TODO: Consider enable/disable, accept/reject and options as property methods.
# TODO: Consider parsing lpstat -l -p for more detail on prefetch
# TODO: lpstat -v for device-uris in prefetch
# TODO: change of device uri should imply destroy+create
# NOTE: cups will always report the PPD being used in /etc/cups/ppds even if the ppd is sourced outside of this dir.
# So, we can't reliably detect the PPD state.

require 'shellwords'

Puppet::Type.type(:printer).provide :cups, :parent => Puppet::Provider do
  desc "This provider manages installed printers using CUPS command line tools"

  commands :lpadmin => "/usr/sbin/lpadmin"
  commands :lpoptions => "/usr/bin/lpoptions"
  commands :lpinfo => "/usr/sbin/lpinfo"
  commands :lpstat => "/usr/bin/lpstat"

  commands :cupsenable => "/usr/sbin/cupsenable"
  commands :cupsdisable => "/usr/sbin/cupsdisable"

  commands :cupsaccept => "/usr/sbin/cupsaccept"
  commands :cupsreject => "/usr/sbin/cupsreject"

  class << self

    # A hash of possible parameters to their command-line equivalents.
    Cups_Options = {
        :uri => '-v "%s"',
        :description => '-D "%s"',
        :location => '-L "%s"',
        :ppd => '-P "%s"'
    }

    # Retrieve simple list of printer names
    def printers
      lpstat('-p').split("\n").map { |line|
        line.match(/printer (.*) is/).captures[0]
      }
    end

    # Retrieve long listing of printers
    # The PPD path that CUPS uses may have been automatically reformatted or changed by CUPS. making it hard to keep
    # ppd location idempotent.
    # TODO: theres probably a better way to parse this.
    def printers_long
      printers = []
      printer = {} # Current printer entry being parsed

      lpstat('-l', '-p').split("\n").each { |line|
        case line
          when /^printer/

            if printer.key? :name # Push the last result
              printers.push printer
              printer = {}
            end

            printer[:name] = line.match(/printer (.*) is/).captures[0]
          when /^\tDescription/
            printer[:description] = line.match(/\tDescription: (.*)/).captures[0]
          when /^\tLocation/
            printer[:location] = line.match(/\tLocation: (.*)/).captures[0]
          when /^\tInterface/
            printer[:ppd] = line.match(/\tInterface: (.*)/).captures[0]
        end
      }

      printers.push printer

      printers
    end

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

    # Retrieve Device-uri's
    def printer_uris
      uris = {}

      lpstat('-v').split("\n").each { |line|
        caps = line.match(/device for (.*): (.*)/).captures
        uris[caps[0]] = caps[1]
      }

      uris
    end

    def prefetch(resources)
      prefetched_uris = self.printer_uris

      prefetched_long = self.printers_long.collect { |p|

        p[:options] = self.printer_options(p[:name])
        p[:provider] = :cups
        p[:uri] = prefetched_uris[p] if prefetched_uris.key? p

        new(p)
      }

      prefetched_long
    end

    def instances
      []
    end
  end

  def create
    options = Array.new

    # Handle most parameters via string substitution
    Cups_Options.keys.each do |k|
      options.unshift Cups_Options[k] % @resource[k] if @resource.parameters.key?(k)
    end

    options.push '-o printer-is-shared=true' if @resource[:shared]
    options.push '-E' if @resource[:enabled]

    lpadmin "-p", @resource[:name], options
  end

  def destroy
    lpadmin "-x", @resource[:name]
  end

  # TODO: use prefetched resources instead of executing the utility again.
  def exists?
    self.class.printers.select { |v| v.downcase == @resource[:name].downcase }.length > 0
  end
end