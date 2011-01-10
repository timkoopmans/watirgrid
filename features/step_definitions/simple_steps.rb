begin 
  require 'rspec/expectations'; 
rescue LoadError; 
  require 'spec/expectations'; 
end
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'watirgrid'
require 'socket'

Given /^I have started a controller on port (\d+)$/ do |port|
  @controller = Controller.new(
    :ring_server_port => port.to_i,
    :loglevel => Logger::ERROR)
  @controller.start
  @grids = []
end

Then /^I should have a controller listening on UDP port (\d+)$/ do |port|
  u = UDPSocket.open
  u.connect('127.0.0.1', port.to_i)
end

Given /^I have added (\d+).+?provider.+?to the controller on port (\d+)$/ do |total, port|
  1.upto(total.to_i) do
    provider = Provider.new(
      :ring_server_port => port.to_i, 
      :loglevel => Logger::ERROR, :browser_type => 'webdriver')
    provider.start
  end
end

When /I start a grid using the read_all method on port (\d+)/ do |port|
  @grid = Watir::Grid.new(:ring_server_port => port.to_i, 
    :ring_server_host => '127.0.0.1')
  @grid.start(:read_all => true)
end

Then /^I should see (\d+) provider.+?on the grid$/ do |total| 
  @grid.size.should == total.to_i
end

When /I start a grid using the take_all method on port (\d+)/ do |port|
  @grid = Watir::Grid.new(:ring_server_port => port.to_i, 
    :ring_server_host => '127.0.0.1')
  @grid.start(:take_all => true)
end

Then /^if I release the providers on the grid$/ do 
  @grid.release_tuples
end


