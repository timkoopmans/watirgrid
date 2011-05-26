$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'watirgrid'

# Here's some basic examples in plain Ruby with Watirgrid and WebDriver

# Start a Controller using defaults
controller = Controller.new
controller.start

# Start 2 Providers with WebDriver
1.upto(2) do
  provider = Provider.new(:driver => 'webdriver')
  provider.start
end

# Control the Providers via the Grid
Watir::Grid.control(:browser_type => 'firefox') do |browser, index|
  p "I am browser index #{index}"
  browser.goto "http://google.com"
  p browser.title
  browser.text_field(:name, 'q').set("watirgrid")
  browser.button(:name, "btnI").click
  browser.close
end
