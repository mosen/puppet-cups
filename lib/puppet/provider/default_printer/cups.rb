Puppet::Type.type(:default_printer).provide :cups, :parent => Puppet::Provider do
  desc "This provider manages the system wide default cups destination.

  This has no effect on the Mac OS X default destination, which is set via the GUI only.
  "

  commands :lpoptions => '/usr/bin/lpoptions'
  commands :lpstat => '/usr/bin/lpstat'

  def self.instances
    default = printer_default

    if default.nil?
      []
    else
      [ new({ :name => default }) ]
    end
  end

  def self.printer_default
    begin
      lpstat('-d').split(':', 2)[1].strip
    rescue
      nil
    end
  end

  def create
    lpoptions '-d', @resource[:name]
  end

  def destroy
    # actually impossible at the moment
  end

  def exists?
    self.class.printer_default == @resource[:name]
  end

end