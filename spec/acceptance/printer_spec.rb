require 'spec_helper_acceptance'

describe 'printer resource properties' do

  describe 'when adding a generic printer queue: `cups_printer_add_0`' do
    let(:manifest) {
      <<-EOS
          printer { 'cups_printer_add_0':
            ensure       => present,
            model        => 'drv:///sample.drv/deskjet.ppd',
            description  => 'Generic Test Printer',
            error_policy => stop_printer,
          }
      EOS
    }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
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

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
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

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    it 'should display the newly set uri in `lpstat -v`' do
      expect(shell("lpstat -v cups_printer_add_0", :acceptable_exit_codes => 0).stdout).to include("lpd://10.10.10.10/test")
    end
  end


  describe 'when disabling printer sharing' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_add_0':
         ensure => present,
         shared => false,
       }
      EOS
    }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    it 'should display printer-is-shared=false as a part of the destination options' do
      expect(shell("lpoptions -p cups_printer_add_0").stdout).to include("printer-is-shared=false")
    end
  end


  describe 'when modifying the location' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_add_0':
         ensure   => present,
         location => "TEST LOCATION",
       }
      EOS
    }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    it 'should display the newly updated description' do
      expect(shell("lpstat -l -p cups_printer_add_0 |grep 'Location:'").stdout).to include("TEST LOCATION")
    end

  end


  describe 'when adding a generic queue with the page_size option set to `A4`' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_add_pagesize':
          ensure       => present,
          model        => 'drv:///sample.drv/deskjet.ppd',
          description  => 'Generic Test Printer PageSize',
          page_size    => 'A4',
       }
      EOS
    }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    it 'should display PageSize=A4 as part of the PPD options' do
      expect(shell("lpoptions -p cups_printer_add_pagesize -l").stdout).to include("*A4")
    end

  end

  describe 'create printer with error_policy=abort_job' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_err_abort':
          ensure       => present,
          model        => 'drv:///sample.drv/deskjet.ppd',
          description  => 'error_policy abort',
          error_policy => abort_job,
       }
      EOS
    }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    # TODO: Test error policy in lpstat output
  end

  after(:all) do
    # Clean up tests for re-run
    shell("lpadmin -x cups_printer_add_0")
    shell("lpadmin -x cups_printer_add_pagesize")
    shell("lpadmin -x cups_printer_err_abort")
  end

end
