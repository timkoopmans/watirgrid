$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'watirgrid'
require 'extensions/remote'

# Here's some basic examples in plain Ruby with Watirgrid and WebDriver Remote / HtmlUnit

# Start a Controller using defaults
controller = Controller.new
controller.start

# Start 50 Providers with WebDriver Remote
1.upto(50) do
  provider = Provider.new(:browser_type => 'webdriver_remote')
  provider.start
end

# Start another Grid
@grid = Watir::Grid.new
@grid.start(:take_all => true)
threads = []
  @grid.browsers.each_with_index do |browser, index|
    sleep 0.5 # let's sleep a little to give a more natural rampup
    threads << Thread.new do
      require 'selenium/server'
      include Selenium

      b = browser[:object].new_browser(:htmlunit)
      t = Time.now
      b.goto("http://90kts.local/")
      puts "#{Thread.current.object_id} : #{b.title} : Elapsed #{Time.now - t}"
      b.close
    end
  end
threads.each {|thread| thread.join}
