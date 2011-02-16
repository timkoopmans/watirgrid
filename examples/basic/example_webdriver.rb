$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'watirgrid'

# Here as some basic examples in plain Ruby with Watirgrid and WebDriver

# Start a Controller using defaults
controller = Controller.new
controller.start

# Start 2 Providers with WebDriver
1.upto(2) do
  provider = Provider.new(:browser_type => 'webdriver')
  provider.start
end

# Start another Grid
grid = Watir::Grid.new
grid.start(:take_all => true)

# Control the first Provider via the Grid using Firefox
# Note when we have a WebDriver object we also need to specify the target 
# browser in new_browser method
thread = Thread.new do 
  b = grid.browsers[0][:object].new_browser(:firefox)
  b.goto("http://google.com")
  b.text_field(:name, 'q').set("watirgrid")
  b.button(:name, "btnI").click
  b.close
end
thread.join

# Control the second Provider via the Grid, this time using Chrome
thread = Thread.new do 
  b = grid.browsers[1][:object].new_browser(:chrome)
  b.goto("http://google.com")
  b.text_field(:name, 'q').set("watirgrid")
  b.button(:name, "btnI").click
  b.close
end
thread.join
