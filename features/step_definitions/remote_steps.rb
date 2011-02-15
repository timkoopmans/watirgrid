begin 
  require 'rspec/expectations'; 
rescue LoadError; 
  require 'spec/expectations'; 
end
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'watirgrid'
require 'socket'
require 'extensions/remote'

Given /^I have added a remote WebDriver provider to the controller on port (\d+)$/ do |port|
  provider = Provider.new(
    :ring_server_port => port.to_i,
    :ring_server_host => '127.0.0.1', 
    :loglevel => Logger::ERROR, :browser_type => 'webdriver_remote')
  provider.start
end
