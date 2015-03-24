require 'spec_helper_acceptance'

describe 'default printer resource' do

  before(:all) do
    shell("lpadmin -p default_printer_fixture -E -DFixture -mdrv:///sample.drv/deskjet.ppd")
  end

  after(:all) do
    shell("lpadmin -x default_printer_fixture")
  end

  describe 'setting the default printer' do
    let(:manifest) {
      <<-EOS
       default_printer { 'default_printer_fixture': ensure => present, }
      EOS
    }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    it 'should output the name of the fixture when calling puppet resource' do
      expect(shell("puppet resource default_printer").stdout).to include('default_printer_fixture')
    end
  end

end