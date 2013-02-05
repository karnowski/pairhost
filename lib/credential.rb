class Credential
  def initialize(config_file)
    @config ||= begin
      unless File.exists?(config_file)
        abort "Pairhost: No ~/.pairhost/config.yml found. First run 'pairhost init'."
      end
      config = YAML.load_file(config_file)
    end
  end

  def secret_access_key
    @config['aws_secret_access_key']
  end

  def access_key_id
    @config['aws_access_key_id']
  end
end
