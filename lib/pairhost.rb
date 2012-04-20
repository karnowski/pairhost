require "pairhost/version"
require 'fog'
require 'thor'
require 'yaml'

module Pairhost
  def self.config
    @config ||= YAML.load(File.open(File.expand_path('~/.pairhost/config.yml')))
  end

  def self.instance_id
    @instance_id ||= File.read(File.expand_path('~/.pairhost/instance')).chomp
  end

  def self.connection
    return @connection if @connection

    Fog.credentials = Fog.credentials.merge(
      :private_key_path => config['private_key_path'], 
    )

    @connection = Fog::Compute.new(
      :provider              => config['provider'],
      :aws_secret_access_key => config['aws_secret_access_key'],
      :aws_access_key_id     => config['aws_access_key_id'],
    )
  end

  def self.create(name)
    server_options = {
      "tags" => {"Name" => name},
      "image_id" => config['ami_id'],
      "flavor_id" => config['flavor_id'],
      "key_name" => config['key_name'],
    }

    server = connection.servers.create(server_options)
    server.wait_for { ready? }
    server
  end

  def self.start(server)
    server.start
    server.wait_for { ready? }
  end

  def self.stop(server)
    server.stop
    server.wait_for { state == "stopped" }
  end

  def self.fetch
    connection.servers.get(instance_id) if instance_id
  end

=begin
  vagrant commands:
    box --> ignore?
    destroy
    gem --> ignore
    halt
    init --> ignore
    package --> ignore
    provision
    reload
    resume
    ssh
    ssh-config --> ignore?
    status
    suspend
    up
=end

  class CLI < Thor
    desc "ssh", "SSH to your pairhost"
    def ssh
      server = Pairhost.fetch
      exec "ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET pair@#{server.reload.dns_name}"
    end

    desc "status", "Print the status of your pairhost"
    def status
      server = Pairhost.fetch
      display_status(server)
    end

    # TODO: create asks for a name, but gives you a default based on the $CWD and git initials, if any
    desc "up", "Create a new pairhost or start your stopped pairhost"
    def up
      server = Pairhost.fetch

      if server
        puts "Starting..."
        Pairhost.start(server)
        puts "started!"
      else
        puts "Provisioning..."
        server = Pairhost.create("DevOps Dev (LK FTW)")
        puts "provisioning!"
      end

      display_status(server)
    end

    map "stop" => :suspend
    map "shutdown" => :suspend
    map "halt" => :suspend

    desc "suspend", "Stop your pairhost"
    def stop
      server = Pairhost.fetch
      puts "Shutting down..."
      Pairhost.shutdown(server)
      puts "shutdown!"
    end

    desc "attach", "Start using an existing pairhost given its EC2 instance ID"
    def attach
      puts "coming soon..."
    end

    desc "destroy", "Terminate your pairhost"
    def destroy
      server = fetch
      puts "Destroying..."
      server.destroy
      server.wait_for { state == "terminated" }
      puts "destroyed!"
    end

    # TODO: this is just a spike, remove
    desc "list", "List all instances on your EC2 account"
    def list
      Pairhost.connection.servers.each do |server|
        puts server.tags['Name']
        puts server.inspect
        puts 
        puts
      end
    end

    # TODO: this is just a spike, remove
    desc "initials", "DEBUG: just a test task for getting the current git initials"
    def initials
      initials = `git config user.initials`.chomp.split("/").map(&:upcase).join(" ")
      puts initials.inspect
    end

    desc "init", "Setup your ~/.pairhost directory with default config"
    def init
      
    end

    private 
    
    def display_status(server)
      puts "#{server.id}: #{server.tags['Name']}"
      puts "State: #{server.state}"
      puts server.dns_name if server.dns_name
    end

  end
end