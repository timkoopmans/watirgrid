$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib'))
require 'watirgrid'
require 'rspec/expectations';
require 'watir-webdriver-performance'

# Setup a grid network, normally this is done outside of env.rb
controller = Controller.new(
  :ring_server_port => 12357,
  :loglevel => Logger::ERROR)
controller.start

2.times do
  provider = Provider.new(
    :ring_server_port => 12357,
    :loglevel => Logger::ERROR, :driver => 'webdriver')
  provider.start
end

ENV["GRID"] = 'true'

if ENV["GRID"] then
  params = {}
  # discover controller via ring server broadcast on UDP port
  params[:ring_server_port] = 12357

  # OR
  # optionally connect via a controller_uri environment variable
  # params[:controller_uri]  = ENV["controller_uri"]

  # Now for the other params
  params[:browser_type]    = 'firefox' # type of webdriver browser to spawn
  params[:quantity]        = 20       # max number of browsers to use
  params[:rampup]          = 10       # seconds
  grid ||= Watir::Grid.new(params)
  grid.start(:initiate => true)
else
  grid = []
  ##
  # Creating a dummy class when we're not using WatirGrid
  # so that the design steps can still call an iterate method.
  class Grid
    def initialize
      @browser ||= Watir::Browser.new :chrome
    end
    def iterate
      yield @browser
    end
  end
  grid = Grid.new
end

##
# This would be cool if I could modify the instance variable
# @browser within the proc block created... Then I could get
# rid of the @grid.iterate method from the design steps ...
#Around do |scenario, block|
  #grid.iterate do |browser|
    #@browser = browser # this doesn't work =(
    #block.call
  #end
#end

Before do
  @grid = grid
end

at_exit do
  grid.iterate do |browser|
    browser.close
  end
end
