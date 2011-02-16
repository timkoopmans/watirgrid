require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'extensions/remote'

describe 'Using the Grid with WebDriver Remote' do
  before(:all) do
    @controller = Controller.new(
      :loglevel => Logger::ERROR)
    @controller.start
    provider = Provider.new(
      :loglevel => Logger::ERROR, :browser_type => 'webdriver_remote')
    provider.start
  end

  after(:all) do
    @controller.stop
  end

  it 'should take the last provider on the grid and execute some Watir code in WebDriver with HtmlUnit' do
    grid = Watir::Grid.new
    grid.start(:quantity => 1, :take_all => true)
    threads = []
    grid.browsers.each do |browser|
      threads << Thread.new do 
        b = browser[:object].new_browser(:htmlunit)
        b.goto("http://www.google.com")
        b.text_field(:name, 'q').set("watirgrid")
        b.button(:name, "btnI").click
        b.close
      end
    end
    threads.each {|thread| thread.join}
    grid.size.should == 1
  end
end
