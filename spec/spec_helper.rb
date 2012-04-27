require 'bahia'
require 'pairhost'

RSpec.configure do |config|
  config.include Bahia
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true
  config.filter_run_excluding :disabled => true
  config.alias_example_to :fit, :focused => true
  config.color_enabled = true
end
