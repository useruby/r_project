require 'spec_helper'
require 'benchmark'

describe Packages do
  describe '.download' do
    it 'should download PACKAGES.gz from ftp and store it in the tmp folder' do
      Packages.download

      File.should be_exist(Rails.root.join('tmp', 'PACKAGES.gz'))
    end
  end

  describe '.parse' do
    before do
      # FIXME need to add stub file and not download file each time
      Packages.download
    end

    it 'should parse data from PACKAGES.gz and create records about package in db' do
      expect {
        Packages.parse('PACKAGES.gz')
      }.to change(Packages, :count)
    end

    it 'should have abc package in db after parsing' do
      Packages.parse('PACKAGES.gz')

      Packages.where(name: 'abc').should_not be_nil
    end

    it 'should parse file really fast' do
      # FIXME downloading and parsing is really slow, need to optimize this part

      Benchmark.realtime do
        Packages.parse('PACKAGES.gz')
      end.should < 25
    end
  end
end
