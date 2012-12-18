#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type/file/ensure'

describe Puppet::Type::File::Ensure do
  include PuppetSpec::Files

  let(:path) { tmpfile('file_ensure') }
  let(:resource) { Puppet::Type.type(:file).new(:ensure => 'file', :path => path, :replace => true) }
  let(:property) { resource.property(:ensure) }

  it "should be a subclass of Ensure" do
    described_class.superclass.must == Puppet::Property::Ensure
  end

  describe "when retrieving the current state" do
    it "should return :absent if the file does not exist" do
      resource.expects(:stat).returns nil

      property.retrieve.should == :absent
    end

    it "should return the current file type if the file exists" do
      stat = mock 'stat', :ftype => "directory"
      resource.expects(:stat).returns stat

      property.retrieve.should == :directory
    end
  end

  describe "when testing whether :ensure is in sync" do
    it "should always be in sync if replace is 'false' unless the file is missing" do
      property.should = :file
      resource.expects(:replace?).returns false
      property.safe_insync?(:link).should be_true
    end

    it "should be in sync if :ensure is set to :absent and the file does not exist" do
      property.should = :absent

      property.must be_safe_insync(:absent)
    end

    it "should not be in sync if :ensure is set to :absent and the file exists" do
      property.should = :absent

      property.should_not be_safe_insync(:file)
    end

    it "should be in sync if a normal file exists and :ensure is set to :present" do
      property.should = :present

      property.must be_safe_insync(:file)
    end

    it "should be in sync if a directory exists and :ensure is set to :present" do
      property.should = :present

      property.must be_safe_insync(:directory)
    end

    it "should be in sync if a symlink exists and :ensure is set to :present" do
      property.should = :present

      property.must be_safe_insync(:link)
    end

    it "should not be in sync if :ensure is set to :file and a directory exists" do
      property.should = :file

      property.should_not be_safe_insync(:directory)
    end
  end
end
