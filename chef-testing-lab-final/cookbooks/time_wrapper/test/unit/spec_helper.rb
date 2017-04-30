require 'chefspec'

SCRIPT_DIR = File.dirname(__FILE__)

RSpec.configure do |config|
    config.color = true
    config.cookbook_path = File.join(SCRIPT_DIR, '../../../../build/vendor')
end

$DEFAULT_CENTOS_SOLORUNNER_CFG = {
    platform: 'centos',
    version: '6.8'
}