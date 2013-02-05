require_relative '../lib/credential'

describe Credential do
  context "given a config file" do
    let(:config_file) { File.expand_path('../../config.example.yml', __FILE__) }

    it 'should return a secret access key' do
      credential = Credential.new(config_file)
      credential.secret_access_key.should == "YOUR_SECRET_ACCESS_KEY"
    end

    it 'should return an access key id' do
      credential = Credential.new(config_file)
      credential.access_key_id.should == "YOUR_SECRET_ACCESS_KEY_ID"
    end
  end

  context "given a config file for credentials within pairhost config file" do
    let(:config_file) { File.expand_path('../data/config_with_aws_path.yml', __FILE__) }

    it 'should return an access key' do
      credential = Credential.new(config_file)
      credential.secret_access_key.should == "YOUR_AWS_SECRET_ACCESS_KEY"
    end
  end
end
