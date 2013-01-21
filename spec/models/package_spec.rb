require 'spec_helper'
require 'benchmark'

describe Package do
  describe '.download' do
    it 'should download PACKAGES.gz from ftp and store it in the tmp folder' do
      Package.download

      File.should be_exist(Rails.root.join('tmp', 'PACKAGES.gz'))
    end
  end

  describe '.parse' do
    before do
      # FIXME need to add stub file and not download file each time
      Package.download
    end

    it 'should parse data from PACKAGES.gz and create records about package in db' do
      expect {
        Package.parse('PACKAGES.gz')
      }.to change(Package, :count)
    end

    it 'should have abc package in db after parsing' do
      Package.parse('PACKAGES.gz')

      Package.where(name: 'abc').should_not be_nil
    end

    it 'should parse file really fast' do
      # FIXME downloading and parsing is really slow, need to optimize this part

      Benchmark.realtime do
        Package.parse('PACKAGES.gz')
      end.should < 25
    end
  end
  
  describe 'r_version_needed' do
    before do
      @package_abind = FactoryGirl.build :package_abind
      @package_acceptance_sampling = FactoryGirl.build :package_acceptance_sampling
      @package_adabag = FactoryGirl.build :package_adabag
    end

    it 'should return >= 1.5.0 for package_abind' do
      @package_abind.r_version_needed.should == '>= 1.5.0'
    end

    it 'should return >= 2.4.0 for package_acceptance_sampling' do
      @package_acceptance_sampling.r_version_needed.should == '>= 2.4.0'
    end

    it 'should return null for package_adabag' do
      @package_adabag.r_version_needed.should be_nil
    end
  end
end
