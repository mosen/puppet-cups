require 'spec_helper_acceptance'

test_name "cups::init class"

describe 'cups::init' do
  let(:manifest) {
    <<-EOS
      class { 'cups': }
    EOS
  }

  it 'should work with no errors' do
    apply_manifest(manifest, :catch_failures => true)
    apply_manifest(manifest, :catch_changes => true)
  end

  it 'should install the cups package' do
    expect(shell("puppet resource package cups").stdout).to_not include('absent')
  end

  it 'should ensure that the cups service is running' do
    expect(shell("puppet resource service cups").stdout).to include('running')
  end
end

describe 'cups { ensure => stopped }' do
  let(:manifest) {
    <<-EOS
      class { 'cups':
        ensure => stopped,
      }
    EOS
  }

  it 'should stop the cups service' do
    expect(shell("puppet resource service cups").stdout).to include('stopped')
  end
end

describe 'cups { ensure => absent }' do
  let(:manifest) {
    <<-EOS
      class { 'cups':
        ensure => absent,
      }
    EOS
  }

  it 'should remove the cups package' do
    expect(shell("puppet resource package cups").stdout).to include('absent')
  end
end

describe 'cups { enable => false }' do
  let(:manifest) {
    <<-EOS
      class { 'cups':
        enable => false,
      }
    EOS
  }

  it 'should disable the cups service' do
    expect(shell("puppet resource service cups").stdout).to include('disabled')
  end
end

