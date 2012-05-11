require 'spec_helper'
require 'fileutils'

def ensure_config_file
  config_file = File.expand_path('~/.pairhost/config.yml')
  return if File.exist?(config_file)
  abort "Pairhost config file was NOT found."
end

def safely_move(source, target)
  if File.exist?(source)
    FileUtils.rm_rf(target)
    FileUtils.mv(source, target)
  end
end

describe Pairhost do
  context "when NO pairhost config is present" do
    let(:config_dir)  { File.expand_path('~/.pairhost') }
    let(:backup_dir)  { File.expand_path('~/.pairhost_test_backup') }
    let(:config_file) { File.expand_path('~/.pairhost/config.yml') }

    before(:all) { safely_move config_dir, backup_dir }
    after(:all)  { safely_move backup_dir, config_dir }

    the "attach command returns an error message and failure exit code" do
      pairhost "attach some-instance"
      stderr.should == "pairhost: No config found. First run 'pairhost init'.\n"
      process.should_not be_success
    end

    %w{create up provision detach status ssh resume stop destroy}.each do |method|
      the "#{method} command returns an error message and failure exit code" do
        pairhost method
        stderr.should == "pairhost: No config found. First run 'pairhost init'.\n"
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
    # NOTE: this assumes that as a developer you're also
    # a user of pairhost and have already called "pairhost init"
    # and configured real AWS credentials.
    before(:all) { ensure_config_file }

    the "init command complains that the config is already present" do
      pairhost "init"
      stderr.should == "pairhost: Already initialized.\n"
      process.should be_success
    end

    context "when an instance has NOT been provisioned" do
      let(:instance_file) { File.expand_path('~/.pairhost/instance') }
      let(:backup_file)   { File.expand_path('~/.pairhost/instance_test_backup') }

      before(:all) { FileUtils.mv(instance_file, backup_file) if File.exist?(instance_file) }
      after(:all)  { FileUtils.mv(backup_file, instance_file) if File.exist?(backup_file) }

      # create --> asks to confirm creation
      # up --> asks to confirm creation
      # attach --> multiple branches; with instance id specific and without
      # provision --> not implemented yet
      # detach --> not implemented yet

      %w{status ssh resume stop destroy}.each do |method|
        the "#{method} command returns an error message and failure exit code" do
          pairhost method
          stderr.should == "pairhost: No instance found. Please create or attach to one.\n"
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
