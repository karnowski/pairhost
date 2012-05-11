require 'spec_helper'
require 'fileutils'

def ensure_config_file
  config_file = File.expand_path('~/.pairhost/config.yml')
  if File.exist?(config_file)
    puts "Pairhost config file found.  Assuming it's valid."
  else
    puts "Pairhost config file was NOT found.  Aborting."
    abort
  end
end

describe Pairhost do
  context "when a valid pairhost config is present" do
    before(:all) { ensure_config_file }

    context "when an instance has NOT been provisioned" do
      let(:instance_file) { File.expand_path('~/.pairhost/instance') }
      let(:backup_file)   { File.expand_path('~/.pairhost/instance_test_backup') }

      before(:all) { FileUtils.mv(instance_file, backup_file) if File.exist?(instance_file) }
      after(:all)  { FileUtils.mv(backup_file, instance_file) if File.exist?(backup_file) }

      # create
      # up
      # init
      # provision
      # attach

      it "status returns an error message and failure exit code" do
        pairhost "status"
        stderr.should == "No pairhost instance found. Please create or attach to one.\n"
        process.should_not be_success
      end

      it "ssh returns an error message and failure exit code" do
        pairhost "ssh"
        stderr.should == "No pairhost instance found. Please create or attach to one.\n"
        process.should_not be_success
      end

      it "resume returns an error message and failure exit code" do
        pairhost "resume"
        stderr.should == "No pairhost instance found. Please create or attach to one.\n"
        process.should_not be_success
      end

      it "stop returns an error message and failure exit code" do
        pairhost "stop"
        stderr.should == "No pairhost instance found. Please create or attach to one.\n"
        process.should_not be_success
      end

      it "destroy returns an error message and failure exit code" do
        pairhost "destroy"
        stderr.should == "No pairhost instance found. Please create or attach to one.\n"
        process.should_not be_success
      end



    end

    context "when an instance has been provisioned" do
      # TODO: make sure the instance_id file exists;
      # provision an EC2 instance?
    end

  end
end
