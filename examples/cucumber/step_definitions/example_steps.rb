$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib'))
require 'watirgrid'
require 'rspec/expectations';
require 'watir-webdriver-performance'

controller = Controller.new(
  :ring_server_port => 12357,
  :loglevel => Logger::ERROR)
controller.start

provider = Provider.new(
  :ring_server_port => 12357,
  :loglevel => Logger::ERROR, :browser_type => 'webdriver')
provider.start

Given /^(\d+) users open "([^"]*)"$/ do |quantity, browser|
  params={}
  params[:ring_server_port] = 12357
  # optionall connect via a controller_uri environment variable
  # params[:controller_uri]  = ENV["controller_uri"]
  params[:browser]         = browser        # type of webdriver browser to spawn
  params[:quantity]        = quantity.to_i  # max number of browsers to use
  params[:rampup]          = 10             # seconds
  @grid = Watir::Grid.new(params)
  @grid.start(:initiate => true)
end

Given /^navigate to the portal$/ do
  @grid.iterate {|browser| browser.goto "http://gridinit.com/examples/logon.html" }
end

When /^they enter their credentials$/ do
  @grid.iterate do |browser|
    browser.text_field(:name => "email").set "tim@mahenterprize.com"
    browser.text_field(:name => "password").set "mahsecretz"
    browser.button(:type => "submit").click
  end
end

Then /^they should see their account settings$/ do
  @grid.iterate do |browser|
    browser.text.should =~ /Maybe I should get a real Gridinit account/
  end
end

Then /^the response time should be less than (d+) seconds$/ do |response_time|
  @grid.iterate do |browser|
    browser.performance.summary[:response_time].should < response_time.to_i * 1000
  end
end
