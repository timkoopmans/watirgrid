$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'watirgrid'

# Here's some basic examples in plain Ruby with Watirgrid

# Start a Controller using defaults
controller = Controller.new
controller.start

# Start a Provider with SafariWatir
provider = Provider.new(:driver => 'safariwatir')
provider.start

# Control the Providers via the Grid
Watir::Grid.control do |browser, index|
  p "I am browser index #{index}"
  browser.goto "http://google.com"
  p browser.title
  browser.text_field(:name, 'q').set("watirgrid")
  browser.button(:name, "btnI").click
  browser.close
end
