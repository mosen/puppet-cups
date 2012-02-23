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
    provider.stubs(:command).with(:lpoptions).returns "/usr/bin/lpoptions"
    provider.stubs(:command).with(:lpinfo).returns "/usr/sbin/lpinfo"
    provider.stubs(:command).with(:lpstat).returns "/usr/bin/lpstat"

    provider.stubs(:command).with(:cupsenable).returns "/usr/sbin/cupsenable"
    provider.stubs(:command).with(:cupsdisable).returns "/usr/sbin/cupsdisable"

    provider.stubs(:command).with(:cupsaccept).returns "/usr/sbin/cupsaccept"
    provider.stubs(:command).with(:cupsreject).returns "/usr/sbin/cupsreject"
  end

  it 'should be able to get a list of existing printers' do

    provider.instances.each do |printer|
      printer.should be_instance_of(provider)
      printer.get(:provider).to_s.should == provider.name.to_s
    end
  end
end