require 'spec_helper_acceptance'

describe 'printer resource ppd_options parameter' do

  # PPD options described in the Adobe PPD Specification Document.
  describe 'when setting MediaType=Bond' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_ppd_mediatype':
          ensure       => present,
          model        => 'drv:///sample.drv/deskjet.ppd',
          description  => 'PPD MediaType',
          ppd_options  => {
            'MediaType' => 'Bond'
          }
       }
      EOS
    }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    it 'should reflect the setting ColorModel=Gray in the vendor options listing' do
      expect(shell("lpoptions -p cups_printer_ppd_mediatype -l").stdout).to include("*Bond")
    end
  end

  after(:all) do
    # Clean up tests for re-run
    shell("lpadmin -x cups_printer_ppd_mediatype")
  end
end