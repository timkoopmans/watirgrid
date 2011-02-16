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

  it 'should take the last provider on the grid and execute some Watir code in WebDriver with Firefox' do
    grid = Watir::Grid.new(:ring_server_port => 12356)
    grid.start(:quantity => 1, :take_all => true)
    threads = []
    grid.browsers.each do |browser|
      threads << Thread.new do 
        browser[:hostname].should == `hostname`.strip
        browser[:architecture].should == Config::CONFIG['arch']
        browser[:browser_type].should == 'webdriver'
        b = browser[:object].new_browser(:firefox)
        b.goto("http://www.google.com")
        b.text_field(:name, 'q').set("watirgrid")
        b.button(:name, "btnI").click
        b.close
      end
    end
    threads.each {|thread| thread.join}
    grid.size.should == 1
  end

  it 'should find no more providers on the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12356)
    grid.start(:read_all => true)
    grid.size.should == 0
  end
end
