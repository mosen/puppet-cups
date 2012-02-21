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
  end

  it 'should be able to get a list of existing printers' do
    provider.expects(:execute).with(['/usr/sbin/lpadmin']).returns("")

    provider.instances.each do |p|
      p.should be_instance_of(provider)
      p.properties[:provider].to_s.should == provider.name.to_s
    end
  end
end