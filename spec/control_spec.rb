require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Using the Grid Control method' do
  before(:all) do
    @controller = Controller.new(
      :ring_server_port => 12357,
      :loglevel => Logger::ERROR)
    @controller.start
    provider = Provider.new(
      :ring_server_port => 12357,
      :loglevel => Logger::ERROR, :browser_type => 'safari')
    provider.start
  end

  after(:all) do
    @controller.stop
  end

  it 'should control a grid' do
    Watir::Grid.control(:ring_server_port => 12357) do |browser, index|
      p "I am browser index #{index}"
      browser.goto "google.com"
      p browser.title
      browser.close
    end
  end
end
