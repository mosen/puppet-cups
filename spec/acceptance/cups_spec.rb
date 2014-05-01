require 'spec_helper_acceptance'

describe 'CUPS printer resource type' do

  describe 'when adding a generic printer queue: `cups_printer_add_0`' do
    let(:manifest) {
      <<-EOS
        printer { 'cups_printer_add_0':
          ensure      => present,
          model       => 'drv:///sample.drv/deskjet.ppd',
          description => 'Generic Test Printer',
        }
      EOS
    }

    before do

    end

    it 'should complete with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be_zero
    end

    it 'should be listed as a print queue' do
      shell("lpstat -a cups_printer_add_0", :acceptable_exit_codes => 0)
    end
  end

  describe 'when modifying the description' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_add_0':
         ensure => present,
         description => 'Generic Test Printer MODIFIED',
       }
      EOS
    }

    before do

    end

    it 'should complete with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be_zero
    end

    it 'should display the newly updated description' do
      expect(shell("lpstat -l -p cups_printer_add_0 |grep 'Description:'").stdout).to include("Generic Test Printer MODIFIED")
    end

  end

  describe 'when modifying the device URI' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_add_0':
         ensure => present,
         uri    => 'lpd://10.10.10.10/test',
       }
      EOS
    }

    it 'should complete with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be_zero
    end

    it 'should display the newly set uri in `lpstat -v`' do
      expect(shell("lpstat -v cups_printer_add_0", :acceptable_exit_codes => 0).stdout).to include("lpd://10.10.10.10/test")
    end
  end



end