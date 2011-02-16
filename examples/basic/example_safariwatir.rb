$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'watirgrid'

# Here as some basic examples in plain Ruby with Watirgrid

# Start a Controller using defaults
controller = Controller.new
controller.start

# Start a Provider with SafariWatir
provider = Provider.new(:browser_type => 'safari')
provider.start

# Start a Grid
grid = Watir::Grid.new
grid.start(:take_all => true)

# Control the Providers via the Grid
# We only have one Provider on the Grid so no real need for threads
# however keeping the thread construct for example only
threads = []
  grid.browsers.each_with_index do |browser, index|
    threads << Thread.new do
      b = browser[:object].new_browser
      b.goto("http://www.google.com")
      b.text_field(:name, 'q').set("watirgrid")
      b.button(:name, "btnI").click
      b.close
    end
  end
threads.each {|thread| thread.join}
