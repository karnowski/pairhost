require 'spec_helper'
require 'fileutils'

def ensure_config_file
  config_file = File.expand_path('~/.pairhost/config.yml')
  return if File.exist?(config_file)
  puts "Pairhost config file was NOT found.  Aborting."
  abort
end

describe Pairhost do
  context "when NO pairhost config is present" do
    let(:config_file) { File.expand_path('~/.pairhost/config.yml') }
    let(:config_dir) { File.expand_path('~/.pairhost') }
    let(:backup_dir) { File.expand_path('~/.pairhost_test_backup') }

    before(:all) { FileUtils.mv(config_dir, backup_dir) if File.exist?(config_dir) }
    after(:all)  { FileUtils.mv(backup_dir, config_dir) if File.exist?(backup_dir) }

    %w{create up provision attach detach status ssh resume stop destroy}.each do |method|
      it "#{method} returns an error message and failure exit code" do
        pairhost method
        stderr.should == "No pairhost config found. First run 'pairhost init'.\n"
        process.should_not be_success
      end
    end

    it "init creates a config directory and file" do
      config_dir.should_not exist_on_filesystem

      pairhost "init"

      config_dir.should exist_on_filesystem
      config_file.should exist_on_filesystem
    end
  end

  context "when a valid pairhost config is present" do
    before(:all) { ensure_config_file }

    context "when an instance has NOT been provisioned" do
      let(:instance_file) { File.expand_path('~/.pairhost/instance') }
      let(:backup_file)   { File.expand_path('~/.pairhost/instance_test_backup') }

      before(:all) { FileUtils.mv(instance_file, backup_file) if File.exist?(instance_file) }
      after(:all)  { FileUtils.mv(backup_file, instance_file) if File.exist?(backup_file) }

      # create --> asks to confirm creation
      # up --> asks to confirm creation
      # init --> should complain that ~/.pairhost already exists
      # attach --> multiple branches; with instance id specific and without
      # provision --> not implemented yet
      # detach --> not implemented yet

      %w{status ssh resume stop destroy}.each do |method|
        it "#{method} returns an error message and failure exit code" do
          pairhost method
          stderr.should == "No pairhost instance found. Please create or attach to one.\n"
          process.should_not be_success
        end
      end
    end

    context "when an instance has been provisioned" do
      # TODO: make sure the instance_id file exists;
      # provision an EC2 instance?
    end

  end
end
