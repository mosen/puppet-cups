#!/usr/bin/env rspec

# TODO: cant require spec_helper outside of puppet tree?

printer = Puppet::Type.type(:printer)

describe printer do
  before do
    #ENV["PATH"] += File::PATH_SEPARATOR + "/usr/sbin" unless ENV["PATH"].split(File::PATH_SEPARATOR).include?("/usr/sbin")
    @provider = stub 'provider'
    #@resource = stub 'resource', :resource => nil, :provider => @provider, :line => nil, :file => nil
  end

  it "should have a default provider inheriting from Puppet::Provider" do
    printer.defaultprovider.ancestors.should be_include(Puppet::Provider)
  end

  it "should be able to create a instance" do
    printer.new(:name => "foo").should_not be_nil
  end

  describe "instances" do
    it "should have a valid provider" do
      printer.new(:name => "foo").provider.class.ancestors.should be_include(Puppet::Provider)
    end

    it "should delegate existence questions to its provider" do
      instance = printer.new(:name => "foo")
      instance.provider.expects(:exists?).returns "eh"
      instance.exists?.should == "eh"
    end
  end

  properties = [:ensure, :name, :uri, :description, :location, :ppd, :enabled, :shared, :options]

  properties.each do |property|
    it "should have a #{property} property" do
      printer.attrclass(property).ancestors.should be_include(Puppet::Property)
    end

    it "should have documentation for its #{property} property" do
      printer.attrclass(property).doc.should be_instance_of(String)
    end
  end


end