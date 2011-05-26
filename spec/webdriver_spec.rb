require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe 'Using the Grid with WebDriver' do
  before(:all) do
    @controller = Controller.new(
      :ring_server_port => 12356,
      :loglevel => Logger::ERROR)
    @controller.start
    1.upto(1) do
      provider = Provider.new(
        :ring_server_port => 12356,
        :loglevel => Logger::ERROR, :browser_type => 'webdriver')
      provider.start
    end
  end

  after(:all) do
    @controller.stop
  end

  it 'should control a grid in WebDriver with Firefox' do
    Watir::Grid.control(:ring_server_port => 12356, :browser_type => 'firefox') do |browser, index|
      p "I am browser index #{index}"
      browser.goto "http://google.com"
      p browser.title
      browser.close
    end
  end

  it 'should iterate over a grid in WebDriver with Chrome' do
    grid = Watir::Grid.new(:ring_server_port => 12356, :browser_type => 'chrome')
    grid.start(:initiate => true)
    grid.iterate do |browser|
      browser.goto "http://google.com"
      browser.close
    end
  end
end
