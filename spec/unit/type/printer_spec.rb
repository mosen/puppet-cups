#!/usr/bin/env rspec

require 'spec_helper'

printer = Puppet::Type.type(:printer)

describe printer do
  before do
    @class = printer
    @provider = stub 'provider'
    @provider.stubs(:name).returns(:cups)
    Puppet::Type::Printer.stubs(:defaultprovider).returns @provider

    @resource = @class.new({:name => 'RSpec_Test_Printer'})
  end

  it 'should have :name be its namevar' do
    @class.key_attributes.should == [:name]
  end

  describe ':name' do
    it 'should accept a name' do
      @resource[:name] = 'RSpec_Test_Printer'
      @resource[:name].should == 'RSpec_Test_Printer'
    end

    # CUPS naming requirements

    it 'should not accept a name with spaces' do
      lambda { @resource[:name] = ' test' }.should raise_error(Puppet::Error)
    end

    it 'should not accept a name with tabs' do
      lambda { @resource[:name] = "\ttest" }.should raise_error(Puppet::Error)
    end

    it 'should not accept a name with forward slash' do
      lambda { @resource[:name] = "test/printer" }.should raise_error(Puppet::Error)
    end

    it 'should not accept a name with the pound sign' do
      lambda { @resource[:name] = "test#printer" }.should raise_error(Puppet::Error)
    end
  end

  describe ':uri' do
    it 'should accept a string' do
      @resource[:uri] = "test"
    end
  end

  describe ':description' do
    it 'should accept a string' do
      @resource[:description] = "test"
    end
  end

  describe ':location' do
    it 'should accept a string' do
      @resource[:location] = "test"
    end
  end

  describe ':ppd' do
    it 'should accept a string' do
      @resource[:location] = "test"
    end
  end

  describe ':enabled' do
    it 'should fail if not supplied a boolean value' do
      lambda { @resource[:enabled] = "test" }.should raise_error(Puppet::Error)
    end

    [true, false].each do |v|
      it "should accept boolean value of #{v}" do
        @resource[:enabled] = v
      end
    end
  end

  describe ':shared' do
    it 'should fail if not supplied a boolean value' do
      lambda { @resource[:shared] = "test" }.should raise_error(Puppet::Error)
    end

    [true, false].each do |v|
      it "should accept boolean value of #{v}" do
        @resource[:enabled] = v
      end
    end
  end

  describe ':options' do
    it 'should fail if not supplied a hash value' do
      lambda { @resource[:shared] = "test" }.should raise_error(Puppet::Error)
    end
  end
end