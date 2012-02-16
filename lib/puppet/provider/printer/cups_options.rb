Puppet::Type.type(:printer_defaults).provide :cups_options, :parent => Puppet::Provider do
  desc "This provider manages default printer options using CUPS command line tools"

  commands :lpoptions => "/usr/bin/lpoptions"
  commands :lpinfo => "/usr/sbin/lpinfo"

  def create

  end

  def destroy

  end

  def exists?

  end
end