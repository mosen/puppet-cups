require 'spec_helper_acceptance'

describe 'printer resource ppd_options parameter' do

  # PPD options described in the Adobe PPD Specification Document.
  describe 'when setting ColorModel=Gray' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_ppd_colormodel':
          ensure       => present,
          model        => 'drv:///sample.drv/deskjet.ppd',
          description  => 'PPD ColorModel',
          ppd_options  => {
            'ColorModel' => 'Gray'
          }
       }
      EOS
    }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    it 'should reflect the setting ColorModel=Gray in the vendor options listing' do
      expect(shell("lpoptions -p cups_printer_ppd_colormodel -l").stdout).to include("*Gray")
    end
  end

  after(:all) do
    # Clean up tests for re-run
    shell("lpadmin -x cups_printer_ppd_colormodel")
  end
end