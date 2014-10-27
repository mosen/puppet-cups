require 'spec_helper_acceptance'

test_name "cups::init class"

describe 'cups::init' do
  let(:manifest) {
    <<-EOS
      class { 'cups': }
    EOS
  }

  it 'should complete without error' do
    apply_manifest(manifest, :catch_failures => true)
  end

  it 'should be idempotent' do
    expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be_zero
  end

  it 'should install the cups package' do
    confine :to, :platform => 'centos' do |centos|
      on centos, 'yum list installed cups' do |result|
        expect(result.exit_code).to be_zero
      end
    end

    confine :to, :platform => 'ubuntu' do |ubuntu|
      on ubuntu, 'dpkg --get-selections cups' do |result|
        expect(result.exit_code).to be_zero
      end
    end
  end

  it 'should ensure that the cups service is running' do
    confine :to, :platform => 'centos' do |centos|
      on centos, 'service cups status' do |result|
        expect(result.exit_code).to be_zero
      end
    end
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
    confine :to, :platform => 'centos' do |centos|
      on centos, 'service cups status' do |result|
        expect(result.exit_code).to_not be_zero
      end
    end
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
    confine :to, :platform => 'centos' do |centos|
      on centos, 'yum list installed cups' do |result|
        expect(result.exit_code).to_not be_zero
      end
    end
  end
end

