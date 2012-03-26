require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe 'Capistrano::Node' do
  describe '.version' do
    it 'parses version' do
      Capistrano::Node.version('0.6.11').should == Gem::Version.new('0.6.11')
    end

    it 'ignores prefix' do
      Capistrano::Node.version('v0.4.3', 'v').should == Gem::Version.new('0.4.3')
    end
  end

  describe '.choose_version' do
    before :each do
      @versions = [
        Gem::Version.new('0.6.3'),
        Gem::Version.new('0.6.4'),
        Gem::Version.new('0.4.2')
      ]
    end
    it 'chooses the matching version' do
      requirement = Gem::Requirement.create('0.6.3')
      Capistrano::Node.choose_version(requirement, @versions).to_s.should == '0.6.3'
    end

    it 'prefers newest version' do
      requirement = Gem::Requirement.create('~>0.6.3')
      Capistrano::Node.choose_version(requirement, @versions).to_s.should == '0.6.4'
    end

    it 'returns nil if no version matches to requirement' do
      requirement = Gem::Requirement.create('~>0.4.3')
      Capistrano::Node.choose_version(requirement, @versions).should be_nil
    end
  end

  describe '.requirement' do
    it 'parses node requirement from package.json file' do
      Tempfile.new('package.json') do |t|
        t.write('{"node":{"version":">=0.6.11"}}')
        Capistano::Node.requirement(t.path).should == Gem::Requirement.create(">=0.6.11")
      end
    end
  end
end
