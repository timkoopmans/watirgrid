$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib'))
require 'watirgrid'
require 'rspec/expectations';

ENV["GRID"] = 'true'
ENV["controller_uri"] = "druby://10.0.1.3:11235"

if ENV["GRID"] then
  params = {}
  params[:controller_uri]   = ENV["controller_uri"]
  params[:browser_type]     = 'chrome' # type of webdriver browser to spawn
  grid ||= Watir::Grid.new(params)
  grid.start(:initiate => true, :quantity => 1, :take_all => true)
else
  @browser ||= Watir::Browser.new :chrome
end

Before do |scenario|
  @browser = grid.providers.first
end

at_exit do
  grid.iterate do |browser|
    browser.close
  end
  grid.release_tuples
end
