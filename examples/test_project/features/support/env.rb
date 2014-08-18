require 'selenium-webdriver'
require 'unicode_utils/upcase'
require 'date'
require 'rspec'
require 'rspec-expectations'
require 'capybara'
require 'capybara/dsl'
require 'capybara/cucumber'

World(Capybara)

#Loading required configation yml files
grid_config = YAML.load_file("#{File.dirname(__FILE__)}/../../selenium_grid/grid_config.yml")

#RSpec settings
RSpec.configure do |config|
  config.include Capybara::DSL
  config.expect_with :rspec do |c|
    c.syntax = [:expect,:should]
  end
end

#Capybara settings
Capybara.configure do |config|
  config.app_host = "http://www.google.com"
  config.default_selector = :css
  config.default_wait_time = 1
  config.default_driver = :selenium
  config.javascript_driver = :selenium
  config.match = :prefer_exact
  config.ignore_hidden_elements = false
  config.run_server = false
end

case ENV['BROWSER']
when 'firefox'
  Capybara.default_driver = :selenium_firefox
when 'chrome'
  Capybara.default_driver = :selenium_chrome
else
  raise "Specified value for BROWSER environment variable is not known."
end

# set driver name and capibilities
driver_name = "selenium_#{ENV['BROWSER']}"
caps = Selenium::WebDriver::Remote::Capabilities.send(ENV['BROWSER'])

caps.native_events = true

# Register the browser being used
if ENV['PORT']
  caps.native_events = false
  Capybara.register_driver driver_name.to_sym do |app|
    Capybara::Selenium::Driver.new(app,
    :browser => :remote,
    :url => "http://#{grid_config['hub_ip_address']}:" + "#{grid_config['hub_port_number']}" + "/wd/hub",
    :desired_capabilities => caps)
  end
end