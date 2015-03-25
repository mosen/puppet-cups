require 'spec_helper_acceptance'

describe 'printer resource i18n' do
  before(:all) do
    shell 'export LANG=de_DE.UTF-8'
  end

  after(:all) do
    shell 'export LANG=en_US.UTF-8'
    shell 'lpadmin -x cups_printer_deutsch'
  end

  describe 'create printer with locale de_DE' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_deutsch':
          ensure       => present,
          model        => 'drv:///sample.drv/deskjet.ppd',
          description  => 'drucker',
       }
      EOS
    }

    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end
  end
end

