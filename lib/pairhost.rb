require "pairhost/version"
require 'fog'
require 'thor'
require 'yaml'
require 'fileutils'

module Pairhost
  def self.config_file
    @config_file ||= File.expand_path('~/.pairhost/config.yml')
  end

  def self.config
    @config ||= begin
      unless File.exists?(config_file)
        abort "No pairhost config found. First run 'pairhost init'."
      end
      YAML.load_file(config_file)
    end
  end

  def self.instance_id
    @instance_id ||= begin
      file = File.expand_path('~/.pairhost/instance')
      unless File.exists?(file)
        abort "No pairhost instance found. Please create or attach to one."
      end
      File.read(file).chomp
    end
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
      "tags" => {"Name" => name,
                 "Created-By-Pairhost-Gem" => VERSION},
      "image_id" => config['ami_id'],
      "flavor_id" => config['flavor_id'],
      "key_name" => config['key_name'],
    }

    server = connection.servers.create(server_options)
    server.wait_for { ready? }

    @instance_id = server.id
    write_instance_id(@instance_id)

    server
  end

  def self.write_instance_id(instance_id)
    File.open(File.expand_path('~/.pairhost/instance'), "w") do |f|
      f.write(instance_id)
    end
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

  class CLI < Thor
    include Thor::Actions

    desc "ssh", "SSH to your pairhost"
    def ssh
      server = Pairhost.fetch
      exec "ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET pair@#{server.dns_name}"
    end

    desc "status", "Print the status of your pairhost"
    def status
      server = Pairhost.fetch
      puts "#{server.id}: #{server.tags['Name']}"
      puts "State: #{server.state}"
      puts server.dns_name if server.dns_name
    end

    map "start" => :resume

    desc "resume", "Start a stopped pairhost"
    def resume
      server = Pairhost.fetch
      puts "Starting..."
      Pairhost.start(server.reload)
      puts "started!"

      invoke :status
    end

    desc "create", "Provision a new pairhost; all future commands affect this pairhost"
    def create
      initials = `git config user.initials`.chomp.split("/").map(&:upcase).join(" ")
      default_name = "something1 #{initials}"
      name = ask_with_default("What to name your pairhost? [#{default_name}]", default_name)
      puts "Name will be: #{name}"
      puts "Provisioning..."
      # server = Pairhost.create(name)
      # puts "provisioning!"
      # invoke :status
    end

    desc "up", "Create a new pairhost or start your stopped pairhost"
    def up
      server = Pairhost.fetch

      if server
        invoke :resume
      else
        invoke :create
      end
    end

    map "halt" => :stop
    map "shutdown" => :stop
    map "suspend" => :stop

    desc "stop", "Stop your pairhost"
    def stop
      server = Pairhost.fetch
      puts "Shutting down..."
      Pairhost.stop(server)
      puts "shutdown!"
    end

    desc "attach", "All future commands affect this pairhost"
    def attach
      instance_id = ask("EC2 Instance?")
      Pairhost.write_instance_id(instance_id)
      invoke :status
    end

    map "terminate" => :destroy

    desc "destroy", "Terminate your pairhost"
    def destroy
      server = Pairhost.fetch
      confirm = ask("Type 'yes' to confirm deleting '#{server.tags['Name']}'.\n>")

      return unless confirm == "yes"

      puts "Destroying..."
      server.destroy
      server.wait_for { state == "terminated" }
      puts "destroyed!"
    end

    desc "init", "Setup your ~/.pairhost directory with default config"
    def init
      FileUtils.mkdir_p File.dirname(Pairhost.config_file)
      FileUtils.cp(File.dirname(__FILE__) + '/../config.example.yml', Pairhost.config_file)
    end

    desc "list", "List all instances on your EC2 account"
    def list
      require 'hirb'
      Hirb.enable

      puts Hirb::Helpers::AutoTable.render Pairhost.connection.servers,
        :headers => {:tags => 'name', :flavor_id => 'type' },
        :fields => [:tags, :id, :state, :flavor_id, :created_at, :image_id, :dns_name],
          :filters => {:tags => lambda {|e| e['Name'] || 'No Name' } }
    end

    desc "provision", "Freshen the Chef recipes"
    def provision
      puts "coming soon..."
    end

    private

    def ask_with_default(question, default)
      answer = ask(question)
      answer = answer.strip.empty? ? default : answer
      answer
    end
  end
end
