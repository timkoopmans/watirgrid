require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'WatirGrid' do
  before(:all) do
    controller = Controller.new(
      :ring_server_port => 12351,
      :ring_server_host => '127.0.0.1',
      :loglevel => Logger::ERROR)
    controller.start
    1.upto(1) do 
      provider = Provider.new(
        :ring_server_port => 12351, 
        :loglevel => Logger::ERROR, :browser_type => 'ie')
      provider.start
    end
  end

  it 'should return how many grid are available in the tuplespace' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:read_all => true)
    grid.size.should == 1
  end

  it 'should find at least one browser in the tuplespace' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1, :read_all => true)
    grid.size.should == 1
  end
 
  it 'should take the first (and last) browser and execute some watir commands' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1, :take_all => true)
    threads = []
    grid.browsers.each do |browser|
      threads << Thread.new do 
        browser[:hostname].should == `hostname`.strip
        browser[:architecture].should == Config::CONFIG['arch']
        browser[:browser_type].should == 'ie'
        b = browser[:object].new_browser
        b.goto("http://www.google.com")
        b.text_field(:name, 'q').set("watirgrid")
        b.button(:name, "btnI").click
      end
    end
    threads.each {|thread| thread.join}
    grid.size.should == 1
  end

  it 'should find no more tuples in the tuplespace' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:read_all => true)
    grid.size.should == 0
  end

end

