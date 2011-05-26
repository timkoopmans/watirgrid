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
        :loglevel => Logger::ERROR, :driver => 'selenium')
      provider.start
    end
  end

  after(:all) do
    @controller.stop
  end

  it 'should control a grid in Selenium::WebDriver with Firefox' do
    Watir::Grid.control(:ring_server_port => 12356, :browser_type => 'firefox') do |driver, index|
      driver.navigate.to "http://google.com"
      element = driver.find_element(:name, 'q')
      element.send_keys "Hello WebDriver!"
      element.submit
      driver.quit
    end
  end
end
