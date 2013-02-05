class Credential
  def initialize(config_file)
    @config = load_yaml_file(config_file)

    unless aws_credential_file.nil?
      @config = load_yaml_file(File.expand_path(aws_credential_file))
    end
  end

  def secret_access_key
    @config['aws_secret_access_key']
  end

  def access_key_id
    @config['aws_access_key_id']
  end

  def aws_credential_file
    @config['aws_credential_file']
  end

  private

  def load_yaml_file(file)
    unless File.exists?(file)
      abort "#{file} not found. First run 'pairhost init' or confirm file exists."
    else
      YAML.load_file(file)
    end
  end
end
