require 'beaker-rspec'
#require 'pry'

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    # Install Puppet
    install_package host, 'rubygems'
    on host, 'gem install puppet --no-ri --no-rdoc'
    on host, "mkdir -p #{host['distmoduledir']}"

    # Install CUPS and start service
    install_package host, 'cups'
    on host, puppet("resource service cups ensure=running enable=true")
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => proj_root, :module_name => 'cups')

    # shell("/bin/touch #{default['puppetpath']}/hiera.yaml")
  end
end
