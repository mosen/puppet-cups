#!/usr/bin/env rspec

require 'spec_helper'

describe 'cups provider' do
  let(:provider) { Puppet::Type.type(:printer).provider(:cups) }

  let(:resource) {
    Puppet::Type.type(:printer).new({
      :name  => 'RSpec_Test_Printer',
      :uri  => 'file:///',
    })
  }

  before :each do
    Puppet::Type::Printer.stubs(:defaultprovider).returns provider

    provider.stubs(:command).with(:lpadmin).returns "/usr/sbin/lpadmin"
    provider.stubs(:command).with(:lpoptions).returns "/usr/sbin/lpoptions"
    provider.stubs(:command).with(:lpinfo).returns "/usr/sbin/lpinfo"
    provider.stubs(:command).with(:lpstat).returns "/usr/sbin/lpstat"

    provider.stubs(:command).with(:cupsenable).returns "/usr/sbin/cupsenable"
    provider.stubs(:command).with(:cupsdisable).returns "/usr/sbin/cupsdisable"

    provider.stubs(:command).with(:cupsaccept).returns "/usr/sbin/cupsaccept"
    provider.stubs(:command).with(:cupsreject).returns "/usr/sbin/cupsreject"

  end

  it 'should be able to get a list of existing printers' do
    provider.expects(:execute).with(['/usr/sbin/lpadmin']).returns("")
    provider.expects(:execute).with(['/usr/sbin/lpoptions']).returns("")
    provider.expects(:execute).with(['/usr/sbin/lpinfo']).returns("")
    provider.expects(:execute).with(['/usr/sbin/lpstat']).returns("")

    provider.expects(:execute).with(['/usr/sbin/cupsenable']).returns("")
    provider.expects(:execute).with(['/usr/sbin/cupsdisable']).returns("")

    provider.expects(:execute).with(['/usr/sbin/cupsaccept']).returns("")
    provider.expects(:execute).with(['/usr/sbin/cupsreject']).returns("")

    # BUG: for whatever reason RSpec doesn't recognise the cups provider as having an instances method.
    provider.instances.each do |p|
      p.should be_instance_of(provider)
      p.properties[:provider].to_s.should == provider.name.to_s
    end
  end
end