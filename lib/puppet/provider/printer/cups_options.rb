Puppet::Type.type(:printer_defaults).provide :cups_options, :parent => Puppet::Provider do
  desc "This provider manages default printer options using CUPS command line tools"

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