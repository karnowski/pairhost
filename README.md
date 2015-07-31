# Pairhost

Manage EC2 instances for remote pairing the style that Relevance prefers.

## How to Use

    gem install pairhost
    pairhost init
    # edit ~/.pairhost/config.yml to use your real EC2 & AMI settings
    
    pairhost create "My Cool Pairhost"
    pairhost status
    pairhost ssh

    # down, stop, halt are all aliases
    pairhost down

    # resume will start a down pairhost
    pairhost resume
    
    # up will resume a down pairhost, but if none will create one
    pairhost up

    # ssh will resume a down pairhost, then SSH to it
    pairhost ssh

    # all future commands will affect the given instance
    pairhost attach instance-id

    # destroy and terminate are aliases
    pairhost destroy

## How to Test
    bundler install
    rake

## How to Update Gem on rubygems.org
    rake build
    gem push pkg/pairhost
