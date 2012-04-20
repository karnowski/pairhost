# Pairhost

Create an EC2 instance for Relevance, Inc. remote pairing!  It creates the instance and reports the public DNS name right from the command line.

## How To Use

    # install bundler
    bundle install
    cp config.example.yml config.yml
    # edit the config to use real EC2 & AMI stuff (ask me if you need it)
    #TODO: ./pairhost up