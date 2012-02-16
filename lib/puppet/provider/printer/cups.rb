Puppet::Type.type(:printer).provide :cups, :parent => Puppet::Provider do
  desc "This provider manages installed printers using CUPS command line tools"

  commands :lpadmin => "/usr/sbin/lpadmin"
  commands :lpoptions => "/usr/bin/lpoptions"
  commands :lpinfo => "/usr/sbin/lpinfo"

  commands :cupsenable => "/usr/sbin/cupsenable"
  commands :cupsdisable => "/usr/sbin/cupsdisable"

  commands :cupsaccept => "/usr/sbin/cupsaccept"
  commands :cupsreject => "/usr/sbin/cupsreject"

  class << self

    # A hash of possible parameters to their command-line equivalents.
    CUPS_KEYS_PARAMS = {
        :name => '%s',
        :uri => '-v "%s"',
        :description => '-D "%s"',
        :location => '-L "%s"',
        :ppd => '-P "%s"',
        :enabled => '-E',
        :shared => '-o printer-is-shared=true',
        :options => '-o %s=%s'
    }
  end

  def create

    # Handle most parameters via string substitution
    params = @resource.keys.map do |k|
      self.class.CUPS_KEYS_PARAMS[k] % @resource[k] if self.class.CUPS_KEYS_PARAMS.key?(k)
    end

    lpadmin "-p", params
  end

  def destroy
    lpadmin "-x", @resource[:name]
  end

  def exists?
    Facter["printers"].value.include?(@resource[:name])
  end
end